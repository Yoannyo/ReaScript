--[[    * LUA ReaScript : Copy an item with the markers included during the length of this item
		* Author: Yoann Morvan
--]]

-- quick print function
function consPrint(toPrint)
		reaper.ShowConsoleMsg(tostring(toPrint) .. "\n")
end

reaper.Undo_BeginBlock()

itemEndList = {}
itemStartList = {}


markersToCopy = {}
numberOfMarkerInItem = 0
markerPositionToCursor = {}
markerColorList = {}
markerNameList = {}

earliestItem = 10000000
latestItem = 0


function CopyWithMarkers()    -- Find first and las item position

		reaper.Main_OnCommand(40057, 0)
		
		for i=0, reaper.CountSelectedMediaItems(0)-1 do 
			myItem = reaper.GetSelectedMediaItem(0,i)  
			itemStartList[i+1] = reaper.GetMediaItemInfo_Value(myItem, "D_POSITION")
			itemEndList[i+1] = itemStartList[i+1] + reaper.GetMediaItemInfo_Value(myItem, "D_LENGTH")		
		end
		
		
		for i=0, #itemStartList-1 do
			x = itemStartList[i+1]
			if x<earliestItem then
			earliestItem =x
			end
		end
		
		for i=0, #itemEndList-1 do
			x = itemEndList[i+1]
			if x>latestItem then
			latestItem =x
			end
		end

	reaper.SetEditCurPos(earliestItem, true, true)
end
	
	
	
function GoThroughMarkers()  --  Keep only markers between first and last selected items

	allMarkers, num_markers, num_regions = reaper.CountProjectMarkers(0) 

	for h=0, allMarkers-1 do
		
		retval, isrgn, positionMarker, rgnend, nameMarker, markrgnindexnumber, markerColor = reaper.EnumProjectMarkers3(0, h)  -- check if the marker is a region or a marker
								
		if  isrgn == false then   -- if it is a marker and not a region, stock marker position in table
				
			if positionMarker>=earliestItem and positionMarker<=latestItem then
				numberOfMarkerInItem = numberOfMarkerInItem + 1
				markersToCopy[numberOfMarkerInItem] = positionMarker 
				markerColorList[numberOfMarkerInItem] = markerColor	
				markerNameList[numberOfMarkerInItem] = nameMarker
				markerPositionToCursor[numberOfMarkerInItem] = latestItem - markersToCopy[numberOfMarkerInItem] 
			end		
		end 
	end			
end



function PasteWithMarker()  -- Paste with markers 

	reaper.Main_OnCommand(40058, 1)

	for h=0, numberOfMarkerInItem-1 do
		pastedMarkerPosition =  reaper.GetCursorPositionEx(0) - markerPositionToCursor[h+1]
		reaper.AddProjectMarker2(0, false, pastedMarkerPosition, 8, markerNameList[h+1], 0, markerColorList[h+1])
	end

	reaper.atexit(guiWindow)
	gfx.quit()
end


function guiWindow()  -- GUI window management

	char = gfx.getchar()
	
		if char ~= -1 then
			reaper.defer(guiWindow)
		end
	
	-- Paste button
	my_str = "Paste Item With Markers"
	x, y = 90, 20
	w, h = 100, 40
	r = 10
	gfx.roundrect(x-85, y-17, w+170, h, r, 1, 0)
	gfx.setfont(1, "Arial", 26)
	str_w, str_h = gfx.measurestr(my_str)
	gfx.x = x + ((w - str_w) / 2)
	gfx.y = y + ((h - str_h) / 2) - 17
	gfx.drawstr(my_str)
	
	--Is button clicked ? 
	if gfx.mouse_cap & 1 == 1 then	-- If the left button is down
		-- If the cursor is inside the rectangle AND the button wasn't down when entering the button
		if IsInside(x, y, w, h) and not mouse_btn_down then
			mouse_btn_down = true
			PasteWithMarker()
		end

	
	else  -- If the left button is up 
		mouse_btn_down = false
	end
	
	gfx.update()
end

--get cursor coordinates and return if mouse cursor is inside button area
function IsInside(x, y, w, h)
	
	mouse_x, mouse_y = gfx.mouse_x, gfx.mouse_y
	
	inside = 
		mouse_x >= x-300 and mouse_x < (x+400 + w) and 
		mouse_y >= y-100 and mouse_y < (y+100 + h)	
	return inside

end

gfx.init("Paste copied item with markers", 280, 55, 0, 1610, 890)


--  MAIN FUNCTION TRIGGER 
if  reaper.CountSelectedMediaItems(0)>=1 then 
	guiWindow()
	CopyWithMarkers()
	GoThroughMarkers()	
else
	consPrint("Select at least one item ! Please.")
end 

reaper.Undo_EndBlock( "Copy/Paste item with markers", 0)