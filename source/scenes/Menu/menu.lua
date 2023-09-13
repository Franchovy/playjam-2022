import "engine"

local MARGIN <const> = 19
local SIZE <const> = 1.8
local selectedEntryMargin <const> = 15

local sampleSelect <const> = "menu-select"
local sampleSelectFail <const> = "menu-select-fail"

local textHeight = nil;
local menuWidth = nil;

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
	local entries = table.map(self.options, function (value) return value.title end)
	local w, h = gfx.getTextSize("AAAAAAAAAAAAA")
	menuWidth = w * SIZE + selectedEntryMargin
	textHeight = h * SIZE
	
	self:setImage(getMenuImage(self:getCurrentMenuTitles(), self.selectedIndex))
	
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
		
		if success then
			self:setImage(getMenuImage(self:getCurrentMenuTitles(), self.selectedIndex))
			sampleplayer:playSample(sampleSelect)
		else 
			sampleplayer:playSample(sampleSelectFail)
		end
	elseif buttons.isButtonJustPressedAny() then
		sampleplayer:play(sampleSelectFail)
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
	local menuImage = gfx.image.new(menuWidth, height)
	
	-- Create images for entries
	
	local entryImages = {}
	for i, entry in ipairs(entries) do
		local itemImage = getMenuItemImage(entry, selectedIndex == i)
		table.insert(entryImages, itemImage)
	end
		
	-- Draw entry images on menu
			
	gfx.pushContext(menuImage)
	
	for i, imageEntry in pairs(entryImages) do
		-- Draw individual text (scaled)
		local y = (textHeight + MARGIN) * i
		imageEntry:scaledImage(SIZE):draw(0, y)
	end
	
	gfx.popContext()
			
	return menuImage
end

function getMenuItemImage(text, isSelected)
	local textSpacingX = isSelected and selectedEntryMargin or 0
	local textImage = gfx.image.new(menuWidth, textHeight)
	
	gfx.pushContext(textImage)
	
	if isSelected then
		local triangleHeight = 7
		gfx.fillTriangle(0, 0, 10, (textHeight - triangleHeight) / 2 , 0, textHeight - triangleHeight)
	end
	
	gfx.drawTextAligned(text, textSpacingX, 0, textAlignment.left)
	
	gfx.popContext()
	
	return textImage
end


function makeBackgroundImage()	
	local image = gfx.image.new(400, 200)
	
	gfx.pushContext(image)
	
	-- Print Title Texts
	
	gfx.setFont(gfx.font.new("fonts/Sans Bold/Cyberball"))
	local titleTexts = {"WHEEL", "RUNNER"}
	local titleImages = table.imap(titleTexts, function (i) return createTextImage(titleTexts[i]):scaledImage(5) end)
	
	local startPoint = { x = 170, y = 126 }
	local endPoint = { x = 93, y = 179 }
	for i, image in ipairs(titleImages) do
		if i == 1 then
			image:draw(startPoint.x, startPoint.y)
		else
			image:draw(endPoint.x, endPoint.y)
		end
	end
	
	-- Wheel image
	
	local imageWheel = gfx.image.new("images/menu_wheel"):scaledImage(2)
	imageWheel:draw(75, 90)
	
	gfx.popContext()
	
	return image
end