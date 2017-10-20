assert("Lua 5.3" == _VERSION)
assert(arg[1], "\n\n[ERROR] no input file\n\n")
local OUT = arg[2] or "."

require("mod_binary_reader")
local r = BinaryReader

local zlib = require("zlib")


--[[ funcs ]]------------------------------------------------------------------

local function read_header()
    local t = {}
    r:uint32()          -- version
    t[1] = r:idstring("G3V0") or "G3V0"
    r:uint32()          -- revision
    r:uint32()          -- encription
    t[2] = r:uint32()   -- compression, 0/1 -> none/zlib
    t[3] = r:hex32(1)   -- reserved
    t[4] = r:uint64()   -- file offset
    t[5] = r:uint64()   -- dir offset
    t[6] = r:uint64()   -- file size
    return t
end

local function convert_attr(a)
    local att = {
        a & 0x00001 > 0 and "r" or "-",
        a & 0x00002 > 0 and "h" or "-",
        a & 0x00004 > 0 and "s" or "-",
        a & 0x00008 > 0 and "?" or "-",
        a & 0x00010 > 0 and "d" or "-",
        a & 0x00020 > 0 and "a" or "-",
        a & 0x00040 > 0 and "?" or "-",
        a & 0x00080 > 0 and "?" or "-",
        a & 0x00100 > 0 and "t" or "-",
        a & 0x00200 > 0 and "?" or "-",
        a & 0x00400 > 0 and "?" or "-",
        a & 0x00800 > 0 and "c" or "-",
        a & 0x01000 > 0 and "?" or "-",
        a & 0x02000 > 0 and "n" or "-",
        a & 0x04000 > 0 and "e" or "-",
        a & 0x08000 > 0 and "x" or "-",
        a & 0x10000 > 0 and "v" or "-",
        a & 0x20000 > 0 and "P" or "-",
        a & 0x40000 > 0 and "s" or "-",
        a & 0x80000 > 0 and "S" or "-"
    }
    return table.concat(att)
end

local function convert_time(t)  -- Win FILETIME to Unix time
    local u = math.floor(t / 10000000 - 11644473600)
    return os.date("%Y-%m-%d %H:%M:%S", u)
end

local function unlz(data)
    local out, eof, b_in, b_out = zlib.inflate()(data)
    return out, eof, b_in, b_out
end

local function save_file(fullpath, data)
--    print(fullpath)
    local w = assert(io.open(fullpath, "w+b"))
    w:write(data)
    w:close()
end

local function parse_csv(data)
    local line_fmt = "([^|]+)|([^|]+)|[^\13^\10]+\13\10"
    local map_fmt = "Map_[%d_]+"
    local map_full_fmt = "Map_(%d+)_(%d+)_(%d+)"
    local elex_fmt = "elex-%d-%d-%d.dds"

    local m = {}
    -- get line
    for hash, name in string.gmatch(data, line_fmt) do
        -- is it map?
        local f = string.find(name, map_fmt)
        if f and f == 1 then
            hash = "w_img_0_na_" .. hash .. ".rom"

            -- Map_ZZZZ_YYYY_XXXX -> elex-z-y-x
            for z, y, x in string.gmatch(name, map_full_fmt) do
                -- elex scale is 5 (big) to 0 (small), leafjet scale is 0 to 5
                z = 5 - tonumber(z)
                y = tonumber(y)
                x = tonumber(x)
                name = elex_fmt:format(z, y, x)
            end

            m[hash] = name
            print(hash .. " -> " .. name)
        end
    end
    return m
end


local files = {}

local img_found = false
local csv_found = false
local dds = {}

local function get_file(fullpath)
    local fname_sz = r:uint32()
    local fname = r:str(fname_sz)
    r:uint8()

    local offset = r:uint64()
    local t_cre = r:uint64() --convert_time(r:uint64())
    local t_acc = r:uint64() --convert_time(r:uint64())
    local t_mod = r:uint64() --convert_time(r:uint64())
    local f_att = r:uint32() --; assert(131104 == f_att)
    local f_enc = r:uint32() --; assert(0 == f_enc)
    local f_com = r:uint32()
    local f_sizez = r:uint32()
    local f_size = r:uint32()

    --    print(fullpath, fname, f_com, f_size, t_mod, f_att, offset)
    if img_found then
        if not csv_found then
            if "w_img_0_na.csv" == fname then
                local pos = r:pos()

                r:seek(offset)
                local data = r:str(f_sizez)
                if 1 == f_enc then data = unlz(data) end
                --save_file(OUT .. "/w_img_0_na.csv", data)
                csv_found = true

                dds = parse_csv(data)

                r:seek(pos)
                
                io.write("save dds...")
            end
        else
            local dds_name = dds[fname]
            if dds_name then
                local pos = r:pos()

                r:seek(offset + 44)
                local data = r:str(f_sizez)
                if 1 == f_enc then data = unlz(data) end
                save_file(OUT .. "/" .. dds_name, data)
                io.write(".")

                r:seek(pos)
            end
        end
    end
end

local function get_dir(fullpath, l)
    local fname_sz = r:uint32()
    local fname
    if fname_sz > 0 then 
        fname = fullpath .. "/" .. r:str(fname_sz)
        r:uint8()
    else
        fname = "."
    end

    local t_cre = r:uint64() --convert_time(r:uint64())
    local t_acc = r:uint64() --convert_time(r:uint64())
    local t_mod = convert_time(r:uint64())
    local f_att = r:uint32() --; assert(131088 == f_att)
    local count = r:uint32()

    if l == 1 then
        print(l, fname, count, t_mod)
        if "./0_na_img" == fname then
            img_found = true
            print("img...")
        else
            img_found = false
        end
    end

    for i = 1, count do
        local attr = r:uint32()
        if attr & 0x10 > 0  then    -- directory
            get_dir(fname, l+1)
        else
            get_file(fname)
        end
    end
end


--[[ main ]]-------------------------------------------------------------------

r:open(arg[1], "rb")

local h = read_header()
print("magik\tcomp\treserved\toffset\troot offset\tsize")
print(table.concat(h, "\t"))
print()

r:seek(h[5])
get_dir(".", 0)

r:close()
