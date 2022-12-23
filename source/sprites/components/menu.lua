import "engine"

class("Menu").extends(Sprite)

local MARGIN = 25

function Menu:init(textEntries, size)
	self.selectedIndex = 1
	self.size = size
	
	local image = menuImage(textEntries, size)
	self:setImage(image)
	
	self:setCenter(0, 0)
end 

function getMaxTextWidth(entries)
	local max = 0
	for _, entry in ipairs(entries) do
		local width = gfx.getTextSize(entry)
		if max < width then
			max = width
		end
	end
	return max
end

function menuImage(textEntries, size)
	local _, textHeight = gfx.getTextSize(textEntries[1])
	
	local width, height = getMaxTextWidth(textEntries) * size, textHeight * size * (#textEntries + MARGIN) - MARGIN
	local image = gfx.image.new(width, height)
	
	--
	
	gfx.pushContext(image)
	
	for i, text in pairs(textEntries) do
		-- Draw individual text (scaled)
		local textImage = gfx.image.new(gfx.getTextSize(text))
		
		gfx.pushContext(textImage)
		gfx.drawTextAligned(text, 0, 0, textAlignment.left)
		gfx.popContext()
		
		local y = (textHeight * size + MARGIN) * i
		textImage:scaledImage(size):draw(0, y)
	end
	
	gfx.popContext()
	
	return image
end

-- draw three text entries