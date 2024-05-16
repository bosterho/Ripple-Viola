-- helper functions

function split_str(s, delimiter)
result = {}
for match in (s..delimiter):gmatch('(.-)'..delimiter) do
    table.insert(result, match)
end
return result
end
  
fs = Filesystem
k = Kontakt

samplesPath = "D:/Kontakt Development/Osterhouse Sounds/Arpeggios/Recording 2/renders/"
groups = {"quarters", "eighths", "sixteenths"}

for _, artic in pairs(groups) do
    g = k.add_group(0)
    for _, file in fs.directory(samplesPath) do
        if fs.extension(file) == ".wav" and fs.stem(file):find(artic) then
            k.set_group_name(0, g, artic)
            z = k.add_zone(0, g, file)
            tokens = split_str(fs.stem(file), "_")
            key = tonumber(tokens[2])
            interval = tonumber(tokens[3])
            k.set_zone_high_key(0, z, key)
            k.set_zone_low_key(0, z, key-1)
            k.set_zone_root_key(0, z, key)
            k.set_zone_low_velocity(0, z, interval + 64)
            k.set_zone_high_velocity(0, z, interval + 64)
        end
    end
end