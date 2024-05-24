reaper.ClearConsole()
-- Constants from KSP
LOWEST_KEY = 36
HIGHEST_KEY = 72

articulation_keyswitches = {29, 31, 33}
speed_keyswitches        = {72+5, 72+7, 72+9, 72+11, 72+12}
direction_keyswitches    = {72+14, 72+16, 72+17}
legato_keyswitches       = {72+19, 72+21, 72+23, 72+24}

-- Helper functions
function find_in_table(table, input)
  for k, v in pairs(table) do
    if v == input then
      return k
    end
  end
end


-- Get strings started
data = "midi_data = [\n"
clip_length_data = 'clip_lengths = ['
clip_names = 'clip_names = ['
lowest_pitches = 'lowest_pitches = ['
highest_pitches = 'highest_pitches = ['
for i = 0, reaper.CountSelectedMediaItems(0) - 1 do
  lowest_pitch = 127
  highest_pitch = 0
  data = data .. '\t[\n'
  item = reaper.GetSelectedMediaItem(0, i)
  take = reaper.GetActiveTake(item)
  clip_names = clip_names .. '"' ..reaper.GetTakeName(take) .. '", '
  n = 0
  while reaper.MIDI_GetNote(take, n) do
    retval, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote(take, n)
    if pitch >= LOWEST_KEY and pitch <= HIGHEST_KEY then
      if pitch < lowest_pitch then lowest_pitch = pitch end
      if pitch > highest_pitch then highest_pitch = pitch end
      data = data .. '\t\t{'
      data = data .. '"command": "note"' .. ", "
      data = data .. '"pitch":' .. pitch .. ", "
      data = data .. '"vel":' .. vel .. ", "
      data = data .. '"pos":' .. math.floor(startppqpos) .. ", "
      data = data .. '"length":' .. math.floor(endppqpos - startppqpos) .. ", "
      data = data .. '"chan":' .. chan .. ", "
      data = data .. '},\n'
    else
      index = find_in_table(articulation_keyswitches, pitch)
      if index then
        ks_type = "articulation"
        ks_index = index
      end
      index = find_in_table(speed_keyswitches, pitch)
      if index then
        ks_type = "speed"
        ks_index = index
      end
      index = find_in_table(direction_keyswitches, pitch)
      if index then
        ks_type = "direction"
        ks_index = index
      end
      index = find_in_table(legato_keyswitches, pitch)
      if index then
        ks_type = "legato"
        ks_index = index
      end
      if ks_index then
        data = data .. '\t\t{'
        data = data .. '"command": "keyswitch"' .. ", "
        data = data .. '"ks_type": "' .. ks_type .. '", '
        data = data .. '"pos":' .. math.floor(startppqpos) .. ", "
        data = data .. '"index":' .. ks_index - 1
        data = data .. '},\n'
      end
    end
    n = n + 1
  end
  
  cc = 0
  while reaper.MIDI_GetCC(take, cc) do
    retval, selected, muted, ppqpos, chanmsg, chan, msg2, msg3 = reaper.MIDI_GetCC(take, cc)
    if msg2 == 64 then
      if msg3 > 0 then msg3 = 127 else msg3 = 0 end
      data = data .. '\t\t{'
      data = data .. '"command": "pedal"' .. ", "
      data = data .. '"value":' .. msg3 .. ", "
      data = data .. '"pos":' .. math.floor(ppqpos) .. ", "
      data = data .. '"chan":' .. chan .. ", "
      data = data .. '},\n'
    end
    if msg2 == 103 then
      clip_length_data = clip_length_data .. math.floor(ppqpos) .. ", "
    end
    cc = cc + 1
  end
  
  data = data .. '\t],\n'
  lowest_pitches = lowest_pitches .. lowest_pitch .. ', '
  highest_pitches = highest_pitches .. highest_pitch .. ', '
end
data = data .. ']\n'
clip_length_data = clip_length_data .. ']\n'
clip_names = clip_names .. ']\n'
lowest_pitches = lowest_pitches .. ']\n'
highest_pitches = highest_pitches.. ']\n'

data = data .. clip_length_data .. clip_names .. lowest_pitches .. highest_pitches

midi_data_path = reaper.GetProjectPath() .. "/midi_data.js"
midi_data = io.open(midi_data_path, "w")
midi_data:write(data)
midi_data:close()
