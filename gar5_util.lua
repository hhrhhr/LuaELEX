assert("Lua 5.3" == _VERSION)

GAR5_UTIL = {}

GAR5_UTIL.read_unknown_bytes = function(size, comment)
    if size == 0 then return end

    local MAX = 128
    local start = r:pos()
    local sz = math.min(size, MAX)
    local hex, str = {}, {}

    for _ = 1, sz do
        local b = r:uint8()
        table.insert(hex, string.format("%02X", b))
        if b < 32 or b > 126 then b = 46 end
        table.insert(str, string.char(b))
    end

    wr("--[[ SKIP: " .. (comment or "") .. "\n")
    local i = 1
    while i < sz do
        local j = math.min(i+15, sz)

        wr(string.format("%08X: ", start + i - 1))
        wr(table.concat(hex, " ", i, j))
        local rep = 15 - sz + i
        if rep < 16 then
            wr(string.rep("   ", rep))
        end
        wr(" | ")
        wr(table.concat(str, "", i, j))
        wr("\n")

        i = i + 16
    end

    if size > MAX then
        wr("total " .. size .. " bytes ")
    elseif size > 16 then
        wr(size .. " bytes ")
    end
    wr("]]\n")

    -- skip this data
    r:seek(start + size)
end

local tochar = string.char
GAR5_UTIL.utf16_to_utf8 = function(u16)
    local u8 = {}
    if u16 < 127 then
        u8[1] = tochar(u16 & 255)
    elseif u16 <= 2047 then
        u8[1] = tochar(u16 >> 6 & 31 | 192)
        u8[2] = tochar(u16 & 63 | 128)
    else
        u8[1] = tochar(u16 >> 12 & 15 | 224)
        u8[2] = tochar(u16 >> 6 & 63 | 128)
        u8[3] = tochar(u16 & 63 | 128)
    end
    return table.concat(u8)
end

GAR5_UTIL.read_datetime = function()
    local t = r:uint32() << 32 | r:uint32()
    local u = math.floor(t / 10000000 - 11644473600)
    local str = os.date("%Y-%m-%d %H:%M:%S", u)
    return str
end


GAR5_UTIL.dbg_scan_GEC2 = function(gn)
    local start = r:pos()
    local data = r:str(10306016 - start)
    start = start - 1
    
    wr("\noff;name0;name1;ver1;size1;c1;name2;v2;sz2;c2\n")
    for h0, pos, h1, v1, sz1, c1, h2, v2, sz2, c2 in
    string.gmatch(data, "(....)()GEC2(....)(..)(....)(....)(....)(..)(....)(....)") do
        h0 = string.unpack("<I", h0)
        h1 = string.unpack("<I", h1)
        v1 = string.unpack("<H", v1)
        sz1 = string.unpack("<I", sz1)
        c1 = string.unpack("<I", c1)
        h2 = string.unpack("<I", h2)
        v2 = string.unpack("<H", v2)
        sz2 = string.unpack("<I", sz2)
        c2 = string.unpack("<I", c2)
        
        assert(h1 == h2)
        assert(v1 == v2)
        assert(v1 == v2)

        
        wf("0x%08X;\"%s\";\"%s\";%d;%d;%d;\"%s\";%d;%d;%d\n",
            (start + pos), gn(h0), gn(h1), v1, sz1, c1, gn(h2), v2, sz2, c2)
    end
end
