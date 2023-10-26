import "engine"

local MARGIN <const> = 19
local SIZE <const> = 1.8
local selectedEntryMargin <const> = 15

local sampleSelect <const> = "menu-select"
local sampleSelectFail <const> = "menu-select-fail"

local textHeight = nil;
local menuWidth = nil;

class("Menu").extends(playdate.sprite)

function Menu.new(options)
	return Menu(options)
end

function Menu:init(options)
	Menu.super.init(self)
	
	self.options = options
	
	-- Load Sound Effects
	
	sampleplayer:addSample(sampleSelect, kAssetsSounds.menuSelect)
	sampleplayer:addSample(sampleSelectFail, kAssetsSounds.menuSelectFail)
	
	-- Menu index
	
	self.currentMenuIndex = {}
	self.selectedIndex = 1
end

function Menu:activate() 	
	local entries = table.map(self.options, function (value) return value.title end)
	local w, h = playdate.graphics.getTextSize("AAAAAAAAAAAAA")
	menuWidth = w * SIZE + selectedEntryMargin
	textHeight = h * SIZE
	
	local titles = self:getCurrentMenuTitles()
	local image = getMenuImage(titles, self.selectedIndex)
	self:setImage(image)
	
	self:setCenter(0, 0)
	self:moveTo(160, 0)
end

function Menu:update()
	
	if playdate.buttonJustPressedAny(playdate.kButtonUp, playdate.kButtonDown, playdate.kButtonA, playdate.kButtonB) then
		local success
		 
		if playdate.buttonJustPressed(playdate.kButtonUp) then
			success = self:indexDecrement()
			
		elseif playdate.buttonJustPressed(playdate.kButtonDown) then
			success = self:indexIncrement()
			
		elseif playdate.buttonJustPressed(playdate.kButtonA) then
			success = self:indexSelect()
			
		elseif playdate.buttonJustPressed(playdate.kButtonB) then
			success = self:indexReturn()
		end
		
		if success then
			self:setImage(getMenuImage(self:getCurrentMenuTitles(), self.selectedIndex))
			sampleplayer:playSample(sampleSelect)
		else 
			sampleplayer:playSample(sampleSelectFail)
		end
	elseif playdate.buttonJustPressedAny() then
		sampleplayer:playSample(sampleSelectFail)
	end
end

-- Menu Navigation Functions

function Menu:getCurrentMenuTitles()
	return table.map(self:getCurrentMenu(), function(value) return value.title end)
end

function Menu:getCurrentMenu()
	local options = self.options;
	
	for _, index in pairs(self.currentMenuIndex) do
		local option = options[index]
		
		if option.menu ~= nil then
			-- Get Submenu
			options = option.menu
		end
	end
	
	return options
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
		self.selectedIndex = 1
	elseif option.callback ~= nil then
		option.callback()
	end
	
	return true
end

function Menu:indexReturn()
	if #self.currentMenuIndex == 0 then
		return false
	end
	
	self.selectedIndex = table.remove(self.currentMenuIndex)
	
	return true
end

-- Drawing Functions

function getMenuImage(entries, selectedIndex)
	-- Create Menu Image using entries
	
	local height = textHeight * (#entries + MARGIN) - MARGIN
	local menuImage = playdate.graphics.image.new(menuWidth, height)
	
	-- Create images for entries
	
	local entryImages = {}
	for i, entry in ipairs(entries) do
		local itemImage = getMenuItemImage(entry, selectedIndex == i)
		table.insert(entryImages, itemImage)
	end
		
	-- Draw entry images on menu
			
	playdate.graphics.pushContext(menuImage)
	
	for i, imageEntry in pairs(entryImages) do
		-- Draw individual text (scaled)
		local y = (textHeight + MARGIN) * i
		imageEntry:scaledImage(SIZE):draw(0, y)
	end
	
	playdate.graphics.popContext()
			
	return menuImage
end

function getMenuItemImage(text, isSelected)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	local textSpacingX = isSelected and selectedEntryMargin or 0
	local textImage = playdate.graphics.image.new(menuWidth, textHeight)
	
	playdate.graphics.pushContext(textImage)
	
	if isSelected then
		local triangleHeight = 7
		playdate.graphics.fillTriangle(0, 0, 10, (textHeight - triangleHeight) / 2 , 0, textHeight - triangleHeight)
	end
	
	playdate.graphics.drawTextAligned(text, textSpacingX, 0, textAlignment.left)
	
	playdate.graphics.popContext()
	
	return textImage
end