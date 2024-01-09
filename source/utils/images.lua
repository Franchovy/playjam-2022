import "CoreLibs/object"
import "CoreLibs/graphics"
import "engine"
import "extensions"

local gfx <const> = playdate.graphics


local graphics <const> = gfx

function getImageTable(path, count)
	
	local images = {}
	for i=0,count-1 do
		local imagePath = path.."/"..i
		local image = graphics.image.new(imagePath)
		table.insert(images, image)
	end
	
	return images
end

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