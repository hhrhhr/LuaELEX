assert("Lua 5.3" == _VERSION)
assert(arg[1], "\n\n[ERROR] no input file\n\n")
assert(arg[#arg], "\n\n[ERROR] no language file\n")

local LANG = dofile(arg[#arg])

--[[
lua gar5_parser.lua World_Teleporter.sec
    -> World_Teleporter.sec.lua
    
lua parse_teleports.lua World_Teleporter.sec.lua > teleport.js
    -> for LeafJet
--]]

dofile(arg[1])

local function hash(str)
    local hash = 5381
    for i = 1, #str do
        hash = (hash * 33 + str:byte(i)) & 0xffffffff
    end
    return hash
end

local w = World_Teleporter

local data = w["class gCEmbeddedLayer"]
.data["class gCEmbeddedLayer"]["gEEntityType_Game"]["class eCScene"]
.data["class eCScene"]["class eCDynamicEntity"]
.data["class eCEntity"].eCEntity2

io.write("var arr = [\n")
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
    table.insert(pos, string.format("%q", LANG[title] or "---"))

    io.write("[ ")
    io.write(table.concat(pos, ", "))
    io.write(" ],\n")
end
io.write("];\nvar arr_len = " .. #data .. ";\n")
io.write([[

function add_teleport_markers() {
    for (var i = 0; i < arr_len; i++) {
        var m = arr[i];
        var pop = m[4] + "<br /><i>" + m[3] + "</i>";
        L.marker( [ m[0]*0.01, m[1]*0.01 ], { title: m[4], icon: teleport } ).bindPopup(pop).addTo(Teleport);
    };    
};

]])
