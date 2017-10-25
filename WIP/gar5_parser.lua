assert("Lua 5.3" == _VERSION)
assert(arg[1], "\n\n[ERROR] no input file\n\n")
local DBG = arg[2] or nil

require("mod_binary_reader")
local r = BinaryReader

local ok, NAMES = pcall(dofile, "names_i686.luac")
if not ok then
    NAMES = dofile("names_x64.luac")
end


--[[ header ]]---------------------------------------------

local read_FOUR
local read_GEC2


--[[ data ]]-------------------------------------------------------------------

local wr
if DBG then
    wr = io.write
else
    DBG = assert(io.open(arg[1] .. ".lua", "w+"))
    wr = function(s) DBG:write(s) end
end

local wf = function(fmt, ...)
    wr(string.format(fmt, ...))
end

local eol = function()
    wr("\n")
end


local tab_level = 0
local function tab(l)
    l = l or tab_level
    wr(("  "):rep(l))
    tab_level = l
end

local hash_unknown = {}

local function get_name(id)
    local n = NAMES[id]
    if n then
        return n, true
    else
        local hash = string.format("0x%08X", id)
        if not hash_unknown[hash] then
            hash_unknown[hash] = true
        end
        return hash, false
    end
end


local function read_string(is_not_quoted)
    local sz = r:uint16()
    local str = r:str(sz)
    if 0 == is_not_quoted then
        wr(str)
    else
        wr("\"" .. str .. "\"")
    end
end

local function read_guid()
    local t = {
        "\"",
        r:hex32(1), "-", r:hex16(1), "-",
        r:hex16(1), "-", r:hex16(), "-",
        r:hex32(), r:hex16(),
        "\""
    }
    wr(table.concat(t))
end

local function read_time()
    local t = r:uint64()
    local u = math.floor(t / 10000000 - 11644473600)
    wr(os.date("%Y-%m-%d %H:%M:%S", u))
end

local function read_float(n)
    if n then
        local t = { [n] = nil }
        for i = 1, n do
            t[i] = r:float()
        end
        wr("{ " .. table.concat(t, ", ") .. " }")
    else
        wr(r:float())
    end
end

local function read_enum()
    local val, hash = r:uint32(), r:uint32()
    wf("%d --[[%s]]", hash, get_name(val))
end

local function read_script_proxy(comment)
    local u = r:uint16()
    assert(1 == u, "\n\npos -> " .. r:pos()-2 .. ", var ~= 1 == " .. u)
    local sz = r:uint16()
    wr("\"" .. r:str(sz) .. "\"")
    if comment then wf(" --[[%s]] ", comment) end
end

local function read_class(level)
    local class = get_name(r:uint32())
    local version = r:uint16()
    local size = r:uint32()
    local pos = r:pos()

    tab(level)
    wr(("[\"%s\"] = { -- c v%d, [%d], off 0x%08X\n"):format(class, version, size, pos))

    return class, version, size
end

local function read_array(level, no_block, count)
    if not no_block then wr("{\n") end

    if not count then count = r:uint32() end
    
    for i = 1, count do
        tab(level+1)
        wf("[%d] = { -- of %d, off 0x%08X\n", i, count, r:pos())

        read_FOUR(level+2)

        tab(level+1)
        wf("}%s -- array %d/%d\n", i<count and "," or "", i, count)
    end

    if not no_block then tab(level); wr("}") end
end


local function read_unknown_bytes(size, comment)
    if size == 0 then return end

    local max = 128

    local start = r:pos()
    local sz = math.min(size, 128)
    local hex, str = {}, {}

    for i = 1, sz do
        local b = r:uint8()
        table.insert(hex, string.format("%02X", b))
        if b < 32 or b > 126 then b = 46 end
        table.insert(str, string.char(b))
    end

    wr("--[[ " .. (comment or "") .. "\n")
    local i = 1
    while i < sz do
        local j = math.min(i+15, sz)

        wr(string.format("%08X: ", start + i - 1))
        wr(table.concat(hex, " ", i, j))
        local rep = 15 - sz + i
        if rep < 16 then
            wr(string.rep("   ", rep))
        end
        wr(" | ")
        wr(table.concat(str, "", i, j))
        wr("\n")

        i = i + 16
    end

    if size > max then
        wr("... \n" .. size .. " bytes ")
    elseif size > 16 then
        wr(size .. " bytes ")
    end
    wr("--]]\n")

    -- skip this data
    r:seek(start + size)
