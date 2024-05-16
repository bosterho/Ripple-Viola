k = Kontakt
fs = Filesystem

function split_str(s, delimiter)
	result = {}
	for match in (s..delimiter):gmatch('(.-)'..delimiter) do
		table.insert(result, match)
	end
	return result
end

samplesPath = k.script_path .. "/../../Samples/"

for g = 0, k.get_num_groups(0) - 1 do
    for oct = 0, 2 do
        filename = samplesPath .. k.get_group_name(0, g) .. "_" .. 36 + oct*12
        k.add_zone(0, g, filename)
        k.set_zone_geometry()
        -- add_zone(instrument_idx: integer, group_idx: integer, filename: string) -> integer
    end
end