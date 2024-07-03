-- helper functions

function split_str(s, delimiter)
    result = {}
    for match in (s..delimiter):gmatch('(.-)'..delimiter) do
        table.insert(result, match)
    end
    return result
end

function find_in_table(table, str)
    for key, value in pairs(table) do
        if value == str then
            return key
        end
    end
end
  
fs = filesystem

samplesPath = "D:/Kontakt Development/Osterhouse Sounds/Ripple Cello/Development/Samples wav/"
groups = {"quarters", "eighths", "sixteenths"}

for index, artic in pairs(groups) do
    if index > 1 then
        instrument.groups:add(Group())
    end
    instrument.groups[index-1].name = artic
end 

for _, file in fs.directory(samplesPath) do
    if fs.extension(file) == ".wav" then
        tokens = split_str(fs.stem(file), "_")
        group_index = find_in_table(groups, tokens[1])
        if group_index ~= nil then
            group_index = group_index - 1
            z = Zone()
            instrument.groups[group_index].zones:add(z)
            z.file = file
            z.keyRange.low = tokens[2]
            z.keyRange.high = tokens[2]
            z.rootKey = tokens[2]
            z.velocityRange.low = 64 + tokens[3]
            z.velocityRange.high = 64 + tokens[3]
        end
    end
end