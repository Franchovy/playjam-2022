import "engine"

class('MenuScene').extends(Scene)

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
	local textSprites = createTextSprites(texts, 5)
	
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
	
	local textSprites = createTextSprites({"A PLAY", "B SELECT LEVEL"}, 1.8)
	
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
	
end

function MenuScene:dismiss()
	Scene.dismiss(self)
	
end

function MenuScene:destroy()
	Scene.destroy(self)
	
end

function createTextSprites(texts, scaling)
	local textSprites = table.map(texts, 
		function (text)
			local image = createTextImage(text):scaledImage(scaling)
			local sprite = gfx.sprite.new(image)
			sprite:setCenter(0, 0)
			return sprite
		end
	)
	
	return textSprites
end
