import "engine"
import "services/sprite/text"

class('MenuScene').extends(Scene)


local options = {
	main = {
		"A PLAY", 
		"B SELECT LEVEL"
	},
	levelselect = {
		"1",
		"2",
		"3"
	}
}

--------------------
-- Lifecycle Methods

function MenuScene:init()
	Scene.init(self)
end

function MenuScene:load()
	Scene.load(self)
end

function MenuScene:present()
	Scene.present(self)
	
	local font = gfx.font.new("fonts/Sans Bold/Cyberball")
	gfx.setFont(font)
	
	-- Print Title Texts
	
	local texts = {"WHEEL", "RUNNER"}
	local textSprites = table.imap(texts, function (i) return sizedTextSprite(texts[i], 5) end)
	
	local startPoint = { x = 170, y = 126 }
	local endPoint = { x = 93, y = 179 }
	for i, textSprite in ipairs(textSprites) do
		textSprite:add()
		
		if i == 1 then
			textSprite:moveTo(startPoint.x, startPoint.y)
		else 
			textSprite:moveTo(endPoint.x, endPoint.y)
		end
	end
	
	-- Print Menu Options
	
	local font = gfx.font.new("fonts/Sans Regular/AfterBurner")
	gfx.setFont(font)
	
	local textSprites = table.imap(options.main, 
		function (i)
			return sizedTextSprite(options.main[i], 1.8)
		end
	)
	
	local MENUTEXT_SPACING <const> = 40
	
	for i, textSprite in ipairs(textSprites) do
		textSprite:add()
		textSprite:moveTo(170, 40 + MENUTEXT_SPACING * (i - 1))
	end
	
	-- Wheel image
	
	local image = gfx.image.new("images/menu_wheel"):scaledImage(2)
	local wheel = gfx.sprite.new(image)
	
	wheel:add()
	wheel:moveTo(75, 90)
end

function MenuScene:update() 
	Scene.update(self)
	
	if buttons.isBButtonJustPressed() or displayingLevelSelect then
		displayLevelSelect()
	end
end

function MenuScene:dismiss()
	Scene.dismiss(self)
	
end

function MenuScene:destroy()
	Scene.destroy(self)
	
end

function displayLevelSelect()
	displayingLevelSelect = true
	
	if buttons.isBButtonPressed() then
		hideLevelSelect()
	end
end

function hideLevelSelect()
	displayingLevelSelect = false
end