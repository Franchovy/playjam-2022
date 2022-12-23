import "engine"
import "services/sprite/text"

class('MenuScene').extends(Scene)

local MENUTEXT_SPACING <const> = 40

local options = {
	main = {
		"A PLAY", 
		"B SELECT LEVEL"
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
	
	self.textSprites = drawMenuOptions(options.main)
	
	-- Wheel image
	
	local image = gfx.image.new("images/menu_wheel"):scaledImage(2)
	wheel = gfx.sprite.new(image)
	
	wheel:add()
	wheel:moveTo(75, 90)
end

function MenuScene:update() 
	Scene.update(self)
	
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

function drawMenuOptions(options)
	local font = gfx.font.new("fonts/Sans Regular/AfterBurner")
	gfx.setFont(font)
	
	local sprites = table.imap(options, 
		function (i)
			return sizedTextSprite(options[i], 1.8)
		end
	)
	
	positionTextSprites(sprites)
	
	return sprites
end

function positionTextSprites(sprites)
	for i, sprite in ipairs(sprites) do
		sprite:add()
		sprite:moveTo(160, 40 + MENUTEXT_SPACING * (i - 1))
	end
end

function MenuScene:displayLevelSelect()
	if self.displayingLevelSelect then 
		if cooldown and buttons.isBButtonJustReleased() then
			self:hideLevelSelect()
		end
		
		return 
	end
	
	self.displayingLevelSelect = true
	
	clearMenuOptions(self.textSprites)
	self.textSprites = drawMenuOptions(options.levelselect)
	
	table.each(self.titleSprites, function(sprite) sprite:setVisible(false) end)
	
	-- Await button release to show
	
	cooldown = false
	
	timer.performAfterDelay(10, function() cooldown = true end)
end

function MenuScene:hideLevelSelect()
	self.displayingLevelSelect = false
	
	table.each(self.titleSprites, function(sprite) sprite:setVisible(true) end)
	
	clearMenuOptions(self.textSprites)
	self.textSprites = drawMenuOptions(options.main)
end