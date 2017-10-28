assert("Lua 5.3" == _VERSION)
assert(arg[1], "\n\n[ERROR] no input file\n")
assert(arg[#arg], "\n\n[ERROR] no language file\n")

local LANG = dofile(arg[#arg])

--[[
lua gar5_parser.lua *_Items.sec
    -> *.sec.lua
    
lua parse_items.lua item1.lua [item2.lua[ ...] ] > items.txt
--]]

local items = {}

local function hash(str)
    local hash = 5381
    for i = 1, #str do
        hash = (hash * 33 + str:byte(i)) & 0xffffffff
    end
    return hash
end

for i = 1, #arg-1 do
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

        if id:find("It_Am_") == 1
        or id:find("It_Audiolog_") == 1
--        or id:find("It_Blaster_") == 1
--        or id:find("It_Bow_") == 1
--        or id:find("It_Crossbow_") == 1
--        or id:find("It_Flamethrower_") == 1
--        or id:find("It_GrenadeLaucher_") == 1
        or id:find("It_Pic_") == 1
        or id:find("It_Recipe_") == 1
        or id:find("It_Ri_") == 1
        or id:find("It_SocketItem_") == 1
        or id:find("It_Wri_") == 1
--        if id:find("It_1h_") == 1
--        or id:find("It_2h_") == 1
        then
            table.insert(pos, "\""..id.."\"")

            local fo = hash(("FO_" .. id):lower())
            local desc = hash(("ITEMDESC_" .. id):lower())
            
            table.insert(pos, string.format("%q", LANG[fo]))
            table.insert(pos, string.format("%q", LANG[desc]))

            table.insert(items, pos)
        end
    end
end

table.sort(items, function(a, b) return a[4] < b[4] end)

for i = 1, #items do
    print("[ " .. table.concat(items[i], ", ") .. " ],")
end
