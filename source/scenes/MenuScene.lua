import "engine"
import "services/sprite/text"
import "utils/level"
import "level/levels"
import "level/theme"
import "menu/menu"
import "scenes"

class('MenuScene').extends(Scene)

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
		title = "CUSTOM LEVELS"
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
	
	self:setCenter(0, 0)
	self:setImage(makeBackgroundImage())
	
	-- Create Menu Sprite
	
	menu = Menu(options)
	
	options[3].menu = loadCustomLevels()
end

function MenuScene:present()
	Scene.present(self)
	
	-- Print SpriteMenu Options
	
	menu:activate()
	menu:add()
end

function MenuScene:update() 
	Scene.update(self)
end

function MenuScene:dismiss()
	Scene.dismiss(self)
	
	menu:remove()
end

function MenuScene:destroy()
	Scene.destroy(self)
end

-- Local Functions

function startGame(level)
	loadAllScenes()
	
	print("Starting game with theme: ".. level)
	
	local gameConfig = {
		theme = level,
		components = levelComponents[level]
	}

	sceneManager:switchScene(scenes.game, nil, gameConfig)
end

function startCustomGame(fileName)
	loadAllScenes()
	
	local levelData = importLevel(fileName)
	
	print("Starting game with custom level: ".. fileName)
	print("Level data:")
	printTable(levelData)
	
	local gameConfig = {
		theme = 0,
		gameObjects = {}
	}
	
	sceneManager:switchScene(scenes.game, nil, gameConfig)
end

function makeBackgroundImage()	
	local image = gfx.image.new(400, 240)
	
	gfx.pushContext(image)
	
	-- Print Title Texts
	
	local titleTexts = {"WHEEL", "RUNNER"}
	local titleImages = table.imap(titleTexts, function (i) return createTextImage(titleTexts[i]):scaledImage(5) end)
	
	local startPoint = { x = 170, y = 136 }
	local endPoint = { x = 93, y = 189 }
	for i, image in ipairs(titleImages) do
		if i == 1 then
			image:draw(startPoint.x, startPoint.y)
		else
			image:draw(endPoint.x, endPoint.y)
		end
	end
	
	-- Wheel image
	
	local imageWheel = gfx.image.new("images/menu_wheel"):scaledImage(2)
	imageWheel:draw(5, 25)
	
	gfx.popContext()
	
	return image
end

function loadCustomLevels() 
	local levels = getLevelFiles()
	if #levels == 0 then
		return nil
	end
	
	local submenu = {}
	for _, level in pairs(levels) do
		local levelName = level:match("(.+).json$"):upper()
		local option = {
			title = levelName,
			callback = function() startCustomGame(level) end
		}
		
		table.insert(submenu, option)
	end
	return submenu
end