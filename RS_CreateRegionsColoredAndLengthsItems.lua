--[[    * LUA ReaScript : Create a region from the lenght of the first to last selected item position, with the color of the  first selected item
		* Description: Select at least one item. The color of the marker will be that of the first item selected in the highest track
		* Author: Yoann Morvan
--]]

reaper.Undo_BeginBlock()

-- quick print function
function consPrint(toPrint)
		reaper.ShowConsoleMsg(tostring(toPrint) .. "\n")
end


--List all start and end position of selected items
function main()

myItemsListStartPoint = {}
myItemsListEndPoint = {}
baseEndPoint = 0
baseFirstPoint = 100000

numberOfItems =  reaper.CountSelectedMediaItems(0)

	if numberOfItems>0 then  --check that at least one item are selected
	
		itemColor = reaper.GetDisplayedMediaItemColor(reaper.GetSelectedMediaItem(0, 0))  -- Get the color of the first item in the first track
		-- r, g, b = reaper.ColorFromNative(itemColor)
	
		for i=0, numberOfItems-1 do --add items to a table
		
			item =  reaper.GetSelectedMediaItem(0, i)
			 		
			itemStart = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
			itemEnd = itemStart + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")

			myItemsListStartPoint[i+1] = itemStart
			myItemsListEndPoint[i+1] = itemEnd
			
		end  --end add items to a table
	
	
		for j=0, numberOfItems-1 do  --check which items ends last
			
			if myItemsListEndPoint[j+1] > baseEndPoint	then
			
				baseEndPoint = myItemsListEndPoint[j+1]
			
			end
			
		end  --end check which items ends last
		
		
		for j=0, numberOfItems-1 do  --check which items starts first
			
			if myItemsListStartPoint[j+1] < baseFirstPoint	then
			
				baseFirstPoint = myItemsListStartPoint[j+1]
			
			end
			
		end  --end check which items starts first
			
		retval, retvals_csv = reaper.GetUserInputs("Name for the region", 1, "Name to give to the region", "" )  -- Get markers name from user
		reaper.AddProjectMarker2(0 , true, baseFirstPoint, baseEndPoint, retvals_csv, 0,itemColor|0x1000000)  --Add Marker with color and name
			
	else
		
		consPrint("No item selected ro create regions!")

	end

--empty tables and reset variables once done

myItemsListEndPoint = nil
myItemsListStartPoint = nil
baseEndPoint = 0
baseFirstPoint = 100000

end

main()

reaper.Undo_EndBlock("Create marker from selected item",0)
