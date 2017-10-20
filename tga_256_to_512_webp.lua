
local filelist = assert(arg[1])
local output_dir = arg[2] or "."

local map = {}

-- init
for z = 0, 5 do
    local tiles = 2 ^ (z + 1) - 1
    map[z] = {}
    for y = 0, tiles do
        map[z][y] = {}
        for x = 0, tiles do
            map[z][y][x] = false
        end
    end
end

-- parse file list

for l in io.lines(filelist) do
    for z, y, x in string.gmatch(l, "-(%d+)-(%d+)-(%d+).tga") do
        z = tonumber(z)
        y = tonumber(y)
        x = tonumber(x)
        map[z][y][x] = l
    end
end


local magick4 = [[
magick convert ^
( "%s" "%s" +append ) ^
( "%s" "%s" +append ) ^
-append ^
-quality 33 -define webp:lossless=false ^
"%s"
echo %s
]]
local tile = "%s\\elex-%d-%d-%d.webp"
local _404 = "404.webp"

print("@echo off\n")

-- 512
for z = 0, 5 do
    local tiles = 2 ^ (z + 1) - 1
    for y = 0, tiles, 2 do
        for x = 0, tiles, 2 do
            local t1, t2, t3, t4
            t1 = map[z][y+0][x+0]
            t2 = map[z][y+0][x+1]
            t3 = map[z][y+1][x+0]
            t4 = map[z][y+1][x+1]

            if t1 or t2 or t3 or t4 then
                local out = tile:format(output_dir, z, y//2, x//2)
                t1 = t1 or _404
                t2 = t2 or _404
                t3 = t3 or _404
                t4 = t4 or _404
                local cmd = magick4:format(t1, t2, t3, t4, out, out)
                print(cmd)
            end
        end
    end
    print()
end
