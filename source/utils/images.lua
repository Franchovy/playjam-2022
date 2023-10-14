

import "CoreLibs/object"
import "CoreLibs/graphics"
import "extensions"

local graphics <const> = playdate.graphics

local imageFolderPath = "images/sprites/"

function getImageTable(name, count)
	local folderPath = imageFolderPath..name
	
	-- TODO: Verify folder exists, folder contents
	
	local images = {}
	for i=0,count-1 do
		local imagePath = folderPath.."/"..name.."_"..i
		local image = graphics.image.new(imagePath)
		table.insert(images, image)
	end
	
	return images
end

-- Note: this would be a good sprite callback property, from (state) -> image.
function getImageForState(imagePath, state)
	local imagePathState = imagePath
	for k, v in pairs(state) do
		if type(v) == "boolean" then
			if v == true then
				imagePathState = imagePathState.."_"..k
			end
		else
			print("Warning: Image for state not configured for any type except boolean.")
		end
	end
	
	return imagePathState
end