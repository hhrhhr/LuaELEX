assert("Lua 5.3" == _VERSION)
assert(arg[1], "\n\n[ERROR] no input file\n\n")

require("mod_binary_reader")
local r = BinaryReader

--[[ data ]]-------------------------------------------------------------------

local NAMES = {
    [0x7A99504C] = "class gCEmbeddedLayer"
    ,[0x36182D05] = "class eCDynamicEntity"
    ,[0x4BF02D80] = "class eCEntity"
}

local function get_names(id)
    local n = NAMES[id]
    if not n then
        n = string.format("0x%08X", n)
    end
    return n
end

local function get_guid()
    local t = {
        r:hex32(1), "-", r:hex16(1), "-", r:hex16(1), "-", r:hex16(), "-",
        r:hex32(), r:hex16()
    }
    return table.concat(t)
end

local function get_matrix()
    local str = {}
    for i = 1, 4 do
        local t = {}
        for j = 1, 4 do
            table.insert(t, r:float())
        end
        table.insert(str, "\t")
        table.insert(str, table.concat(t, ", "))
        table.insert(str, "\n")
    end
    return table.concat(str)
end

local function get_ebox()
    local str = {}
    for i = 1, 2 do
        local t = {}
        for j = 1, 3 do
            table.insert(t, r:float())
        end
        table.insert(str, "\t")
        table.insert(str, table.concat(t, ", "))
        table.insert(str, "\n")
    end
    return table.concat(str)
end

local function get_vector()
    local t = {}
    for i = 1, 3 do
        table.insert(t, r:float())
    end
    return table.concat(t, ", ")
end


--[[ func ]]-------------------------------------------------------------------

local function dynamic_entity()
    r:idstring("GEC2")
    print(get_names(r:uint32()))    -- eCDynamicEntity
    local q0 = r:uint16(); print(q0)
    local q1 = r:uint32(); print(q1, r:size()-r:pos()-q1) -- pos + size = filesize - 36

    local count = r:uint16()
    -- for 1, count do skip(8); skip(uint32) end

    local q2 = r:uint32(); print(q2)

    print(get_names(r:uint32()))    -- eCDynamicEntity
    local q3 = r:uint16(); print(q3)

    local sz = r:uint32(); print(sz)

    local off1 = r:pos(); print("off1 " .. off1)
    r:seek(off1 + sz)

    print(get_names(r:uint32()))    -- eCEntity
    local q4 = r:uint16(); print(q4)
    local q5 = r:uint32(); print(q5, r:size()-r:pos()-q5) -- pos + size = filesize - 36

    local off2 = r:pos(); print("off2 " .. off2)
    local guid = get_guid(); print("GUID " .. guid)

    sz = r:uint16()
    local name = r:str(sz); print("\"" .. name .. "\"")

    r:seek(off2 - 39)
    guid = get_guid(); print("Creator " .. guid)

    r:seek(off1)
    local matrix = get_matrix(); print("MatrixLocal\n" .. matrix)
    matrix = get_matrix(); print("MatrixGlobal\n" .. matrix)

    local ebox = get_ebox(); print("Extent\n" .. ebox)

    local center = get_vector(); print("Center " .. center)
    local radius = r:float(); print("Radius " .. radius)
    
    r:seek(off2 + 18 + sz)
    

end


local function read_GAR5()
    r:idstring("GAR5")
    local q0 = r:uint32(); print(q0)

    local count = r:uint16(); print(count)
    for i = 1, count do
        local sz = r:uint16(); print(sz)
        local name = r:str(sz); print(name)

        local tmp = r:str(4)
        if tmp == "GEC2" then
            print(get_names(r:uint32()))
            r:seek(r:pos() + 88)

            local count = r:uint32(); print(count)
            for i = 1, count do
                print()
                dynamic_entity()
            end
        else
            print("unknown " .. tmp)
            assert(false)
        end
    end
end


--[[ main ]]-------------------------------------------------------------------

r:open(arg[1], "rb")

r:idstring("GAR5")
local q0 = r:uint32(); print(q0)

r:seek(r:size()-36)
local data_offset = r:uint32(); print("data_offset " .. data_offset)
local data_size = r:uint32(); print("data_size " .. data_size)
local q1 = r:uint8(); print(q1)   -- 0
local q2 = r:uint32(); print(q2, r:size()-q2)
r:str(5) -- 00
local q3 = r:uint32(); print(q3, r:size()-q3)
r:str(5)
local q4 = r:uint32(); print(q4, r:size()-q4)
r:str(5)
-- EOF
r:seek(data_offset)

read_GAR5()

r:close()
