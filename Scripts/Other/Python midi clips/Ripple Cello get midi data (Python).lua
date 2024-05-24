reaper.ClearConsole()
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
  length = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
  length = reaper.TimeMap_timeToQN(length) * 960
  clip_length_data = clip_length_data .. math.floor(length) .. ", "
  clip_names = clip_names .. '"' ..reaper.GetTakeName(take) .. '", '
  for n = 0, reaper.MIDI_CountEvts(take) - 1 do
    retval, selected, muted, ppqpos, msg = reaper.MIDI_GetEvt(take, n)
    retval, selected, muted, startppqpos, endppoqpos, chan, pitch, vel = reaper.MIDI_GetNote(take, n)
    if pitch < lowest_pitch then lowest_pitch = pitch end
    if pitch > highest_pitch then highest_pitch = pitch end
    data = data .. '\t\t{'
    data = data .. '"pitch":' .. pitch .. ", "
    data = data .. '"vel":' .. vel .. ", "
    data = data .. '"pos":' .. math.floor(startppqpos) .. ", "
    data = data .. '"length":' .. math.floor(endppoqpos - startppqpos) .. ", "
    data = data .. '},\n'
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

midi_data_path = reaper.GetProjectPath() .. "/midi_data.py"
midi_data = io.open(midi_data_path, "w")
midi_data:write(data)
midi_data:close()
