assert("Lua 5.3" == _VERSION)
assert(arg[1], "\n\n[ERROR] no input file\n\n")

--[[
lua gar5_parser.lua *_Items.sec
    -> *.sec.lua
    
lua parse_items.lua item1.lua [item2.lua[ ...]] > items.txt
--]]

local items = {}

for i = 1, #arg do
    dofile(arg[i])

    local t = string.gsub(arg[i], "(.-)([^\\]-[^\\%.]+).sec.lua$", "%2")
    io.stderr:write(t .. "\n")
    local w = _G[t]

    local data = w["class gCEmbeddedLayer"]
    .data["class gCEmbeddedLayer"]["gEEntityType_Game"]["class eCScene"]
    .data["class eCScene"]["class eCDynamicEntity"]
    .data["class eCEntity"].eCEntity2

    for i = 1, #data do
        local d = data[i]["class eCDynamicEntity"].data
        local cD = d["class eCDynamicEntity"]
        local cE = d["class eCEntity"]

        local pos = cD.position
        local id = cE.string1

        if id:find("It_Audiolog_") == 1
        or id:find("It_Pic_") == 1
        or id:find("It_Recipe_") == 1
        or id:find("It_SocketItem_") == 1
        or id:find("It_Wri_") == 1
        then
            table.insert(pos, "\""..id.."\"")
            table.insert(items, pos)
        end
    end
end

table.sort(items, function(a, b) return a[4] < b[4] end)

for i = 1, #items do
    print(table.concat(items[i], ", "))
end
