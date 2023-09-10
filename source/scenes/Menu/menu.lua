import "engine"

local MARGIN <const> = 19
local SIZE <const> = 1.8

local sampleSelect = "menu-select"
local sampleSelectFail = "menu-select-fail"

class("Menu").extends(Sprite)

function Menu.new(options)
	return Menu(options)
end

function Menu:init(options)
	Menu.super.init(self)
	
	self.options = options
	
	-- Load Sound Effects
	
	sampleplayer:addSample(sampleSelect, "sfx/menu-select")
	sampleplayer:addSample(sampleSelectFail, "sfx/menu-select-fail")
	
	-- Menu index
	
	self.currentMenuIndex = {}
	self.selectedIndex = 1
end

function Menu:activate() 	
	self:setImage(getMenuImage(self:getCurrentMenu(), self.selectedIndex))
	
	self:setCenter(0, 0)
	self:moveTo(160, 0)
end

function Menu:update()
	
	if buttons.isButtonJustPressedAny(buttons.up, buttons.down, buttons.a, buttons.b) then
		local success
		 
		if buttons.isButtonJustPressed(buttons.up) then
			success = self:indexDecrement()
			
		elseif buttons.isButtonJustPressed(buttons.down) then
			success = self:indexIncrement()
			
		elseif buttons.isButtonJustPressed(buttons.a) then
			success = self:indexSelect()
			
		elseif buttons.isButtonJustPressed(buttons.b) then
			success = self:indexReturn()
		end
		
		print(self.selectedIndex)
		
		if success then
			sampleplayer:playSample(sampleSelect)
		else 
			sampleplayer:playSample(sampleSelectFail)
		end
	elseif buttons.isButtonJustPressedAny() then
		sampleplayer:play(sampleSelectFail)
	end
end

-- Menu Navigation Functions

function Menu:getCurrentMenu()
	local options = self.options;
	
	for _, index in pairs(self.currentMenuIndex) do
		local option = options[index]
		
		if option.menu ~= nil then
			-- Get Submenu
			options = option.menu
		end
	end
	
	return table.map(options, function(value) return value.title end)
end

function Menu:indexIncrement()
	local menu = self:getCurrentMenu()
	
	if self.selectedIndex == #menu then
		return false
	end
	
	self.selectedIndex += 1
	
	return true
end

function Menu:indexDecrement()
	local menu = self:getCurrentMenu()

	if self.selectedIndex == 1 then
		return false
	end
	
	self.selectedIndex -= 1
	
	return true
end

function Menu:indexSelect()
	local option = self:getCurrentMenu()[self.selectedIndex]
	
	if option.menu == nil and option.callback == nil then
		print("Menu option [".. option.title.."] is missing submenu or callback!")
		return false
	end
	
	if option.menu ~= nil then
		table.insert(self.currentMenuIndex, self.selectedIndex)
	elseif option.callback ~= nil then
		option.callback()
	end
	
	return true
end

function Menu:indexReturn()
	if #self.currentMenuIndex == 1 then
		return false
	end
	
	self.selectedIndex = table.remove(self.currentMenuIndex)
	
	return true
end

-- Drawing Functions

function getMenuImage(entries, index)
	-- Create Menu Image using entries

	local _, textHeight = gfx.getTextSize(entries[1])
	local width = getMaxTextWidth(entries) * SIZE
	local height = textHeight * SIZE * (#entries + MARGIN) - MARGIN
	local menuImage = gfx.image.new(width, height)
	
	-- Create images for entries
	
	local entryImages = {}
	for _, entry in pairs(entries) do
		local itemImage = getMenuItemImage(entries[1])
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
	local textSpacingX = isSelected and 30 or 0
	
	local textImage = gfx.image.new(textSizeWidth, textSizeHeight)
	
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