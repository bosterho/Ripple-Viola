reaper.ClearConsole()

-- Set selections
reaper.GetSet_LoopTimeRange(true, false, 0, 90, true)
reaper.Main_OnCommand(40717, 0) -- Item: Select all items in current time selection

-- Constants from KSP
LOWEST_KEY = 36
HIGHEST_KEY = 72

articulation_keyswitches   = {29, 31, 33}
speed_keyswitches          = {72+5, 72+7, 72+9, 72+11, 72+12}
direction_keyswitches      = {72+14, 72+16, 72+17}
legato_keyswitches         = {72+19, 72+21, 72+23, 72+24}
release_sample_keyswitches = {72+26, 72+28, 72+29}

-- Helper functions
function find_in_table(table, input)
  for k, v in pairs(table) do
    if v == input then
      return k
    end
  end
end

-- Clear CC103's
cmd = reaper.NamedCommandLookup("_RSc2e075142ee9a60061bae560f3e2c0b9540cdfa0")
reaper.Main_OnCommand(cmd, 0) -- Script: mpl (BO edit)_Remove selected takes MIDI CC103.lua

-- Get strings started
data = "midi_data = [\n"
clip_length_data = 'clip_lengths = ['
lowest_pitches = 'lowest_pitches = ['
highest_pitches = 'highest_pitches = ['
for i = 0, reaper.CountSelectedMediaItems(0) - 1 do
  lowest_pitch = 127
  highest_pitch = 0
  data = data .. '\t[\n'
  item = reaper.GetSelectedMediaItem(0, i)
  take = reaper.GetActiveTake(item)
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
      index = find_in_table(release_sample_keyswitches, pitch)
      if index then
        ks_type = "release_sample"
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
  mf_end_found = false
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
    --[[ --You don't need to retrieve CC's. Just have this script place them, based on item length.
    if msg2 == 103 and mf_end_found == false then
      mf_end_found = true
      clip_length_data = clip_length_data .. math.floor(ppqpos) .. ", "
      --if i == 103 then
        --reaper.ShowConsoleMsg(i .. "    " .. math.floor(ppqpos) .. "\n")
      --end
    end
    ]]--
    cc = cc + 1
  end
  
  -- Get clip length and write it to item
  item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
  len_ticks = math.floor(reaper.TimeMap2_timeToQN(0, item_len) * 960)
  clip_length_data = clip_length_data .. len_ticks .. ", "
  looped = reaper.GetMediaItemInfo_Value(item, "B_LOOPSRC")
  
  reaper.MIDI_InsertCC(take, 
                        false,--boolean selected, 
                        false,--boolean muted, 
                        len_ticks-1,--number ppqpos, 
                        176,--integer chanmsg, 
                        0,--integer chan, 
                        103,--CC num
                        looped * 127) --CC value
  --reaper.UpdateItemInProject(item) -- Not needed I think
  
  data = data .. '\t],\n'
  lowest_pitches = lowest_pitches .. lowest_pitch .. ', '
  highest_pitches = highest_pitches .. highest_pitch .. ', '
end
data = data .. ']\n'
clip_length_data = clip_length_data .. ']\n'
lowest_pitches = lowest_pitches .. ']\n'
highest_pitches = highest_pitches.. ']\n'

data = data .. clip_length_data .. lowest_pitches .. highest_pitches

midi_data_path = reaper.GetProjectPath() .. "/midi_data.js"
midi_data = io.open(midi_data_path, "w")
midi_data:write(data)
midi_data:close()

reaper.Main_OnCommand(40849, 0) -- File: Export project MIDI...
reaper.UpdateArrange()
