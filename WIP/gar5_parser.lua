assert("Lua 5.3" == _VERSION)
assert(arg[1], "\n\n[ERROR] no input file\n\n")

require("mod_binary_reader")
local r = BinaryReader


--[[ data ]]-------------------------------------------------------------------

local wr = io.write

local tab_level = 0
local function tab(l)
    l = l or tab_level
    wr(("  "):rep(l))
    tab_level = l
end

local NAMES = dofile("hash_names.lua")

local function get_name(id)
    local n = NAMES[id] and NAMES[id][2]
    if not n then
        n = string.format("#0x%08X#", id)
    end
    return n
end

local function read_string()
    local sz = r:uint16()
    wr("\"" .. r:str(sz) .. "\"")
end

local function read_guid()
    local t = {
        r:hex32(1), "-", r:hex16(1), "-", r:hex16(1), "-",
        r:hex16(), "-", r:hex32(), r:hex16()
    }
    wr(table.concat(t))
end

local function read_box()
    for i = 1, 2 do
        wr("\n\t")
        for j = 1, 3 do
            wr(("%10.2f "):format(r:float()))
        end
    end
end

local function read_time()
    local t = r:uint64()
    print(t)
    local u = math.floor(t / 10000000 - 11644473600)
    print(u)
    print(os.date("%Y-%m-%d %H:%M:%S", u))
end



local function read_unknown_bytes(size)
    local pos = r:pos()
    local sz = math.min(size, 64)
    local hex, str = {}, {}

    for i = 1, sz do
        local b = r:uint8()
        table.insert(hex, string.format("%02X", b))
        if b < 32 or b > 126 then b = 46 end
        table.insert(str, string.char(b))
    end

    local i = 1
    while i < sz do
        local j = math.min(i+15, sz)

        io.write(string.format("%08X: ", pos + i - 1))
        io.write(table.concat(hex, " ", i, j))
        local rep = 15 - sz + i
        if rep < 16 then
            io.write(string.rep("   ", rep))
        end
        io.write(" | ")
        io.write(table.concat(str, "", i, j))
        io.write("\n")

        i = i + 16
    end

    if size > 64 then
        wr("... " .. size .. " bytes\n")
    elseif size > 16 then
        wr(size .. " bytes\n")
    end

    -- skip this data
    local jmp = pos + size
    r:seek(jmp)
end

--[[ header ]]---------------------------------------------

local read_FOUR
local read_GEC2


--[[ classes ]]----------------------------------------------------------------

local classes = {}

classes["bool"]         = function() wr(r:uint32() == 1 and "true" or "false") end
classes["float"]        = function() wr(r:float()) end
classes["int"]          = function() wr(r:sint32()) end
classes["unsigned int"] = function() wr(r:uint32()) end

classes["class bCGuid"] = function() read_guid() end
classes["class eCEntityProxy"] = function() read_guid() end
classes["class eCTemplateEntityProxy"] = function() read_guid() end

classes["class bCMatrix"] = function()
    for i = 1, 4 do
        wr("\n\t")
        for j = 1, 4 do
            wr(("%10.2f "):format(r:float()))
        end
    end
end

classes["class bCVector"] = function()
    for j = 1, 3 do
        wr(r:float() .. " ")
    end
end

classes["class bCFloatColor"] = function()
    for j = 1, 3 do
        wr(r:float() .. " ")
    end
end

classes["class bCRange1"] = function()
    for j = 1, 2 do
        wr(r:float() .. " ")
    end
end

classes["class eCScriptProxyScript"] = function()
    assert(1 == r:uint16())
    read_string()
end

classes["class gCScriptProxyAIState"] = function()
    assert(1 == r:uint16())
    read_string()
end

classes["class gCScriptProxyAIFunction"] = function()
    assert(1 == r:uint16())
    read_string()
end

classes["class eCLocString"] = function()
    wr("L#0x" .. r:hex32(1) .. "# ")
    read_string()
end

classes["class eTResourceProxy<class eCCollisionMeshResource2>"] = function()
    read_string()
end

classes["class eTResourceProxy<class eCMeshResource2>"] = function()
    read_string()
end

classes["class eTResourceProxy<class eCMotionNetworkDefResource2>"] = function()
    read_string()
end

classes["class gCEffectProxy"] = function()
    read_string()
end

classes["class bCString"] = function()
    read_string()
end


classes["enum"] = function()
    wr("(" .. get_name(r:uint32()) .. ") ")
    wr(r:uint32())
end


classes["class eCCollisionShapeList"] = function()
    local count = r:uint32()
    for i = 1, count do
        wr("\n")
        read_FOUR(tab_level)
    end
end

classes["dbg5903BEF3"] = function(level)
    wr("\n")
    local count = r:uint32()
    for i = 1, count do
        read_FOUR(level+1)
    end
end


classes["unknown"] = function(size)
    wr("\n")
    read_unknown_bytes(size)
end


--[[ func ]]-------------------------------------------------------------------

local function read_entry(level)
    local class_name = get_name(r:uint32())
    local var_name = get_name(r:uint32())
    local size = r:uint32()

    wr("< " .. class_name .. " > ")
    wr(var_name .. " = ")

    if class_name:find("enum ") == 1 then
        classes["enum"]()
    else
        local c = classes[class_name]
        if c then
            c(level)
        else
            classes["unknown"](size)
        end
    end
    wr("\n")
end