end


--[[ hash ]]----------------------------------------------------------------

local hash = {}

hash["bool"]         = function() wr(r:uint32() == 1 and "true" or "false") end
hash["float"]        = function() wr(r:float()) end
hash["int"]          = function() wr(r:sint32()) end
hash["unsigned int"] = function() wr(r:uint32()) end

hash["class bCGuid"]                = function() read_guid() end
hash["class eCEntityProxy"]         = function() read_guid() end
hash["class eCTemplateEntityProxy"] = function() read_guid() end

hash["class bCMatrix"]      = function() read_float(16) end
hash["class bCMotion"]      = function() read_float(7) end
hash["class bCVector"]      = function() read_float(3) end
hash["class bCFloatColor"]  = function() read_float(3) end
hash["class bCRange1"]      = function() read_float(2) end

hash["class eCLocString"] = function()
    local hex = r:hex32(1)
    read_string()
    wf(" --[[0x%s]]", hex)
end

hash["class bCString"] = function() read_string() end
hash["class gCEffectProxy"] = function() read_string() end
hash["class gCStateGraphTransition"] = function() read_string() end

hash["class eCCollisionShapeList"] = function(level) read_array(level) end
hash["class bTSceneRefPropertyArray<class gCStateGraphEventFilter *>"] = function(level) read_array(level) end
hash["class bTSceneRefPtrArray<class gCStateGraphState *>"] = function(level) read_array(level) end

hash["0xBD7025AF"] = function(level, size)
    local start = r:pos()
    local unk1 = r:uint16()
    assert(1 == unk1)
    local unk2 = r:float()
    local count = r:uint32()
    -- 10 bytes
    wf("%10.2f, -- %d*8 + 2*3 floats\n", unk2, count)
    for i = 1, count do
        for j = 1, 8 do
            wf("%10.2f, ", r:float())
        end
        wr("\n")
    end
    for i = 1, 2 do
        for j = 1, 3 do
            wf("%10.2f, ", r:float())
        end
        wr("\n")
    end
end

-- ["Shapes"] ... ["class eCVegModShapeSphere"]
hash["0x889E4D02"] = function(level, size)
    read_array(level)
end

--hash["0xF998E269"] = function(level, size)
--    read_array(level)
--end


--[[ func ]]-------------------------------------------------------------------

local function execute_func(class_name, level, size, not_found_comment)
    local c = hash[class_name]
    if c then
        c(level, size)
    else
        wr("nil\n")
        read_unknown_bytes(size, not_found_comment .. ": " .. class_name)
    end
end


local function read_props(level, count)
    for i = 1, count do
        local class_name, ok = get_name(r:uint32())
        local var_name = get_name(r:uint32())
        local size = r:uint32()

        tab(level)
        wf("[\"%s\"] = ", var_name)

        local not_found_comment
        if ok then
            not_found_comment = "no in hash"
        else
            not_found_comment = "no in names"
        end

        if class_name:find("enum ") == 1 then
            read_enum()
        elseif class_name:find("class bTSceneObjArray") == 1
            or class_name:find("class bTObjArray") == 1 then
            read_array(level)
        elseif class_name:find("class eTResourceProxy") == 1 then
            read_string()
        elseif class_name:find("class eCScriptProxy") == 1 then
            read_script_proxy()
        elseif class_name:find("class gCScriptProxy") == 1 then
            read_script_proxy()
        elseif class_name:find("class gCLetterLocString") == 1 then
            local hash = r:uint32()
            read_string()
            wf(" --[[hash 0x%08X]]", hash)
            
        else
            execute_func(class_name, level, size, "no in hash")
        end

        wf("%s -- <%s> %d/%d\n", i<count and "," or "", class_name, i, count)
    end
end


