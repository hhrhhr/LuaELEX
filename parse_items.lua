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
lua gar5_parser.lua *_Items.sec
    -> *.sec.lua
    
lua parse_items.lua <item1.lua> [item2.lua [...] ] <lang.lua> <output.js>
--]]

local items = {}
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

        if id:find("It_") == 1 then
            local item
            if id:find("Am_", 4) == 4 then
                item = "amulet"
            elseif id:find("Audiolog_", 4) == 4 then
                item = "audio"
            elseif id:find("Pic_", 4) == 4 then
                item = "picture"
            elseif id:find("Recipe", 4) == 4 then
                item = "recipe"
            elseif id:find("Ri_", 4) == 4 then
                item = "amulet"
            elseif id:find("SocketItem_", 4) == 4 then
                item = "socket"
            elseif id:find("Sun_", 4) == 4 then
                item = "sunglass"
            elseif id:find("Wri_Book", 4) == 4 then
                item = "book"
            elseif id:find("Wri_Letter", 4) == 4 then
                item = "letter"
            end
            
            if item then
                local t = {}
                t[1] = ("%.2f"):format(pos[1] * COFF)
                t[2] = ("%.2f"):format(pos[3] * COFF)
                t[3] = ("\"%s#%d %s\""):format(class, j, id)
                local fo = hash(("FO_" .. id):lower())
                local desc = hash(("ITEMDESC_" .. id):lower())
                t[4] = ("0x%08X"):format(fo)
                t[5] = ("0x%08X"):format(desc)
                t[6] = ("\"%s\""):format(item)

                table.insert(items, t)
            end
        end
    end
end

table.sort(items, function(a, b) return a[3] < b[3] end)

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

-- items array
owr("var arr_item = [\n")
for i = 1, #items do
    owr("[ %s ],\n", table.concat(items[i], ", "))
end
owr("];\n")

-- funcs
owr([=[
    
init_marker.push(
  function () {
    for (var i = 0; i < arr_item.length; i++) {
      var m = arr_item[i];
      var id = lang[m[3]];
      var desc = lang[m[4]];
      var pop = "<b>" + id + "</b><br />" + desc + "<br /><i>" + m[2] + "</i>"
      L.marker( [ m[1], m[0] ], { title: id, icon: icon[m[5]] } )
      .bindPopup(pop).addTo(layer[m[5]]);
    };
    arr_item = null;
  }
);
]=])

OUT:close()
