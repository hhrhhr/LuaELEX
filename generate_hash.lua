assert("Lua 5.3" == _VERSION)

local hash = {}

local function hash_it(fn)
    for line in io.lines(fn) do
        local h = 5381
        for j = 1, #line do
            h = (h * 33 + line:byte(j)) & 0xffffffff
        end
        table.insert(hash, { h, line })
    end
end

--[[
generated from
strings -3 ELEX.exe | grep "^[A-Za-z][0-9a-zA-Z _<>*-]\+$" | LANG=C sort | uniq > strings.txt
--]]
hash_it("strings.txt")

-- manually added strings
hash_it("strings2.txt")

table.sort(hash, function(a, b) return a[1] < b[1] end)

print("local hash = {")
for i = 1, #hash do
    local h = hash[i]
    --print(("[0x%08X] = '%s',"):format(h[1], h[2]))
    print(("[%d] = '%s',"):format(h[1], h[2]))
end
print("}")
print("return hash")
