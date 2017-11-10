assert("Lua 5.3" == _VERSION)
assert(arg[1], "\n\n[ERROR] no input file\n\n")

local OUT = arg[2] or "."
OUT = OUT .. "/" ..string.gsub(arg[1], "(.-)([^\\]-[^\\%.]+).save$", "%2")

local FILE = nil


require("mod_binary_reader")
r = BinaryReader

require("gar5_util")
local u = GAR5_UTIL

local ok, NAMES = pcall(dofile, "names_i686.luac")
if not ok then
    NAMES = dofile("names_x64.luac")
end


--[[ util ]]-------------------------------------------------------------------

wr = function(s) FILE:write(s) end

wf = function(fmt, ...) wr(string.format(fmt, ...)) end
local function eol() wr("\n") end
tab = function(l) wr(("  "):rep(l)) end

local hash_unknown = {}
local function show_unknown_hash()
    local hash_sorted = {}
    for k, v in pairs(hash_unknown) do
        table.insert(hash_sorted, k)
    end
    if #hash_sorted > 0 then
        table.sort(hash_sorted)
        print("unknown hashes:")
        for i = 1, #hash_sorted do
            print(hash_sorted[i])
        end
        print()
    end
end


--[[ funcs ]]-------------------------------------------------------------------

func = dofile("gar5_gsg3_func.lua")

func.get_name = function(id)
    local n = NAMES[id]
    if n then
        return n
    else
        local hash = string.format("0x%08X", id)
        if not hash_unknown[hash] then
            hash_unknown[hash] = true
        end
        return hash
    end
end

func["bool"] = function() wr(1 == r:uint32() and "true" or "false") end
func["int"] = function() wf("%d", r:sint32()) end
func["unsigned int"] = function() wf("%d", r:uint32()) end
func["__int64"] = function() wf("%d", r:sint64()) end

func["class bCGuid"] = function()
    local t = { "\"", r:hex32(1), "-", r:hex16(1), "-", r:hex16(1), "-",
        r:hex16(), "-", r:hex32(), r:hex16(), "\"" }
    wr(table.concat(t))
end

func.get_guid = function()
    return table.concat({ "\"", r:hex32(1), "-", r:hex16(1), "-", r:hex16(1), "-",
        r:hex16(), "-", r:hex32(), r:hex16(), "\"" })
end

func["class bCString"] = function()
    local sz = r:uint16()
    local str = r:str(sz)
    wf("%q", str)
end

func.get_string = function() local sz = r:uint16(); return r:str(sz) end

func["class bCUnicodeString"] = function()
    local sz = r:uint16()
    local str = {}
    while sz > 0 do
        table.insert(str, u.utf16_to_utf8(r:uint16()))
        sz = sz - 1
    end
    wf("%q", table.concat(str))
end

func["class bCDateTime"] = function() wf("%q", u.read_datetime()) end

func.script_proxy = function()
    assert(1 == r:uint16())
    local sz = r:uint16()
    return r:str(sz)
end

func.read_float = function(n, sep)
    if n then
        local t = { [n] = nil }
        for i = 1, n do
            local f = ("%.2f"):format(r:float())
            if sep and i % sep == 0 then f = f .."\n" end
            t[i] = f
        end
        wr("{ " .. table.concat(t, ", ") .. "}")
    else
        wr(r:float())
    end
end

-- cEntity
func["class gCInteraction_PS"] = function(level)
    tab(level); wf("%q, %d,\n", func.get_name(r:uint32()), r:uint32())
    tab(level); wf("%q, %d,\n", func.get_name(r:uint32()), r:uint32())
    tab(level); wf("%d, %d, %d, %d, %d\n", r:uint32(), r:uint32(), r:uint32(), r:uint32(), r:uint32())
end


--[[ array ]]------------------------------------------------------------------

local execute = nil

local function check_func(class, size)
    local e = func[class]
    if e then
        return true
    else
        u.read_unknown_bytes(size, "unknown <" .. class .. ">")
        return false
    end
end


local function write_bTObjArray(class, level, size)
    local start = r:pos()
    local count = r:uint32()
    wf("{ -- num=%d, off=%d\n", count, start)

    if check_func(class, size-4) then
        for i = 1, count do
            tab(level)
            wf("[%d] = ", i)

            execute(class, level+1, size-4)

            wf("%s\n", i<count and "," or "")
        end
    end

    tab(level-1)
    wr("}")
end


--[[ data ]]-------------------------------------------------------------------

execute = function(class, level, size)
    local e = func[class]
    if e then
        e(level, size)
        return
    else
        local c, pos = class:find("class ", 1)
        if 1 == c then
            local a, pos = class:find("bTObjArray<", pos+1)
            if 7 == a then
                local var = class:sub(pos+1, -2)
                write_bTObjArray(var, level+1, size)
                return
            end
        end
    end
    u.read_unknown_bytes(size, "unknown <" .. class .. ">")
