--[[ 

Add marker to every beat of the selected item 

LUA script for Reaper 

Author: Yoann Morvan

]]--

reaper.Undo_BeginBlock()

reaper.PreventUIRefresh( 1 )

function round(x)
  return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end

count = 0

if reaper.CountSelectedMediaItems(0) > 0 then

	--get the media end position
	mySong = reaper.GetMediaItem(0, 0)
	mySongStartPosition = reaper.GetMediaItemInfo_Value(mySong, "D_POSITION")
	mySongLength = reaper.GetMediaItemInfo_Value(mySong, "D_LENGTH")
	mySongEndPosition = mySongStartPosition + mySongLength
	reaper.SetEditCurPos(mySongStartPosition, 1, 0)     

		--place marker until cursor is out of item length

		while ( reaper.GetCursorPosition() <= mySongEndPosition ) and ( reaper.GetCursorPosition() >= mySongStartPosition ) do 
		
					-- reaper.Main_OnCommand(40157, 0)
					count = count + 1
		
					beat_in_meas, meas = reaper.TimeMap2_timeToBeats(0, reaper.GetCursorPosition())
									
					myBeat = round(beat_in_meas+1)
					markerName = tostring(meas+1).."."..tostring(myBeat)
					
					reaper.AddProjectMarker(0, false, reaper.GetCursorPosition(), 0, markerName, count)

					closest_beat_in_secs = reaper.TimeMap2_beatsToTime(0, math.floor(beat_in_meas + 0.5), meas)

					if closest_beat_in_secs > reaper.GetCursorPosition() then 

						reaper.SetEditCurPos(reaper.TimeMap2_beatsToTime(0, math.floor(beat_in_meas + 0.5), meas), 1, 0)

					else

						reaper.SetEditCurPos(reaper.TimeMap2_beatsToTime(0, math.floor(beat_in_meas + 0.5) + 1, meas), 1, 0)

					end          

					
	
		end
		
	-- reaper.Main_OnCommandEx(reaper.NamedCommandLookup( "_BR_NORMALIZE_LOUDNESS_ITEMS"), 0, 0)
	-- reaper.Main_OnCommandEx(reaper.NamedCommandLookup( "_BR_ANALAYZE_LOUDNESS_DLG"), 0, 0)

	else 
		
	reaper.ShowConsoleMsg("No item selected!! Too bad.")
	reaper.ShowConsoleMsg("\n")
	
end

reaper.PreventUIRefresh(-1)

reaper.Undo_EndBlock("Add marker to all beats in selected item", -1)
