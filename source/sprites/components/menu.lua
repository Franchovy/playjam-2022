import "engine"

class("Menu").extends(Sprite)

local MARGIN = 25

function Menu:init(textEntries, size)
	self.selectedIndex = 1
	self.entries = textEntries
	self.size = size
	
	self:drawMenu()
	
	self:setCenter(0, 0)
end 

function Menu:setSelectedIndex(i)
	if i < 1 then
		self.selectedIndex = 1
	elseif i > #self.entries then
		self.selectedIndex = #self.entries
	else
		self.selectedIndex = i
	end
	
	self:drawMenu()
end

function Menu:drawMenu()
	local entries = table.imap(self.entries, 
		function (i) 
			if i == self.selectedIndex then
				return "O ".. self.entries[i]
			else 
				return " ".. self.entries[i]
			end
		end
	)
			
	local image = menuImage(entries, self.size)
	self:setImage(image)
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