assert("Lua 5.3" == _VERSION)
assert(arg[1], "\n\n[ERROR] no input file\n\n")

--[[
lua gar5_parser.lua World_Teleporter.sec
    -> World_Teleporter.sec.lua
    
lua parse_teleports.lua World_Teleporter.sec.lua > teleport.js
    -> for LeafJet
--]]

dofile(arg[1])

local w = World_Teleporter

local data = w["class gCEmbeddedLayer"]
    .data["class gCEmbeddedLayer"]["gEEntityType_Game"]["class eCScene"]
    .data["class eCScene"]["class eCDynamicEntity"]
    .data["class eCEntity"]

io.write("var arr = [\n")
for i = 1, #data do
    local d = data[i]["class eCDynamicEntity"].data
    local cD = d["class eCDynamicEntity"]
    local cE = d["class eCEntity"]

    local l = cE[3] and cE[3]["class gCMapLocation_PS"].prop

    local pos = cD.position
    local id = cE.string1
    local title = l and l["Title"] or "none"

    table.insert(pos, "\"" .. id .. "\"")
    table.insert(pos, "\"" .. title .. "\"")

    io.write("[ ")
    io.write(table.concat(pos, ", "))
    io.write(" ],\n")
end
io.write("];\nvar arr_len = " .. #data .. ";\n")
io.write([[

function add_teleport_markers() {
    for (var i = 0; i < arr_len; i++) {
        var m = arr[i];
        L.marker( [ m[0], m[1] ], { title: m[3] } ).addTo(Teleport);
    };    
};

]])
