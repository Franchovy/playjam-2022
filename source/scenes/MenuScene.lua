import "engine"
import "utils/text"
import "constant"
import "playdate"
import "menu/menu"
import "scenes"

class('MenuScene').extends(Scene)

local menu = nil

options = {
	{
		title = "PLAY",
		callback = function() end
	},
	{
		title = "SELECT LEVEL",
		menu = {
			{
				title = "1 COUNTRY",
				callback = function() end
			},
			{
				title = "2 SPACE",
				callback = function() end
			},
			{
				title = "3 CITY",
				callback = function() end
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
	
	self._sprite:setCenter(0, 0)
	self._sprite:setImage(makeBackgroundImage())
	
	-- Create Menu sprite
	
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

function startCustomGame(fileName)
	loadAllScenes()
	
	sceneManager:switchScene(scenes.game, nil, fileName)
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
	
	local imageWheel = gfx.image.new(kAssetsImages.menuWheel):scaledImage(2)
	imageWheel:draw(5, 25)
	
	gfx.popContext()
	
	return image
end

function loadCustomLevels()
	playdate.file.mkdirIfNeeded(kFilePath.levels)
	
	local levels = playdate.file.listFiles(kFilePath.levels)
	
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