end

local function read_class()
    local name = func.get_name(r:uint32())
    local ver = r:uint16()
    local size = r:uint32()

    return name, ver, size
end

local read_eCDynamicEntity
local read_eCEntity

--[[ block1 ]]-----------------------------------------------------------------

local function read_block1()
    r:idstring("GEC2")
    local name = func.get_name(r:uint32())
    local ver = r:uint16()
    local sz = r:uint32()

    local start = r:pos()
    local level = 0

    tab(level); wf("[%q] = { -- v=%d, sz=%d, off=0x%08X\n", name, ver, sz, start)
    level = level + 1

    local count = r:uint16()
    tab(level); wf("prop = { -- num=%d\n", count)
    for i = 1, count do
        local class = func.get_name(r:uint32())
        local var = func.get_name(r:uint32())
        local size = r:uint32()
        tab(level+1); wf("[%q] = ", var)
        execute(class, level+1, size)
        wf("%s -- <%s> sz=%d\n", (i<count and "," or ""), class, size)
    end
    tab(level); wf("}, -- off=0x%08X\n", r:pos())

    count = r:uint32(); assert(0 == count)
    --[[
    tab(level); wf("data = { -- num=%d\n", count)
    for i = 1, count do
        local class = get_name(r:uint32())
        local var = get_name(r:uint32())
        local size = r:uint32()
        tab(level+1); wf("[%q] = ", var)
        execute(class, level, size)
        wf("%s -- <%s> sz=%d\n", (i<count and "," or ""), class, size)
    end
    tab(level);wf("}\n")
    ]]
    level = level - 1

--    u.read_unknown_bytes(sz - r:pos() + start, "block1 data")
    tab(level); wf("} -- <%s>, off=0x%08X\n", name, r:pos())
end


--[[ block2 ]]-----------------------------------------------------------------

local function read_block2()
    local t = {}
    local start1 = r:pos()
    assert(1 == r:uint32())
    t[1] = start1
    t[2] = r:uint32() + start1   -- offset0, jump to t[4]
    t[3] = r:uint32() + start1   -- offset1, at end of file

    local start2 = r:pos()
    assert(1 == r:uint32())
    assert(t[2] == start2)
    t[4] = start2
    t[5] = r:uint32() + start2   -- offset2
    t[6] = r:uint32() + start2   -- offset3
    t[7] = r:uint32() + start2   -- offset4, array of guids
    t[8] = r:uint32()            -- 0
    wr("  offset = { ")
    wr(table.concat(t, ", "))
    wr(" },\n")

    r:seek(t[7])
    wr("  guids = ")
    write_bTObjArray("class bCGuid", 2, 16)
    eol()

    return t
end


--[[ block3 ]]-----------------------------------------------------------------

local function read_block3(offset)   -- 10325951
    r:seek(offset)
    assert(1 == r:uint32())
    local size = r:uint32() -- 390291

    r:seek(offset + size)

    local count = r:uint32() -- 57
    wf("  offset = { -- num=%d\n", count)
    for i = 1, count do
        local hash = r:uint32()
        local name = func.get_name(hash)
        local off = r:uint32() + offset
        wf("    [%d] = { name = %q, off = %d }\n", i, name, off)
    end
    wr("  }\n")

    assert(r:pos() == r:size())
end


--[[ block4 ]]-----------------------------------------------------------------

local function read_block4(offset, start)   -- 10306016
    r:seek(offset)
    local count = r:uint32()
--    wf("  offset = { -- num=%d\n", count)
    local t = {}
    for i = 1, count do
        local sz = r:uint16()
        local name = r:str(sz)
        local off = r:uint32() + start
--        wf("    [%d] = { name = %q, off = %d },\n", i, name, off)
        t[i] = { name, off }
    end
--    wr("  },\n")

    for i = 1, count do
        local name = t[i][1]
        local off = t[i][2]
        wf("  [%q] = { -- %d/%d\n", name, i, count)

        r:seek(off)
        local size = r:uint32()
        local count2 = r:uint32()
        wf("    -- off=%d, size=%d, num=%d\n", off, size, count2)
        for j = 1, count2 do
            wf("      [%d] = { -- of %d\n", j, count2)
            wr("        guid1 = "); func["class bCGuid"](); wr(", -- entity\n")
            wr("        guid2 = "); func["class bCGuid"](); wr(", -- file\n")
            wr("        guid3 = "); func["class bCGuid"](); wr(", -- template\n")
            
            local start = r:pos()
            local code = r:uint32()
            assert(1 == code or 0 == code, "\n\npos=" .. start .. "\n\n")
            local sz = r:uint32()
--            r:seek(start+sz)
            read_eCDynamicEntity(4)
            wr("      },\n")
        end
        wf("  }, -- <%s>\n", name)
    end
