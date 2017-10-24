assert("Lua 5.3" == _VERSION)
assert(arg[1], "\n\n[ERROR] no input file\n\n")
local OUT = arg[2]

require("mod_binary_reader")
local r = BinaryReader

local zlib
if OUT then zlib = require("zlib") end


--[[ funcs ]]------------------------------------------------------------------

local function convert_time(t)  -- Win FILETIME to Unix time
    local u = math.floor(t / 10000000 - 11644473600)
    return os.date("%Y-%m-%d %H:%M:%S", u)
end

local function read_header()
    local t = {}
    r:idstring("PAK ")
    t[1] = r:str(4)     -- "V001"
    assert(0 == r:uint64())
    t[3] = r:uint64()   -- info_off
    t[4] = r:uint64()   -- size

    return t
end

local function read_info(off)
    r:seek(off)
    r:idstring("VOL ")
    local t = {}
    assert(1 == r:uint32())
    t[2] = r:uint32() + off -- name_off
    t[3] = r:uint32()       -- name_sz
    t[4] = r:uint32() + off -- file_off
    t[5] = r:uint32()       -- file_num
    t[6] = r:uint32() + off -- jour_off
    t[7] = r:uint32()       -- jour_num

    return t
end

local function read_jour(offset, jnum, fnum)
    r:seek(offset)
    local t = {}
    for i = 1, jnum do
        r:idstring("JOUR")
        local j = { r:uint32(), r:uint32(), r:uint32() }
        t[i] = table.concat(j, ", ")
    end

    local n = {}
    for i = 1, fnum do
        n[i] = r:uint32()
    end

    return t, n
end

local function read_files(off, count)
    local f = {}
    for i = 1, count do
        r:idstring("FILE")
        local t = {}
        assert(0 == r:uint32())
        t[2] = r:uint32() + off -- name_off
        t[3] = r:uint32() + off -- path_off
        t[4] = r:uint64()       -- data_off
        t[5] = r:uint32()       -- attr
        assert(0 == r:uint32())
        t[7] = r:uint64()       -- ctime
        t[8] = r:uint64()       -- mtime
        t[9] = r:uint32()       -- file_size
        t[10] = r:uint32()      -- data_size
        t[11] = r:uint32()      -- comp, 0000 or ZLIB
        assert(0 == r:uint32())
        assert(0 == r:uint32())
        assert(0 == r:uint32())
        table.insert(f, t)

        off = off + 72  -- size of FILE entry
    end
    
    -- replace names
    for i = 1, #f do
        local e = f[i]
        r:seek(e[2])
        e[2] = r:str()
        r:seek(e[3])
        e[3] = r:str()
    end
    
    -- sort by offset
    table.sort(f, function(a, b) return a[4] < b[4] end)
    
    return f
end

local function unpack_files(files)
    for i = 1, #files do
        local f = files[i]
        print(("0x%08X %8d -> %8d (%s) [%s] %s"):format(
                f[4], f[10], f[9], f[11] == 0 and "--" or "lz", convert_time(f[8]), f[2]))
        
        if OUT then
            r:seek(f[4])
            local data = r:str(f[10])
            if f[11] ~= 0 then
                local eof, b_in, b_out
                data, eof, b_in, b_out = zlib.inflate(-15)(data)
                assert(true == eof)
                assert(f[10] == b_in)
                assert(f[9] == b_out)
            end
            local w = assert(io.open(OUT .. "/" .. f[2], "w+b"))
            w:write(data)
            w:close()
        end
    end
end


--[[ main ]]-------------------------------------------------------------------

r:open(arg[1], "rb")

local head = read_header()
local info = read_info(head[3])
local jour, fsort = read_jour(info[6], info[7], info[5])
local files = read_files(info[4], info[5])

unpack_files(files)

r:close()
