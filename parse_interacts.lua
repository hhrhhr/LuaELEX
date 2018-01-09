assert("Lua 5.3" == _VERSION)
local args = #arg
assert(arg[1], "\n\n[ERROR] no input file\n")
assert(arg[args-1], "\n\n[ERROR] no language file\n")
assert(arg[args], "\n\n[ERROR] no output file\n")

local LANG = dofile(arg[args-1])
local OUT = assert(io.open(arg[args], "w+"))

local owr = function(fmt, ...)
    local str = string.format(fmt, ...)
    OUT:write(str)
end

local COFF = 0.01

--[[
lua gar5_parser.lua *_Interacts.sec
    -> *.sec.lua
    
lua parse_interacts.lua <int1.lua> [int2.lua [...] ] <lang.lua> <output.js>
--]]

local orevein = {}
local used_lang = {}

local function hash(str)
    local hash = 5381
    for i = 1, #str do
        hash = (hash * 33 + str:byte(i)) & 0xffffffff
    end
    used_lang[hash] = true
    return hash
end

for i = 1, args-2 do
    dofile(arg[i])

    local class = string.gsub(arg[i], "(.-)([^\\]-[^\\%.]+).sec.lua$", "%2")
    io.stderr:write(class .. "\n")
    local w = _G[class]

    local data = w["class gCEmbeddedLayer"]
    .data["class gCEmbeddedLayer"]["gEEntityType_Game"]["class eCScene"]
    .data["class eCScene"]["class eCDynamicEntity"]
    .data["class eCEntity"].eCEntity2

    for j = 1, #data do
        local d = data[j]["class eCDynamicEntity"].data
        local cD = d["class eCDynamicEntity"]
        local cE = d["class eCEntity"]

        local pos = cD.bb_mid
        local id = cE.string1

        if id:find("Obj_Int_") == 1 then
            if id:find("OreVein_", 9) == 9 then
                local ore
                if id:find("Elex", 17) == 17 then
                    ore = "elex"
                elseif id:find("Gold", 17) == 17 then
                    ore = "gold"
                elseif id:find("Iron", 17) == 17 then
                    ore = "iron"
                elseif id:find("Sulfur", 17) == 17 then
                    ore = "sulfur"
                elseif id:find("Depleted", 17) == 17 then
                    ore = "empty"
                end
                if ore then
                    local t = {}
                    t[1] = ("%.2f"):format(pos[1] * COFF)
                    t[2] = ("%.2f"):format(pos[3] * COFF)
                    t[3] = ("\"%s#%d %s\""):format(class, j, id)
                    local fo = hash(("FO_" .. id):lower())
                    t[4] = ("0x%08X"):format(fo)
                    t[5] = ("\"%s\""):format(ore)

                    table.insert(orevein, t)
                end
            end
        end
    end
end

table.sort(orevein, function(a, b) return a[3] < b[3] end)

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
owr("\n")

-- interacts array
owr("var arr_ore = [\n")
for i = 1, #orevein do
    owr("[ %s ],\n", table.concat(orevein[i], ", "))
end
owr("];\n")

-- funcs
owr([=[

init_marker.push(
  function () {
    for (var i = 0; i < arr_ore.length; i++) {
      var m = arr_ore[i];
      var id = lang[m[3]];
      var pop = "<b>" + id + "</b><br /><i>" + m[2] + "</i>";
      L.marker( [ m[1], m[0] ], { title: id, icon: icon[m[4]] } )
      .bindPopup(pop).addTo(layer["orevein"]);
    };
    arr_ore = null;
  }
);
]=])

OUT:close()
