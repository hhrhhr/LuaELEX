assert("Lua 5.3" == _VERSION)
assert(arg[1], "\n\n[ERROR] no input file\n")
assert(arg[2], "\n\n[ERROR] no output file\n")

local OUT = assert(io.open(arg[2], "w+"))

local COFF = 0.01

--[[
lua gar5_parser.lua World_MapStreets.sec
    -> *.sec.lua
    
lua parse_streets.lua <World_MapStreets.sec.lua> <street.js>
--]]

local street = {}

dofile(arg[1])

local t = string.gsub(arg[1], "(.-)([^\\]-[^\\%.]+).sec.lua$", "%2")
local w = _G[t]

local data = w["class gCEmbeddedLayer"]
.data["class gCEmbeddedLayer"]["gEEntityType_Game"]["class eCScene"]
.data["class eCScene"]["class eCDynamicEntity"]
.data["class eCEntity"].eCEntity2

for i = 1, #data do
    local d = data[i]["class eCDynamicEntity"].data
    local cD = d["class eCDynamicEntity"]
    local cE = d["class eCEntity"]
    local eC = cE.eCEntity1[1]["0xBD7025AF"]

    local offx = cD.matrix1[15] * COFF
    local offy = cD.matrix1[13] * COFF

    if not eC then goto skip end

    local width = eC.prop["Radius"] // 125 * 2
    eC = eC.data["0xBD7025AF"]

    local t = {}
    t[1] = cE.string1 .. " #" .. i
    t[2] = width

    local p = {}
    for j = 2, #eC-6, 8 do
        table.insert(p, eC[j+2] * COFF + offx)
        table.insert(p, eC[j] * COFF + offy)
    end
    table.insert(t, p)
    table.insert(street, t)
    ::skip::
end


OUT:write("var arr_street = [\n")
for i = 1, #street do
    local st = street[i]
    OUT:write(("[\"%s\",%d,["):format(st[1], st[2]))
    local p = st[3]
    for j = 1, #p, 2 do
        OUT:write(("[%.2f,%.2f],"):format(p[j], p[j+1]))
    end
    OUT:write("]],\n")
end
OUT:write("];\n")

OUT:write([[

function add_streets(){
  for(var i=0;i<arr_street.length;i++){
    var m=arr_street[i];
    L.polyline(m[2],{color:'yellow',weight:m[1],opacity:0.5,interactive:false,smoothFactor:2.0})
    .addTo(Street);
  };
  arr_street=null;
};

]])

OUT:close()
