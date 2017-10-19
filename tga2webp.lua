
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
local _404
for l in io.lines(filelist) do
    if not _404 then
        if string.find(l, "404") then
            _404 = l
        end
    else
        for z, y, x in string.gmatch(l, "Map_(%d+)_(%d+)_(%d+).tga") do
            z = 5 - tonumber(z)
            y = tonumber(y)
            x = tonumber(x)
            map[z][y][x] = l
        end
    end
end


local level = 5

-- map - *.tga dir

local magick4 = [[
magick convert ^
( "%s" "%s" +append ) ^
( "%s" "%s" +append ) ^
-append ^
-quality 66 -define webp:lossless=false ^
"%s"
]]

local magick16 = [[
magick convert ^
( "%s" "%s" "%s" "%s" +append ) ^
( "%s" "%s" "%s" "%s" +append ) ^
( "%s" "%s" "%s" "%s" +append ) ^
( "%s" "%s" "%s" "%s" +append ) -append ^
-quality 66 -define webp:lossless=false ^
"%s"
]]

local tile = "%s\\elex-%d-%d-%d.webp"

print("@echo off\n")

-- 512
for z = 0, level do
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
                local cmd = magick4:format(t1, t2, t3, t4, out)
                print(cmd)
            end
        end
    end
    print()
end

--[[
-- 1024
for z = 1, level do
    local tiles = 2 ^ (z + 1) - 1
    for y = 0, tiles, 4 do
        for x = 0, tiles, 4 do
            local t1, t2, t3, t4, t5, t6, t7, t8
            local r1, r2, r3, r4, r5, r6, r7, r8
            t1 = map[z][y+0][x+0]
            t2 = map[z][y+0][x+1]
            t3 = map[z][y+0][x+2]
            t4 = map[z][y+0][x+3]
            t5 = map[z][y+1][x+0]
            t6 = map[z][y+1][x+1]
            t7 = map[z][y+1][x+2]
            t8 = map[z][y+1][x+3]
            r1 = map[z][y+2][x+0]
            r2 = map[z][y+2][x+1]
            r3 = map[z][y+2][x+2]
            r4 = map[z][y+2][x+3]
            r5 = map[z][y+3][x+0]
            r6 = map[z][y+3][x+1]
            r7 = map[z][y+3][x+2]
            r8 = map[z][y+3][x+3]

            if t1 or t2 or t3 or t4 or t5 or t6 or t7 or t8
            or r1 or r2 or r3 or r4 or r5 or r6 or r7 or r8 then
                local out = tile:format(output_dir, z, y//4, x//4)
                t1 = t1 or _404
                t2 = t2 or _404
                t3 = t3 or _404
                t4 = t4 or _404
                t5 = t5 or _404
                t6 = t6 or _404
                t7 = t7 or _404
                t8 = t8 or _404
                r1 = r1 or _404
                r2 = r2 or _404
                r3 = r3 or _404
                r4 = r4 or _404
                r5 = r5 or _404
                r6 = r6 or _404
                r7 = r7 or _404
                r8 = r8 or _404
                local cmd = magick16:format(t1, t2, t3, t4, t5, t6, t7, t8,
                    r1, r2, r3, r4, r5, r6, r7, r8, out)
                print(cmd)
            end
        end
    end
    print()
end
--]]