local function read_dynamic1(level)
    local c = get_name(r:uint32())
    local v = r:uint16()
    local sz = r:uint32()
    local pos = r:pos()

    tab(level)
    wr(("[\"%s\"] = { -- c v%d, [%d], off 0x%08X\n"):format(c, v, sz, pos))

    if "class gCEmbeddedLayer" == c then
        tab(level+1)
        wf("[\"%s\"] = {\n", get_name(r:uint32()))
        assert(0 == r:uint32())
        
        read_FOUR(level+2)
        
        tab(level+1)
        wr("} -- gCEmbeddedLayer\n")

    elseif "class eCScene" == c then
        tab(level)
        local unk1 = r:uint32()
        io.stderr:write("-- eCScene val ??? " .. unk1 .. " ???\n")
        wf("-- ??? %d ???\n", unk1)
        read_FOUR(level+1)

    elseif "class gCNavigation_PS" == c then
        read_array(level, true)

    elseif "class gCRoutine" == c then
        read_array(level, true)

    elseif "0xBD7025AF" == c then
        hash[c]()

    elseif "class gCItem_PS" == c then
        tab(level+1)
        wf("[\"%s\"] = ", get_name(r:uint32()))
        assert(0 == r:uint32())
        wr(r:uint32())
        wr("\n")
        
    elseif "class gCInventory_PS" == c then
--        local unk1 = r:uint32()
--        local count = r:uint16()
--        local unk2 = r:uint16()
--        print("gCInventory_PS", unk1, count, unk2)
--        if unk > 0 then
--            read_array(level, true, count)
--        end
        read_array(level, true)
        local count = r:uint16()
        local unk1 = r:uint8()
        local unk2 = r:uint8()
--print("gCInventory_PS", count, unk1, unk2)
        if unk2 > 0 then
            read_array(level, true, count)
        end
--        read_unknown_bytes(4)
--        assert(0 == r:uint32())

    elseif "class gCParty_PS" == c then
--        read_unknown_bytes(6)
        wr("--[[\n")
        wr("string1 = "); read_string(); eol()
        wr("int1 = " .. r:uint32() .. "\n")
        wr("guid1 = "); read_guid(); eol()
        wr("--]]\n")
    
    elseif "class eCPrefabMesh" == c then
        tab(level+1)
        read_float(16)
        eol()
        
    elseif "class gCStateGraphState" == c then
        read_unknown_bytes(16)
        wr("arr1 = {\n")
        read_array(level, true)
        wr("},\narr2 = {\n")
        read_array(level, true) -- TODO: check this
        wr("}\n")
        
    elseif "class gCStateGraphTransition" == c then
        read_string()
        eol()
        
    else
        read_unknown_bytes(sz, "unknown < " .. c .. " >")
    end

    tab(level)
    wf("} -- <%s>, off 0x%08X \n", c, r:pos())
end


local function read_eCEntity(level)
    local c, v, sz = read_class(level)
    -- wrote "{..."

    local start = r:pos()
    level = level + 1

    tab(level); wr("guid2 = "); read_guid(); wr(",\n")
    tab(level); wr("string1 = "); read_string(); wr(",\n")
    read_unknown_bytes(6, "eCEntity")

    local count = r:uint8()
    for i = 1, count do
        tab(level)
        wr("-- //eCEntity1\n")
        tab(level)
        wf("[%d] = { -- eCE d1 of %d, off 0x%08X\n", i, count, r:pos())

        read_FOUR(level+1)

        tab(level)
        wf("}, -- eCE d1 %d/%d\n", i, count)
        tab(level)
        wr("-- \\\\eCEntity1\n")
    end

    count = r:uint32()
    for i = 1, count do
        tab(level)
        wr("eCEntity2 = {\n")
        tab(level)
        wf("[%d] = { -- eCE d2 of %d\n", i, count)

        read_FOUR(level+1)

        tab(level)
        wf("}%s -- eCE d2 %d/%d\n", i<count and "," or "", i, count)
        
        tab(level)
        wr("}, -- eCEntity2\n")
    end

    read_unknown_bytes(start + sz - r:pos(), "eCEntity left")

    level = level - 1
    tab(level)
    wr("} -- eCEntity\n")
end



local function read_eCDynamicEntity(size, level, class_name, version)
    local start = r:pos()

    tab(level)
    wf("[\"%s\"] = { -- v%d, [%d], off 0x%08X\n", class_name, version, size, start)

    level = level + 1
    tab(level); wr("matrix1 = "); read_float(16); wr(",\n")
    tab(level); wr("matrix2 = "); read_float(16); wr(",\n")
    tab(level); wr("box1 = "); read_float(2); wr(",\n")
    tab(level); wr("position = "); read_float(3); wr(", -- ???\n")
    tab(level); wr("floats = "); read_float(5); wr(",\n")
    tab(level); wr("guid1 = "); read_guid(); wr(",\n")
    read_unknown_bytes(start + size - r:pos(), "eCDynamicEntity")

    level = level - 1
    tab(level)
    wf("}, -- <%s>\n", class_name)

    read_eCEntity(level)
