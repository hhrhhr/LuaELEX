assert("Lua 5.3" == _VERSION)
assert(arg[1], "\n\n[ERROR] no input file\n")
assert(arg[2], "\n\n[ERROR] no output file\n")

local OUT = assert(io.open(arg[2], "w+"))

local COFF = 0.01

local zone = {}
local color = { "orange", "blue", "green", "red" }  -- fire, cold, poison, rad
local opacity = { [5] = 0.4, [10] = 0.4, [20] = 0.3, [40] = 0.2 }
local danger_level = { [5] = 5, [10] = 3, [20] = 2, [40] = 1 }

local function rotate_rectangle(matrix, center, ext)
    local cosa = matrix[1]
    local sina = matrix[2]
    
    local x1 = -ext[1]
    local y1 = ext[2]
    local x2 = ext[1]
    local y2 = -ext[2]
    
    local x1c = x1 * cosa
    local x1s = x1 * sina
    local x2c = x2 * cosa
    local x2s = x2 * sina
    local y1c = y1 * cosa
    local y1s = y1 * sina
    local y2c = y2 * cosa
    local y2s = y2 * sina
    
    local rx1 = center[1] + x1c - y1s
    local ry1 = center[2] + x1s + y1c
    local rx2 = center[1] + x2c - y1s
    local ry2 = center[2] + x2s + y1c
    local rx3 = center[1] + x2c - y2s
    local ry3 = center[2] + x2s + y2c
    local rx4 = center[1] + x1c - y2s
    local ry4 = center[2] + x1s + y2c
    
    return {rx1, ry1, rx2, ry2, rx3, ry3, rx4, ry4}
end

local function hash(str)
    local hash = 5381
    for i = 1, #str do
        hash = (hash * 33 + str:byte(i)) & 0xffffffff
    end
    return hash
end


dofile(arg[1])

local t = string.gsub(arg[1], "(.-)([^\\]-[^\\%.]+).sec.lua$", "%2")
--io.stderr:write(t .. "\n")
local w = _G[t]

local data = w["class gCEmbeddedLayer"]
.data["class gCEmbeddedLayer"]["gEEntityType_Game"]["class eCScene"]
.data["class eCScene"]["class eCDynamicEntity"]
.data["class eCEntity"].eCEntity2

for i = 1, #data do
    local d = data[i]["class eCDynamicEntity"].data
    local cD = d["class eCDynamicEntity"]
    local cE = d["class eCEntity"]
    local eC = cE.eCEntity1[1]["class eCWeatherZone_PS"].prop

    local pos = cD.bb_mid -- XZY, west/east, down/up, south/north
    table.remove(pos, 2)

    local t = { }
    local danger = eC["ZoneDamageMinSecondsSurvival"]
    local kill = eC["ZoneDamageMustKillVictim"]
    if kill then danger = 5 end
    t[3] = danger_level[danger]
    t[5] = "\"" .. color[eC["ZoneDamage"]] .. "\""
    t[6] = opacity[danger]
    
    local shape = eC["Shape"]
    local box = eC["ShapeBox"]["class eCWeatherZoneShapeBox"].prop
    local sphere = eC["ShapeSphere"]["class eCWeatherZoneShapeSphere"].prop
    t[4] = shape
    
    if shape == 0 then
        t[1] = pos[1] * COFF
        t[2] = pos[2] * COFF
        t[7] = sphere["InnerRadius"] * COFF
    
    elseif shape == 1 then
        local m = cD.matrix1
        local matrix = { m[1], m[3] }
        
        local ext = box["InnerExtends"]
        table.remove(ext, 2)
        
        local p = rotate_rectangle(matrix, pos, ext)
        
        t[1] = p[1] * COFF
        t[2] = p[2] * COFF
        t[7] = p[3] * COFF
        t[8] = p[4] * COFF
        t[9] = p[5] * COFF
        t[10] = p[6] * COFF
        t[11] = p[7] * COFF
        t[12] = p[8] * COFF
    else
        assert(false, "\n\nunknown shape: " .. shape)
    end

    table.insert(zone, t)
end

-- zone array
OUT:write("var arr_danger_zone = [\n")
for i = 1, #zone do
    OUT:write("[ " .. table.concat(zone[i], ", ") .. " ],\n")
end

OUT:write("];\n")
OUT:write([[

function add_danger_zone_markers() {
  for (var i = 0; i < arr_danger_zone.length; i++) {
    var m = arr_danger_zone[i];
    var tooltip = ""
    for (var t = 0; t < m[2]; t++)
        tooltip += "<img src='images/skull.png' />";
    var l;
    var stroke = (m[2] > 3) ? true : false;
    if (m[3] == 0) {
      l = L.circle([ m[1], m[0] ],
      { radius: m[6], color: m[4], weight: 1, stroke: stroke, fillOpacity: m[5] })
    } else {
      l = L.polygon( [ [m[1], m[0] ], [ m[7], m[6] ], [ m[9], m[8] ], [ m[11], m[10] ] ],
      { color: m[4], weight: 1, stroke: stroke, fillOpacity: m[5] } );
    };
    l.bindTooltip(tooltip, { sticky: true }).addTo(Zone);
  };
  arr_danger_zone = null;
};

]])

OUT:close()
