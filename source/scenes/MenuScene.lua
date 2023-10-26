import "engine"
import "utils/text"
import "constant"
import "playdate"
import "menu/menu"
import "scenes"

class('MenuScene').extends(Scene)

local menu = nil

local levels = {
	{
		title = "MOUNTAIN",
		path = kAssetsLevels.mountain
		-- data = { unlocked = false, complete = nil } -- complete = { stars = nil, coins = nil, time = nil }
	},
	{
		title = "SPACE",
		path = kAssetsLevels.space
	},
	{
		title = "CITY",
		path = kAssetsLevels.city
	}
}

options = {
	{
		title = "PLAY",
		callback = function() startGame(levels[1].path) end
	},
	{
		title = "LEVEL SELECT",
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
	
	options[2].menu = loadCustomLevels()
	
	self:loadComplete()
end

function MenuScene:present()
	playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeCopy)
	playdate.graphics.setBackgroundColor(playdate.graphics.kColorWhite)
	
	Scene.present(self)
	
	-- Print SpriteMenu Options
	
	menu:activate()
	menu:add()
end

function MenuScene:update() 
	
end

function MenuScene:dismiss()
	Scene.dismiss(self)
	
	menu:remove()
end

function MenuScene:destroy()
	Scene.destroy(self)
end

-- Local Functions

function startGame(levelPath)
	loadAllScenes()
	
	sceneManager:switchScene(scenes.game, nil, levelPath..".json")
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
	local submenu = {}
	for _, level in pairs(levels) do
		local option = {
			title = level.title,
			callback = function() startGame(level.path) end
		}
		
		table.insert(submenu, option)
	end
	return submenu
end