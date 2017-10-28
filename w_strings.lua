assert("Lua 5.3" == _VERSION)
assert(arg[1], "\n\n[ERROR] no input file\n\n")
assert(arg[2], "\n\n[ERROR] no output file\n\n")

local LANG = tonumber(arg[3]) or nil

require("mod_binary_reader")
local r = BinaryReader

local out = assert(io.open(arg[2], "w+b"))

--[[ utils ]]------------------------------------------------------------------

local wr = io.write
local tochar = string.char
local tobyte = string.byte

local wf = function(fmt, ...)
    wr(string.format(fmt, ...))
end

local owr = function(s) out:write(s) end

local function utf16_to_utf8(u16)
    local u8 = {}
    if u16 < 127 then
        u8[1] = tochar(u16 & 255)
    elseif u16 <= 2047 then
        u8[1] = tochar(u16 >> 6 & 31 | 192)
        u8[2] = tochar(u16 & 63 | 128)
    else
        u8[1] = tochar(u16 >> 12 & 15 | 224)
        u8[2] = tochar(u16 >> 6 & 63 | 128)
        u8[3] = tochar(u16 & 63 | 128)
    end
    return table.concat(u8)
end

local function convert_time(time)
    local u = math.floor(time / 10000000 - 11644473600)
    local str = os.date("%Y-%m-%d %H:%M:%S", u)
    return str
end

--[[ funcs ]]------------------------------------------------------------------

local function read_header()
    local header = {}

    header.s_num = r:uint32()    -- кол-во имён файлов
    local unk = r:uint32()
    assert(0 == unk, "\n\nexpected 0, received " .. unk .. "\n\n")
    header.c_num = r:uint32()    -- кол-во колонок (/2 - языков)
    header.r_num = r:uint32()    -- кол-во строк (хешей)
    header.s_arr = r:uint32()    -- адрес массива имен файлов
    header.n_arr = r:uint32()    -- адрес массива заголовков (первая строка таблицы)
    header.c_arr = r:uint32()    -- адрес колонок...
    header.r_arr = r:uint32()    -- адрес строк...
--[[
    wr("s_num\tc_num\tc_num\ts_arr\tn_arr\tc_arr\t\tr_arr\n")
    wr(header.s_num .. "\t")
    wr(header.c_num .. "\t")
    wr(header.r_num .. "\t")
    wr(header.s_arr .. "\t")
    wr(header.n_arr .. "\t")
    wr(header.c_arr .. "\t")
    wr(header.r_arr .. "\n")
--]]
    return header
end

local function read_source(offset, count)
    local source = { [count-1] = true }
    r:seek(offset)
    for i = 0, count-1 do
        local sz = r:uint16()
        local name = r:str(sz)
        local time = (r:uint32() << 32) + r:uint32()
        source[i] = { name, time }
    end
--[[
    wr("\nsources:\n")
    for i = 0, count-1 do
        local s = source[i]
        wf("%s %s\n", convert_time(s[2]), s[1])
    end
--]]
    return source
end

local function read_hash(offset, count)
    local hash = { [count-1] = true }
    r:seek(offset)
    local sz = r:uint32(); assert(count*4 == sz)
    local ptr = r:uint32(); assert(r:pos() == ptr)
    for i = 0, count-1 do
        hash[i] = r:uint32()
    end

    wr("hashes (rows): " .. count .. "\n")
    return hash
end

local function read_lang(offset, count)
    r:seek(offset)
    local tmp = { [count-1] = true }
    for _ = 0, count-1 do
        local sz = r:uint32()
        local off = r:uint32()
        tmp[off] = sz
    end

    local lang = { [count-1] = true }
    for i = 0, count-1 do
        local sz = tmp[r:pos()]-1   -- skip \x00 at end
        local name = r:str(sz)
        r:uint8()
        lang[i] = name
    end
    tmp = nil

    wr("languages: " .. count .. "\n")
    return lang
end

local function read_lang_ptr(offset, count, rows)
    r:seek(offset)
    local lang_ptr = { [count-1] = true }
    for i = 0, count-1 do
        lang_ptr[i] = {
            [0] = r:uint32() - (rows * 4) -1,   -- control size
            [1] = r:uint32(),                   -- control offset
            [2] = r:uint32() // 4 -1,           -- char syze
            [3] = r:uint32()                    -- char offset
        }
    end
    assert(r:pos() == r:size()) -- must be EOF

    return lang_ptr
end

local function read_column(ctr, rows)
    local beg_sz = rows -1
    local seq_sz = ctr[0]   -- control size
    local sym_sz = ctr[2]   -- char size

    local begin = { [beg_sz] = true }
    local seq = { [seq_sz] = true }
    local ptr = { [sym_sz] = true }
    local char = { [sym_sz] = true }

    r:seek(ctr[1]) -- control offset
    for i = 0, beg_sz do
        begin[i] = r:uint32()
    end
    for i = 0, seq_sz do
        seq[i] = r:uint16()
    end

    r:seek(ctr[3]) -- char offset)
    for i = 0, sym_sz do
        ptr[i] = r:uint16()
        char[i] = utf16_to_utf8(r:uint16())
    end

    return { begin = begin, seq = seq, ptr = ptr, char = char }
end

local function read_row(lang, row)
    local idx = lang.begin[row]
    if 0xffffffff == idx then return "" end

    local str = {}
    local seq = lang.seq
    local ptr = lang.ptr
    local char = lang.char

    local s = seq[idx]
    while s ~= 0 do
        local add = {}
        while s ~= 0 do
            table.insert(add, 1, char[s])
            s = ptr[s]
        end
        table.insert(str, table.concat(add))
        idx = idx + 1
        s = seq[idx]
    end

    return table.concat(str)
end


--[[ localization ]]-----------------------------------------------------------

local function read_STB(ver)
    local h = read_header()
    local source = read_source(h.s_arr, h.s_num)
    local hash = read_hash(h.r_arr, h.r_num)
    local lang = read_lang(h.n_arr, h.c_num)
    local lang_ptr = read_lang_ptr(h.c_arr, h.c_num, h.r_num)
    wr("header done, start data reading...\n")

    local tbl = { [h.c_num-1] = true }
    tbl[LANG] = read_column(lang_ptr[LANG], h.r_num)
    wr("data done, start output...\n")

    owr(("local L = {}\r\nL.lang = \"%s\"\r\n"):format(lang[LANG]))
    for r = 0, h.r_num-1 do
        local str = read_row(tbl[LANG], r)
        owr(("L[0x%08X] = [[%s]]\r\n"):format(hash[r], str))
    end
    owr("return L\r\n")
    wr("all done!\n")
end


local function read_GAR5()
    r:idstring("GAR5")
    r:idstring("\32\0\0\0")

    if "STB" == r:str(3) then
        local ver = r:uint8()
        read_STB(ver)
    else
        io.stderr("\nthe file is not like a localization table.\n")
    end
end


--[[ main ]]-------------------------------------------------------------------

r:open(arg[1], "rb")
read_GAR5()
r:close()

out:close()
