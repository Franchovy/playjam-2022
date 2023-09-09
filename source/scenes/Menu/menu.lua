import "engine"

local <const> MARGIN = 19
local <const> SIZE = 1.8

class("Menu").extends(Sprite)

function Menu.new(options)
	return Menu(options)
end

function Menu:init(options)
	Menu.super.init(self)
	
	self.options = options
	
	-- Load Sound Effects
	
	sampleplayer:addSample("menu-select", "sfx/menu-select")
	sampleplayer:addSample("menu-select-fail", "sfx/menu-select-fail")
	
	-- Menu index
	
	self.currentMenu = {}
	self.index = 1
end

function Menu:activate() 
	self.entries = {"test1", "test2", "test3"}
	
	self:setImage(getMenuImage()) -- TODO: Feed in current menu
	
	self:setCenter(0, 0)
	self:moveTo(160, 0)
end

function Menu:update()
	-- TODO: Menu navigation
end

function SpriteMenu:selectIndex(i)	 -- TODO: Move into index methods
	if i < 1 then
		self.selectedIndex = 1
	elseif i > #self.entries then
		self.selectedIndex = #self.entries
	else
		self.selectedIndex = i
	end
	
	self:drawMenu()
	
	return self.selectedIndex
end

function Menu:indexDecrement()
	
end

function Menu:indexIncrement()
	
end

function Menu:indexSelect()
	
end

function Menu:indexReturn()
	
end

function playSample(isFail) 
	if not isFail then
		sampleplayer:playSample("menu-select")
	else 
		sampleplayer:playSample("menu-select-fail")
	end
end

function getMenuImage(entries, index)
	
	-- Create Menu Image using entries

	local _, textHeight = gfx.getTextSize(entries[1])
	local width = getMaxTextWidth(entries) * SIZE
	local height = textHeight * SIZE * (#entries + MARGIN) - MARGIN
	local menuImage = gfx.image.new(width, height)
	
	-- Create images for entries
	
	local entryImages = {}
	for _, entry in pairs(entries) do
		local itemImage = getMenuItemImage(text)
		table.insert(entryImages, itemImage)
	end
		
	-- Draw entry images on menu
			
	gfx.pushContext(menuImage)
	
	for i, imageEntry in pairs(entryImages) do
		-- Draw individual text (scaled)
		local y = (textHeight * SIZE + MARGIN) * i
		imageEntry:scaledImage(SIZE):draw(0, y)
	end
	
	gfx.popContext()
			
	return menuImage
end

function getMenuItemImage(text, isSelected)
	local textSizeWidth, textSizeHeight = gfx.getTextSize(text)
	local textImage = gfx.image.new(textSizeWidth, textSizeHeight)
	local textSpacingX = isSelected and 30 or 0
	
	gfx.pushContext(textImage)
	if isSelected then
		gfx.drawTriangle(0, 0, 20, textSizeHeight / 2, 0, textSizeHeight)
	end
	gfx.drawTextAligned(text, textSpacingX, 0, textAlignment.left)
	gfx.popContext()
	
	return textImage
end

-- TODO: replace with function max(table, callback)
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