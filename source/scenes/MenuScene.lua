import "engine"
import "services/sprite/text"
import "Menu/SpriteMenu"
import "Menu/MenuOption"
import "level/levels"
import "level/theme"
import "scenes"

class('MenuScene').extends(Scene)

local MENUTEXT_SPACING <const> = 40

local selectedIndex = [1]
local menu = nil

options = {
	{
		title = "PLAY",
		callback = function() startGame(1) end
	},
	{
		title = "SELECT LEVEL",
		menu = {
			{
				title = "1 COUNTRY",
				callback = function() startGame(1) end
			},
			{
				title = "2 SPACE",
				callback = function() startGame(2) end
			},
			{
				title = "3 CITY",
				callback = function() startGame(3) end
			},
		}
	},
	{
		title = "CUSTOM LEVELS",
		menu = {}
	}
}

--------------------
-- Lifecycle Methods

function MenuScene:init()
	Scene.init(self)
end

function MenuScene:load()
	Scene.load(self)
	
	-- Draw Menu Background
	
	drawBackground()
	
	-- Create Menu Sprite
	
	menu = Menu.new(options)
	
	-- TODO: Load custom levelsfile names
end

function MenuScene:present()
	Scene.present(self)
	
	-- Print SpriteMenu Options
	
	menu:add()
end

function MenuScene:update() 
	Scene.update(self)
	
	if buttons.isUpButtonJustPressed() then
		menu:indexDecrement()
	end
	
	if buttons.isDownButtonJustPressed() then
		menu:indexIncrement()
	end
	
	if buttons.isAButtonJustPressed() then
		menu:indexSelect()
	end
	
	if buttons.isBButtonJustReleased() then
		menu:indexReturn()
	end
end

function MenuScene:dismiss()
	Scene.dismiss(self)
end

function MenuScene:destroy()
	Scene.destroy(self)
end

function startGame(level)
	loadAllScenes()
	
	print("Starting game with level: ".. level)
	
	currentTheme = level

	sceneManager:switchScene(scenes.game, function () end)
end

function drawBackground()
	
	local images = {}
	
	-- Print Title Texts
	
	gfx.setFont(gfx.font.new("fonts/Sans Bold/Cyberball"))
	local titleTexts = {"WHEEL", "RUNNER"}
	self.titleImages = table.imap(titleTexts, function (i) return createTextImage(titleTexts[i]):scaledImage(5) end)
	
	local startPoint = { x = 170, y = 126 }
	local endPoint = { x = 93, y = 179 }
	for i, sprite in ipairs(titleImages) do
		if i == 1 then
			table.insert(images, { image = imageTitle, x = startPoint.x, y = startPoint.y)
		else
			table.insert(images, { image = imageTitle, x = endPoint.x, y = endPoint.y) 
		end
	end
	
	-- Wheel image
	
	local image = gfx.image.new("images/menu_wheel"):scaledImage(2)
	table.insert(images, { image = imageWheel, x = 75, y = 90 })
	
	-- TODO: Draw image in background
end