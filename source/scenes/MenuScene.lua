import "engine"
import "services/sprite/text"
import "sprites/components/menu"

class('MenuScene').extends(Scene)

local MENUTEXT_SPACING <const> = 40

local options = {
	main = {
		"PLAY", 
		"SELECT LEVEL"
	},
	levelselect = {
		"1 MOUNTAIN",
		"2 SEA",
		"3 CASTLE"
	}
}

--------------------
-- Lifecycle Methods

function MenuScene:init()
	Scene.init(self)
	
	self.displayingLevelSelect = false
end

function MenuScene:load()
	Scene.load(self)
end

function MenuScene:present()
	Scene.present(self)
	
	local font = gfx.font.new("fonts/Sans Bold/Cyberball")
	gfx.setFont(font)
	
	-- Print Title Texts
	
	local titleTexts = {"WHEEL", "RUNNER"}
	self.titleSprites = table.imap(titleTexts, function (i) return sizedTextSprite(titleTexts[i], 5) end)
	
	positionTitleSprites(self.titleSprites)
	
	-- Print Menu Options
	
	MenuScene:displayMainMenu()
	
	-- Wheel image
	
	local image = gfx.image.new("images/menu_wheel"):scaledImage(2)
	wheel = gfx.sprite.new(image)
	
	wheel:add()
	wheel:moveTo(75, 90)
end

function MenuScene:update() 
	Scene.update(self)
	
	if buttons.isUpButtonJustPressed() then
		self.menuIndex = math.max(self.menuIndex - 1, 1)
		self.menu:setSelectedIndex(self.menuIndex)
	end
	
	if buttons.isDownButtonJustPressed() then
		self.menuIndex = math.max(self.menuIndex + 1, 1)
		self.menu:setSelectedIndex(self.menuIndex)
	end
	
	if buttons.isBButtonJustReleased() or self.displayingLevelSelect then
		self:displayLevelSelect()
	end
end

function MenuScene:dismiss()
	Scene.dismiss(self)
	
end

function MenuScene:destroy()
	Scene.destroy(self)
	
end

function MenuScene:displayMainMenu()
	if self.menu ~= nil then
		self.menu:remove()
	end
	
	self.menu = Menu(options.main, 1.8)
	self.menu:add()
	self.menu:moveTo(160, 0)
	self.menuIndex = 1
end

function MenuScene:displayLevelSelectMenu()
	if self.menu ~= nil then
		self.menu:remove()
	end
	
	self.menu = Menu(options.levelselect, 1.6)
	self.menu:add()
	self.menu:moveTo(160, 0)
	self.menuIndex = 1
end

function positionTitleSprites(titleSprites)
	local startPoint = { x = 170, y = 126 }
	local endPoint = { x = 93, y = 179 }
	for i, sprite in ipairs(titleSprites) do
		sprite:add()
		
		if i == 1 then
			sprite:moveTo(startPoint.x, startPoint.y)
		else 
			sprite:moveTo(endPoint.x, endPoint.y)
		end
	end
end

function clearMenuOptions(options)
	table.each(options, function (sprite) sprite:remove() end )
end


function MenuScene:displayLevelSelect()
	if self.displayingLevelSelect then 
		if cooldown and buttons.isBButtonJustReleased() then
			self:hideLevelSelect()
		end
		
		return 
	end
	
	self.displayingLevelSelect = true
	
	table.each(self.titleSprites, function(sprite) sprite:setVisible(false) end)
	self:displayLevelSelectMenu()
	
	-- Await button release to show
	
	cooldown = false
	
	timer.performAfterDelay(10, function() cooldown = true end)
end

function MenuScene:hideLevelSelect()
	self.displayingLevelSelect = false
	
	table.each(self.titleSprites, function(sprite) sprite:setVisible(true) end)
	
	self:displayMainMenu()
end