end


--[[ block5 ]]-----------------------------------------------------------------

local function read_block5(offset)   -- 10314071
    r:seek(offset)
    local count = r:uint32()
    wf("  -- num=%d\n", count)
    for i = 1, count do
        local sz = r:uint16()
        local name = r:str(sz)
        local bool = r:uint32()
        wf("  [%d] = { val = %d, name = %q },\n", i, bool, name)
    end
end


--[[ parse ]]------------------------------------------------------------------

read_eCEntity = function(level)
    local name = func.get_name(r:uint32())
    r:idstring("GEC2")
    local n, v, sz = read_class()
    
    assert(name == n)
    
    local start = r:pos()
    local code1 = r:uint32()

    assert(code1 >= 0 and code1 <= 2, "\n\ncode1 " .. code1 .. "\n\n")

    local n2, v2, sz2 = read_class()
    local start2 = r:pos()

    tab(level)
    wf("[%q] = { -- v=%d, sz=%d, code1=%d, off=%d\n", name, v, sz, code1, r:pos())

    execute(name, level+1, sz2)

    tab(level); wf("} -- <%s>\n", name)
end


read_eCDynamicEntity = function(level)
    r:idstring("GEC2")
    local n, v, sz = read_class()
    
    assert("class eCDynamicEntity" == n)
    
    local start = r:pos()
    local code1 = r:uint32()

    assert(code1 >= 0 and code1 <= 2, "\n\ncode1 " .. code1 .. "\n\n")


    local n2, v2, sz2 = read_class()
    local start2 = r:pos()
    local code2 = r:uint32()
    
    assert(n == n2)
    assert(v == v2)
    assert(sz - 14 == sz2)

    tab(level)
    wf("[%q] = { -- v=%d, sz=%d, code1=%d, code2=%d\n", n, v, sz, code1, code2)

    if 0 == code2 then
        --
    elseif 1 == code2 then
        tab(level+1); wr("matrix1 = "); func.read_float(16); wr(",\n")
        tab(level+1); wr("matrix1 = "); func.read_float(16); wr(",\n")
        tab(level+1); wr("bb_min = "); func.read_float(3); wr(",\n")
        tab(level+1); wr("bb_max = "); func.read_float(3); wr(",\n")
        tab(level+1); wr("position = "); func.read_float(3); wr(",\n")
        tab(level+1); wr("diameter = "); func.read_float(); wr(",\n")
    else
        assert(false, "\n\ncode2 " .. code2 .. "\n" .. r:pos() .. "\n")
    end

    local u1 = r:hex32()
    local u2 = r:uint16()
    local u3 = r:uint8()

    tab(level+1); wf("--[[ %s %d x%d off=%d ]]\n", u1, u2, u3, r:pos())
    tab(level+1); wr("data = {\n")
    for i = 1, u3 do
        tab(level+2); wf("[%d] = {\n", i)
        
        read_eCEntity(level+3)
        
        tab(level+2); wr("}\n")
    end
    tab(level+1); wr("} -- data\n")
    tab(level); wf("} -- <%s>\n", n)
end


--[[ ]]------------------------------------------------------------------------

local function check_GAR5()
    r:idstring("GAR5")
    r:idstring("\0\0\0\0")
    r:idstring("GSG3")
end

--[[ main ]]-------------------------------------------------------------------

r:open(arg[1], "rb")
check_GAR5()

FILE = assert(io.open(OUT .. ".block1.lua", "w+"))
wr("block1 = {\n")
read_block1()
wr("\n")
FILE:close()

FILE = assert(io.open(OUT .. ".block2.lua", "w+"))
wf("block2 = { -- 0x%08X\n", r:pos())
local off = read_block2()
wr("}\n")
FILE:close()
-- start1=1533, off1=1545, block3_off=10325951,
-- block4_data=1545, block4_off=10306016, block5_off=10314071, block2_off=1565,
-- 0

FILE = assert(io.open(OUT .. ".block3.lua", "w+"))
wf("block3 = { -- 0x%08X\n", r:pos())
read_block3(off[3])
wr("}\n")
FILE:close()

FILE = assert(io.open(OUT .. ".block4.lua", "w+"))
wf("block4 = { -- 0x%08X\n", r:pos())
read_block4(off[5], off[4])
wr("}\n")
FILE:close()

FILE = assert(io.open(OUT .. ".block5.lua", "w+"))
wf("block5 = { -- 0x%08X\n", r:pos())
read_block5(off[6])
wr("}\n")
FILE:close()


--[[
u.dbg_scan_GEC2(get_name)
]]
--[[
r:seek(10306016) -- save1
--r:seek(10281699) -- save3
read_test3(0)
read_test3(0)
]]

--read_test2(0)
--eol(); eol();
--print(r:pos())

r:close()
--show_unknown_hash()
