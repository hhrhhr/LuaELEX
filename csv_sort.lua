local fn = assert(arg[1])

--local ext = string.gsub(fn, ".+w_(%a+)_0.+", ".%1")

local r = assert(io.open(fn))
local head = r:read()
local csv = {}

local line = r:read()
while line do
    for h, n, r, c in string.gmatch(line, "([^|]+)|([^|]+)|([^|]+)|([^|]+)|") do
        table.insert(csv, { h, n, r, c, "" })
    end
    line = r:read()
end
r:close()

table.sort(csv, function(a, b) return a[2] < b[2] end)

print(head)
for i = 1, #csv do
    print(table.concat(csv[i], "|"))
end
