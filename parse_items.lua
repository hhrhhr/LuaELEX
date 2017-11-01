assert("Lua 5.3" == _VERSION)
assert(arg[1], "\n\n[ERROR] no input file\n")
assert(arg[#arg-1], "\n\n[ERROR] no language file\n")
assert(arg[#arg], "\n\n[ERROR] no output file\n")

local LANG = dofile(arg[#arg-1])
local OUT = assert(io.open(arg[#arg], "w+"))

local COFF = 0.01

--[[
lua gar5_parser.lua *_Items.sec
    -> *.sec.lua
    
lua parse_items.lua item1.lua [item2.lua[ ...] ] <lang.lua> <output.txt>
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

for i = 1, #arg-2 do
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

        local pos = cD.bb_mid
        table.remove(pos, 2)
        pos[1] = pos[1] * COFF
        pos[2] = pos[2] * COFF

        local id = cE.string1

        if id:find("It_") == 1 then
            if id:find("Am_", 4) == 4
            or id:find("Audiolog_", 4) == 4
--            or id:find("It_Blaster_", 4) == 4
--            or id:find("It_Bow_", 4) == 4
--            or id:find("It_Crossbow_", 4) == 4
--            or id:find("It_Flamethrower_", 4) == 4
--            or id:find("It_GrenadeLaucher_", 4) == 4
            or id:find("Pic_", 4) == 4
            or id:find("Recipe", 4) == 4
            or id:find("Ri_", 4) == 4
            or id:find("SocketItem_", 4) == 4
            or id:find("Wri_Book", 4) == 4
            or id:find("Wri_Letter", 4) == 4
--            or id:find("It_1h_", 4) == 4
--            or id:find("It_2h_", 4) == 4
            then
                table.insert(pos, "\""..id.."\"")

                local fo = hash(("FO_" .. id):lower())
                local desc = hash(("ITEMDESC_" .. id):lower())
                table.insert(pos, ("0x%08X"):format(fo))
                table.insert(pos, ("0x%08X"):format(desc))

                table.insert(items, pos)
            end
        end
    end
end

table.sort(items, function(a, b) return a[3] < b[3] end)

local lang = {}
for k, v in pairs(used_lang) do
    table.insert(lang, {k, LANG[k]})
end
used_lang = nil
table.sort(lang, function(a, b) return a[1] < b[1] end)

-- lang array
OUT:write("var lang = [];\n")
for i = 1, #lang do
    local l = lang[i]
    OUT:write(string.format("lang[0x%08X] = %q;\n", l[1], l[2]))
end
OUT:write("\n")

-- items array
for i = 1, #items do
    OUT:write("[ " .. table.concat(items[i], ", ") .. " ],\n")
end
OUT:write("\n")

-- funcs
OUT:write("function add_markers() {\n")

local q = { {"am", "Amulet"}, {"audio", "Audio"}, {"pic", "Picture"}, {"recipe", "Recipe"},
    {"socket", "Socket"}, {"book", "Book"}, {"letter", "Letter"} }
for i = 1, #q do
    OUT:write("    for (var i = 0; i < arr_"..q[i][1]..".length; i++) {\n")
    OUT:write("        var m = arr_"..q[i][1].."[i];\n")
    OUT:write("        var pop = \"<b>\" + lang[m[3]] + \"</b><br />\" + lang[m[4]] + \"<br /><i>\" + m[2] + \"</i>\"\n")
    OUT:write("        L.marker( [ m[1], m[0] ], { title: lang[m[3]], icon: "..q[i][2]:lower().." } )\n")
    OUT:write("        .bindPopup(pop).addTo("..q[i][2]..");\n    };\n")
end

OUT:write("};\n")
OUT:close()
