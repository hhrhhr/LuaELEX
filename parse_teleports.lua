assert("Lua 5.3" == _VERSION)
assert(arg[1], "\n\n[ERROR] no input file\n\n")
assert(arg[#arg-1], "\n\n[ERROR] no language file\n")
assert(arg[#arg], "\n\n[ERROR] no output file\n")

local LANG = dofile(arg[#arg-1])
local OUT = assert(io.open(arg[#arg], "w+"))

--[[
lua gar5_parser.lua World_Teleporter.sec
    -> World_Teleporter.sec.lua
    
lua parse_teleports.lua World_Teleporter.sec.lua > teleport.js
    -> for LeafJet
--]]

local teleport = {}
local used_lang = {}

local function hash(str)
    local hash = 5381
    for i = 1, #str do
        hash = (hash * 33 + str:byte(i)) & 0xffffffff
    end
    used_lang[hash] = true
    return hash
end

dofile(arg[1])
local w = World_Teleporter

local data = w["class gCEmbeddedLayer"]
.data["class gCEmbeddedLayer"]["gEEntityType_Game"]["class eCScene"]
.data["class eCScene"]["class eCDynamicEntity"]
.data["class eCEntity"].eCEntity2

for i = 1, #data do
    local d = data[i]["class eCDynamicEntity"].data
    local cD = d["class eCDynamicEntity"]
    local cE = d["class eCEntity"]

    local l = cE.eCEntity1[3] and cE.eCEntity1[3]["class gCMapLocation_PS"].prop

    local pos = cD.position
    local id = cE.string1
    local title = l and l["Title"] or "none"
    title = hash(title:lower())
    
    table.insert(pos, "\"" .. id .. "\"")
    table.insert(pos, ("0x%08X"):format(title))
    
    table.insert(teleport, pos)
end


local lang = {}
for k, v in pairs(used_lang) do
    table.insert(lang, {k, LANG[k] or "---"})
end
used_lang = nil
table.sort(lang, function(a, b) return a[1] < b[1] end)

-- lang array
OUT:write("var lang = [];\n")
for i = 1, #lang do
    local l = lang[i]
    OUT:write(string.format("lang[0x%08X] = %q;\n", l[1], l[2]))
end

OUT:write("\nvar arr_teleport = [\n")

for i = 1, #teleport do
    OUT:write("[ " .. table.concat(teleport[i], ", ") .. " ],\n")
end

OUT:write("];\n")
OUT:write([=[

function add_teleport_markers() {
    for (var i = 0; i < arr_teleport.length; i++) {
        var m = arr_teleport[i];
        var pop = lang[m[4]] + "<br /><i>" + m[3] + "</i>";
        L.marker( [ m[0]*0.01, m[1]*0.01 ], { title: lang[m[4]], icon: teleport } ).bindPopup(pop).addTo(Teleport);
    };
};

]=])

OUT:close()
