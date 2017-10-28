assert("Lua 5.3" == _VERSION)
assert(arg[1], "\n\n[ERROR] no input file\n\n")
assert(arg[2], "\n\n[ERROR] no output file\n\n")

local LANG = tonumber(arg[3]) or nil

require("mod_binary_reader")
local r = BinaryReader

--[[ utils ]]------------------------------------------------------------------

local wr = io.write

local wf = function(fmt, ...)
    wr(string.format(fmt, ...))
end

local out = assert(io.open(arg[2], "w+b"))

local owr = function(s) out:write(s) end

local function to_utf16(s)
    local out, pos = string.gsub(s, "(.)", "%1\x00")
    return out
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
    assert(0 == unk, "\n\nexpected 0x00000000, received " .. unk .. "\n\n")
    header.c_num = r:uint32()    -- кол-во колонок (/2 - языков)
    header.r_num = r:uint32()    -- кол-во строк (хешей)
    header.s_arr = r:uint32()    -- адрес массива имен файлов
    header.n_arr = r:uint32()    -- адрес массива заголовков (первая строка таблицы)
    header.c_arr = r:uint32()    -- адрес колонок...
    header.r_arr = r:uint32()    -- адрес строк...

    wr("s_num\tc_num\tc_num\ts_arr\tn_arr\tc_arr\t\tr_arr\n")
    wr(header.s_num .. "\t")
    wr(header.c_num .. "\t")
    wr(header.r_num .. "\t")
    wr(header.s_arr .. "\t")
    wr(header.n_arr .. "\t")
    wr(header.c_arr .. "\t")
    wr(header.r_arr .. "\n")

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

    wr("hash readed: " .. count .. "\n")
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
        local sz = tmp[r:pos()]-1
        local name = r:str(sz)
        r:uint8()
        lang[i] = name
    end
    tmp = nil

    wr("lang readed: " .. count .. "\n")
    return lang
end

local function read_lang_ptr(offset, count)
    r:seek(offset)
    local lang_ptr = { [count-1] = true }
    for i = 0, count-1 do
        -- strings (size, offset), symbols (size, offset)
        lang_ptr[i] = { [0] = r:uint32(), r:uint32(), r:uint32(), r:uint32() }
    end
    assert(r:pos() == r:size()) -- must be EOF

    return lang_ptr
end

local function read_column(ptr, count)
    local beg_sz = count - 1
    local seq_sz = ptr[0] - (count * 4) - 1 -- strings size
    local sym_sz = ptr[2] // 4 - 1          -- symbol size

    local begin = { [beg_sz] = true }
    local seq = { [seq_sz] = true }
    local symbol = { [sym_sz] = true }

    r:seek(ptr[1]) -- string offset
    for i = 0, beg_sz do
        begin[i] = r:uint32()
    end
    for i = 0, seq_sz do
        seq[i] = r:uint16()
    end

    r:seek(ptr[3]) -- symbol offset)
    for i = 0, sym_sz do
        symbol[i] = { nxt = r:uint16(), char = r:str(2) }
    end

    return { begin = begin, seq = seq, symbol = symbol }
end

local function read_row(lang, row)
    local i = lang.begin[row]
    if 0xffffffff == i then return "" end

    local str = {}
    local seq = lang.seq
    while true do
        local s = seq[i]
        if s == 0 then break end
        
        local sub = {}
        local ls = lang.symbol
        while true do
            table.insert(sub, 1, ls[s].char)
            s = ls[s].nxt
            if s == 0 then break end
        end
        table.insert(str, table.concat(sub))
        i = i + 1
    end

    return table.concat(str)
end


--[[ localization ]]-----------------------------------------------------------

local function read_STB(ver)
    local h = read_header()
    local source = read_source(h.s_arr, h.s_num)
    local hash = read_hash(h.r_arr, h.r_num)
    local lang = read_lang(h.n_arr, h.c_num)
    local lang_ptr = read_lang_ptr(h.c_arr, h.c_num)
    wr("headers done, start data reading...\n")

    local tbl = { [h.c_num-1] = true }
    tbl[LANG] = read_column(lang_ptr[LANG], h.r_num)
    wr("data done, start output...\n")
    
    owr("\xFF\xFE")
    owr(to_utf16("L = {}\r\n"))
    owr(to_utf16("L.lang = \"" .. lang[LANG] .. "\"\r\n"))

    for r = 0, h.r_num-1 do
        local str = read_row(tbl[LANG], r)
        
        owr(to_utf16(("L[0x%08X] = [["):format(hash[r])))
        owr(str)
        owr(to_utf16("]]\r\n"))
    end
    owr(to_utf16("return L\r\n"))
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

if out then out:close() end
