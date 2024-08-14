reaper.ClearConsole()

function main()
  typebuf = ""
  initialFolder = reaper.GetExtState("Ripple Cello export selected midi clips folder", 0)
  retval, initialFolder = reaper.JS_Dialog_BrowseForFolder("Choose Folder to save Selected Midi Clips in", initialFolder)
  if retval == 0 then goto exit end
  if initialFolder == "" then goto exit end
  if retval == -1 then reaper.ShowConsoleMsg("error setting save folder") ; goto exit end
  reaper.SetExtState("Ripple Cello export selected midi clips folder", 0, initialFolder, true)

  num_selected_items = reaper.CountSelectedMediaItems(-1)
  
  for i = 0, num_selected_items-1 do
    item = reaper.GetSelectedMediaItem(-1, i)
    cur_take = reaper.GetMediaItemInfo_Value(item, "I_CURTAKE")
    take = reaper.GetTake(item, cur_take)
    take_name = reaper.GetTakeName(take)
    fn = initialFolder .. "/" .. take_name .. ".mid"
    src = reaper.GetMediaItemTake_Source(take)
    typebuf = reaper.GetMediaSourceType(src, typebuf)
    if typebuf ~= "MIDI" then reaper.MB("This only works on midi items.", "wrong item type", 0); goto exit end
    retval = reaper.CF_ExportMediaSource(src, fn)
  end
  ::exit::
end

-- RUN ---------------------
  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  main() -- Execute your main function
  reaper.UpdateArrange() -- Update the arrangement (often needed)

  reaper.Undo_EndBlock("Ripple Cello - Export midi files", -1) -- End of the undo block. Leave it at the bottom of your main function.
