local str = arg[1]

local function hash(str)
    local hash = 5381
    for i = 1, #str do
        hash = (hash * 33 + str:byte(i)) & 0xffffffff
    end
    print(("%10d 0x%08X \"%s\""):format(hash, hash, str))
end

hash(str)
hash(str:lower())