end


local function read_eCAnimation3Controller_PS(size, level)
    local start = r:pos()

    tab(level); wr("string1 = "); read_string(); wr(",\n")
    read_unknown_bytes(6)
    tab(level); wr("string2 = "); read_string(); wr(",\n")
    tab(level); wr("string3 = "); read_string(); wr(",\n")
    read_unknown_bytes(4)
    tab(level); wr("string4 = "); read_string(); wr(",\n")
    read_unknown_bytes(6)
    tab(level); wr("string5 = "); read_string(); wr(",\n")
    read_unknown_bytes(start + size - r:pos())

    -- eCAnimation3Base_PS
    local c, v, sz = read_class()
    read_unknown_bytes(sz)
    tab(level)
    wr("}\n")
end


local function read_eCTemplateEntity(size, level)
    tab(level)
    wf("[\"class eCTemplateEntity\"] = { -- [%d], off 0x%08X\n", size, r:pos())

    read_unknown_bytes(size)

    tab(level)
    wr("}, -- <class eCTemplateEntity>\n")

    read_eCEntity(level, size)
end


local function read_dynamic2(level)
    local class_hash = r:uint32()
    local class_name = get_name(class_hash)
    local version = r:uint16()
    local size = r:uint32()

    if class_hash == 0x36182D05 then
        read_eCDynamicEntity(size, level+1, class_name, version)

    elseif class_hash == 0xD256AADC then
        read_eCAnimation3Controller_PS(size, level+1)

    elseif class_hash == 0x60DE515C then
        read_eCTemplateEntity(size, level+1)

    else
        read_unknown_bytes(size)
    end
end


read_GEC2 = function(level)
    local c, v, sz = read_class(level)
    local start = r:pos()

    local count = r:uint16()

    level = level+1

    tab(level)
    wf("prop = { -- off 0x%08X, %d entries\n", start, count)
    read_props(level+1, count)

    local pos = r:pos()
    local readed = pos - start
    local left = start + sz - pos

    tab(level)
    wf("}, -- prop end <%s>, %d <- %d bytes\n", c, readed, left)

    pos = r:pos()
    local code = r:uint32()

    tab(level)
    wf("data = { -- off 0x%08X, :%d:\n", pos, code)

    if code == 2 then
        read_dynamic2(level)
    elseif code == 1 then
        read_dynamic1(level+1)
    elseif code == 0 then
        --
    else
        assert(false, "\n\ncode " .. code .. "\n\n")
    end

    tab(level)
    wf("} -- data <%s>\n", c)

    level = level-1

    pos = r:pos()
    readed = pos - start
    left = start + sz - pos

    tab(level)
    wf("} -- <%s>, off 0x%08X, %d <- %d bytes\n", c, pos, readed, left)
    
    assert(0 == left, "\n\n\n\n")
end


read_FOUR = function(level)
    local FOUR = r:str(4)
    if "GEC2" == FOUR then
        read_GEC2(level)
    else
        print("\n!!! unknown FOUR: " .. FOUR .. "\n\n")
        assert(false)
    end
end


local function read_GSG3()
    r:idstring("GAR5")
end


local function read_GAR5()
    r:idstring("GAR5")
    r:idstring("\x20\x00\x00\x00")
    r:seek(44)
    r:idstring("GAR5")
    r:idstring("\x20\x00\x00\x00")

    if "GTP0" == r:str(4) then
        wr("template = {\n")
        read_unknown_bytes(8)
        read_FOUR(0)
        wr("}\n")
        eol()
    else
        r:seek(r:pos() - 4)
        local count = r:uint16()
        for i = 1, count do
            read_string(0)
            wf(" = { -- %d/%d entries\n", i, count)
            read_FOUR(0)
            wf("}%s\n", i<count and "," or "")
        end
        eol()
    end
end


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


--[[ main ]]-------------------------------------------------------------------

r:open(arg[1], "rb")
read_GAR5()
--read_GTP0()
r:close()

if not DBG then
    DBG:close()
end

show_unknown_hash()
