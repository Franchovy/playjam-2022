import "engine.lua"
import "assets"
import "scenes/scenes"
import "sprites/lib"
import "notify"
import "config"

local acceptsRestart = false

local imagetable
local wheelImageTable
local backgroundImage
local backgroundImage2
local backgroundImage3
local backgroundImage4
local textImage
local textImageInverted 

local pressStart

local painter

function initialize()
	gfx.setFont(gfx.font.new(kAssetsFonts.twinbee))
	gfx.setFontTracking(1)
	
	imagetable = playdate.graphics.imagetable.new(kAssetsImages.particles)
	wheelImageTable = playdate.graphics.imagetable.new(kAssetsImages.wheel)
	backgroundImage = playdate.graphics.image.new(kAssetsImages.background)
	backgroundImage2 = playdate.graphics.image.new(kAssetsImages.background2)
	backgroundImage3 = playdate.graphics.image.new(kAssetsImages.background3)
	backgroundImage4 = playdate.graphics.image.new(kAssetsImages.background4)
	textImage = playdate.graphics.imageWithText("WHEEL RUNNER", 400, 100):scaledImage(3)
	textImageInverted = textImage:invertedImage()
	
	pressStart = playdate.graphics.imageWithText("PRESS A", 200, 60):scaledImage(2)
	
	
	local painterButtonFill = Painter(function(tick)
		if tick == 0 then
			-- press a button fill
			playdate.graphics.setColor(playdate.graphics.kColorWhite)
			playdate.graphics.setDitherPattern(0.8, playdate.graphics.image.kDitherTypeDiagonalLine)
			playdate.graphics.fillRoundRect(125 - 10, 210, 160, 27, 6)
		else
			-- press a button fill
			playdate.graphics.setColor(playdate.graphics.kColorWhite)
			playdate.graphics.setDitherPattern(0.2, playdate.graphics.image.kDitherTypeDiagonalLine)
			playdate.graphics.fillRoundRect(125 - 10, 210, 160, 27, 6)
		end
	end)
	
	local painterButtonOutline = Painter(function(tick)
		if tick == 0 then
			-- press a button outline
			playdate.graphics.setColor(playdate.graphics.kColorBlack)
			playdate.graphics.setDitherPattern(0.2, playdate.graphics.image.kDitherTypeDiagonalLine)
			playdate.graphics.setLineWidth(3)
			playdate.graphics.drawRoundRect(125 - 10, 210, 160, 27, 6)
		else
			-- press a button outline
			playdate.graphics.setColor(playdate.graphics.kColorBlack)
			playdate.graphics.setLineWidth(3)
			playdate.graphics.drawRoundRect(125 - 10, 210, 160, 27, 6)
		end
	end)
	
	local painterButtonPressStart = Painter(function(tick)
		if tick == 0 then
			-- press a text
			pressStart:drawFaded(130, 215, 0.3, playdate.graphics.image.kDitherTypeDiagonalLine)
		else
			-- press a text
			pressStart:draw(130, 215)
		end
	end)
	
	painter = Painter(function(tick) 
		painterButtonFill:draw(tick)
		painterButtonOutline:draw(tick)
		painterButtonPressStart:draw(tick)
	end)
	
	-- Create game state manager
	--scenes.menu = MenuScene()
	
	-- Create Scene
	-- * calls load and present
	--sceneManager:setCurrentScene(scenes.menu)
end

local index = 0
local tick = 0
function playdate.update()
	index += 3
	
	if index % 40 > 30 then
		tick = tick == 0 and 1 or 0
	end
	
	-- state
	--painter.setState({index = index, tick = tick})
	
	playdate.graphics.clear()
	
	-- background
	playdate.graphics.setDitherPattern(0.4, playdate.graphics.image.kDitherTypeDiagonalLine)
	playdate.graphics.fillRect(0, 0, 400, 240)
	
	-- background - right hill
	backgroundImage3:drawFaded(0, -10, 0.2, playdate.graphics.image.kDitherTypeBayer8x8)
	
	-- background - flashing lights
	if tick == 0 then
		backgroundImage2:drawFaded(5, 0, 0.7, playdate.graphics.image.kDitherTypeDiagonalLine)
	else
		backgroundImage2:invertedImage():drawFaded(5, 0, 0.3, playdate.graphics.image.kDitherTypeDiagonalLine)
	end
	
	-- background - left hill
	backgroundImage4:drawFaded(-20, 120, 0.8, playdate.graphics.image.kDitherTypeBayer4x4)
	backgroundImage:draw(200,30)
	
	-- animated particles
	imagetable:getImage((index % 36) + 1):scaledImage(2):draw(-60, -25)
	-- animated wheel
	wheelImageTable:getImage((-index % 12) + 1):scaledImage(2):draw(70, 50)
	
	-- title rectangle outline
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.setDitherPattern(0.3, playdate.graphics.image.kDitherTypeDiagonalLine)
	playdate.graphics.fillRect(0, 150, 400, 57)
	
	-- title rectangle fill
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	playdate.graphics.setDitherPattern(0.3, playdate.graphics.image.kDitherTypeDiagonalLine)
	playdate.graphics.fillRect(0, 160, 400, 37)
	
	-- title white shadow
	textImageInverted:draw(39, 166)
	-- title 
	textImage:draw(40, 165)
	
	painter:draw(tick)
end

function placeholder()
	gfx.sprite.redrawBackground()

	-- Random Seed (for generating random numbers)
	math.randomseed(playdate.getSecondsSinceEpoch())

	-- Game Update

	Scene.update()
	playdate.graphics.animation.blinker.updateAll()
	timer.updateTimers()
	sprite.update()
	frameTimer.updateTimers()

	-- State management
	
	updateScenes()
end

function isGameSceneOver()
	return scenes.game.gameState == gameStates.playerDied
end

function transitionToGameOverScene()
	local gameScene = sceneManager.currentScene
	sceneManager:switchScene(scenes.gameover, function () gameScene:destroy() end)
end


function updateScenes()
	if sceneManager.currentScene == scenes.game then
		if isGameSceneOver() then
			transitionToGameOverScene()
		end
	end
end

-- Start Game

initialize()
