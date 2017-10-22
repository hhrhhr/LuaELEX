assert("Lua 5.3" == _VERSION)
assert(arg[1], "\n\n[ERROR] no input file\n\n")

local hash = {}
local i = 0
for line in io.lines(arg[1]) do
    i = i + 1
    local h = 5381
    for j = 1, #line do
        h = (h * 33 + line:byte(j)) & 0xffffffff
    end
    hash[i] = { h, line }
end

table.sort(hash, function(a, b) return a[1] < b[1] end)

print("hash = {")
for i = 1, #hash do
    local h = hash[i]
    print(("[0x%08X] = '%s',"):format(h[1], h[2]))
end
print("}")
print("return hash")
