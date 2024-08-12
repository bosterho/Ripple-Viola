reaper.ClearConsole()

-- Set selections
reaper.GetSet_LoopTimeRange(true, false, 0, 90, true)
reaper.Main_OnCommand(40717, 0) -- Item: Select all items in current time selection

name = ""

-- Get string started
nka_str = "!clip_names\n"
for i = 0, reaper.CountSelectedMediaItems(0) - 1 do
  item = reaper.GetSelectedMediaItem(0, i)
  take = reaper.GetActiveTake(item)
  _, name = reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", name, false)
  nka_str = nka_str .. name .. "\n"
  
end

--reaper.ShowConsoleMsg(nka_str)
nka_path = reaper.GetProjectPath() .. "/../../../../Resources/data/clip_names.nka"
nka_file = io.open(nka_path, "w")
nka_file:write(nka_str)
nka_file:close()

