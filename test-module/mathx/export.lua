local nc = require("../../module/mathx")

print("nc keys:")
for k, v in pairs(nc) do
    if type(v) == "table" then
        print("  " .. k .. " (table)")
        for k2, v2 in pairs(v) do
            print("    " .. k2 .. ": " .. type(v2))
        end
    else
        print("  " .. k .. ": " .. type(v))
    end
end