local function read_dynamic1(level)
    local class_name = get_name(r:uint32())
    local ver = r:uint16()
    local size = r:uint32()
    
    tab(level)
    wr("< " .. class_name .. " > ")
    wr("(v" .. ver .. ", ")
    wr(size .. " bytes) ")
    
    local start = r:pos()
    if "class gCEmbeddedLayer" == class_name then
        wr(get_name(r:uint32()) .. " = \n")
        assert(0 == r:uint32())
        read_FOUR(level+1)
    else
        local count = r:uint32()
        wr("[" .. count .. "]\n")
        for i = 1, count do
            read_FOUR(level+1)
        end
    end
    read_unknown_bytes(start + size - r:pos())
end


local function read_eCDynamicEntity(size, level)
    local start = r:pos()
    
    tab(level); wr("matrix1 = "); classes["class bCMatrix"](); wr("\n")
    tab(level); wr("matrix2 = "); classes["class bCMatrix"](); wr("\n")
    tab(level); wr("box1 = "); read_box(); wr("\n")
    tab(level); wr("vector1 = "); classes["class bCVector"](); wr("\n")
    tab(level); wr("float1 = "); classes["float"](); wr("\n")
    tab(level); wr("guid1 = "); read_guid(); wr("\n")

    print("left eCDynamicEntity")
    read_unknown_bytes(start + size - r:pos())

    -- class eCEntity
    class_name = get_name(r:uint32())
    ver = r:uint16()
    size = r:uint32()

    tab(level)
    wr("< " .. class_name .. " > ")
    wr("(v" .. ver .. ", ")
    wr(size .. " bytes)\n")

    start = r:pos()
    tab(level); wr("guid2 = "); read_guid(); wr("\n")
    tab(level); wr("string1 = "); read_string(); wr("\n")

print("left eCEntity")
    read_unknown_bytes(6)

    local count = r:uint8()
print("#class " .. count)
    for i = 1, count do
print("class " .. i .. "/" .. count)
        read_FOUR(level+1)
    end

    count = r:uint32()
print("#dynamic2 " ..count)
    for i = 1, count do
print("dynamic " .. i .. "/" .. count)
        read_FOUR(level+1)
    end

    read_unknown_bytes(start + size - r:pos())
end


local function read_eCAnimation3Controller_PS(size, level)
    local start = r:pos()
    
    tab(level); wr("string1 = "); read_string(); wr("\n")
read_unknown_bytes(6)
    tab(level); wr("string2 = "); read_string(); wr("\n")
    tab(level); wr("string3 = "); read_string(); wr("\n")
read_unknown_bytes(4)
    tab(level); wr("string4 = "); read_string(); wr("\n")
read_unknown_bytes(start + size - r:pos())

    -- eCAnimation3Base_PS
    class_name = get_name(r:uint32())
    ver = r:uint16()
    size = r:uint32()

    tab(level)
    wr("< " .. class_name .. " > ")
    wr("(v" .. ver .. ", ")
    wr(size .. " bytes)\n")
    
    start = r:pos()
read_unknown_bytes(start + size - r:pos())
end



local function read_dynamic2(level)
    local class_hash = r:uint32()
    local ver = r:uint16()
    local size = r:uint32()

    tab(level)
    wr("< " .. get_name(class_hash) .. " > ")
    wr("(v" .. ver .. ", ")
    wr(size .. " bytes)\n")
    
    if class_hash == 0x36182D05 then
        read_eCDynamicEntity(size, level)
    elseif class_hash == 0xD256AADC then
        read_eCAnimation3Controller_PS(size, level)
    else
        --
    end
end


read_GEC2 = function(level)
    tab(level)
print("// prop start " .. r:pos())

    local class_name = get_name(r:uint32())
    local ver = r:uint16()
    local size = r:uint32()
    local start = r:pos()
    local count = r:uint16()

    tab(level)
    wr("< " .. class_name .. " > ")
    wr("(v" .. ver .. ", ")
    wr(size .. " bytes) ")
    wr("[" .. count .. "]\n")

    for i = 1, count do
        tab(level+1)
        wr("[" .. i .. "] = ")
        read_entry(level+1)
    end

    tab(level)
    local pos = r:pos()
    local left = start + size - pos
print("\\\\ prop end " .. pos .. " left " .. left)

    tab(level)
    start = r:pos()
print("// data start " .. start)

    count = r:uint32()
print("#dynamic " .. count)

    if count == 2 then
        read_dynamic2(level+1)
    elseif count == 1 then
        read_dynamic1(level+1)
    elseif count == 0 then
        --
    else
        assert(false, "\n\ndynamic count " .. count .. "\n\n")
    end

    tab(level)
    pos = r:pos()
    left = start + left - pos
print("\\\\ data end " .. pos .. " left " .. left)

end



local function read_GAR5()

end

read_FOUR = function(level)
    local FOUR = r:str(4)
    if "GEC2" == FOUR then
        read_GEC2(level)
    else
        print("!!! unknown FOUR: " .. FOUR)
        assert(false)
    end
end


--[[ main ]]-------------------------------------------------------------------

r:open(arg[1], "rb")

--r:idstring("GAR5")
--r:idstring("\x20\x00\x00\x00")
--r:str(36)

r:seek(44)

r:idstring("GAR5")
r:idstring("\x20\x00\x00\x00")

local count = r:uint16()
for i = 1, count do
    read_string()
    wr(" = { (" .. i .. "/" .. count .. ")\n")
    read_FOUR(1)
    wr("}\n")
end
--r:seek(72)
--r:seek(438)

--print("-> " .. r:seek(2522))
--print("-> " .. r:seek(2228))
--read_FOUR(1)

r:close()
