assert("Lua 5.3" == _VERSION)
assert(arg[1], "\n\n[ERROR] no input file\n\n")
assert(arg[2], "\n\n[ERROR] no language file\n")
assert(arg[3], "\n\n[ERROR] no output file\n")

local LANG = dofile(arg[2])
local OUT = assert(io.open(arg[3], "w+"))

local owr = function(fmt, ...)
    local str = string.format(fmt, ...)
    OUT:write(str)
end

local COFF = 0.01

--[[
lua gar5_parser.lua World_Teleporter.sec
    -> World_Teleporter.sec.lua
    
lua parse_teleports.lua <World_Teleporter.sec.lua> <lang.lua> <teleport.js>
    -> for Leaflet
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

    local pos = cD.bb_mid
    table.remove(pos, 2)
    pos[1] = pos[1] * COFF
    pos[2] = pos[2] * COFF
    
    local id = cE.string1
    local title = l and l["Title"] or "none"
    title = hash(title:lower())
    
    table.insert(pos, "\"" .. id .. "\"")
    table.insert(pos, ("0x%08X"):format(title))
    
    table.insert(teleport, pos)
end


local lang = {}
for k, _ in pairs(used_lang) do
    local str = LANG[k]
    if not str then str = "---" end
    table.insert(lang, {k, str})
end
used_lang = nil
table.sort(lang, function(a, b) return a[1] < b[1] end)

-- lang array
owr("var lang = [];\n")
for i = 1, #lang do
    local l = lang[i]
    owr("lang[0x%08X] = %q;\n", l[1], l[2])
end

owr("\nvar arr_teleport = [\n")
for i = 1, #teleport do
    owr("[ " .. table.concat(teleport[i], ", ") .. " ],\n")
end
owr("];\n")

owr([=[

init_marker.push(
  function () {
    for (var i = 0; i < arr_teleport.length; i++) {
      var m = arr_teleport[i];
      var pop = lang[m[3]] + "<br /><i>" + m[2] + "</i>";
      L.marker( [ m[1], m[0] ], { title: lang[m[3]], icon: icon["teleport"] } )
      .bindPopup(pop).addTo(layer["teleport"]);
    };
    arr_teleport = null;
  }
);
]=])

OUT:close()
