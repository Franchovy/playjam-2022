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

local painterButton
local painterBackground
local painterTitle
local painterWheel

local index = 0
local tick = 0

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
	
	-- Painter Button
	
	local painterButtonFill = Painter(function(rect, state)
		if state.tick == 0 then
			-- press a button fill
			playdate.graphics.setColor(playdate.graphics.kColorWhite)
			playdate.graphics.setDitherPattern(0.8, playdate.graphics.image.kDitherTypeDiagonalLine)
			playdate.graphics.fillRoundRect(rect.x, rect.y, rect.w, rect.h, 6)
		else
			-- press a button fill
			playdate.graphics.setColor(playdate.graphics.kColorWhite)
			playdate.graphics.setDitherPattern(0.2, playdate.graphics.image.kDitherTypeDiagonalLine)
			playdate.graphics.fillRoundRect(rect.x, rect.y, rect.w, rect.h, 6)
		end
	end)
	
	local painterButtonOutline = Painter(function(rect, state)
		if state.tick == 0 then
			-- press a button outline
			playdate.graphics.setColor(playdate.graphics.kColorBlack)
			playdate.graphics.setDitherPattern(0.2, playdate.graphics.image.kDitherTypeDiagonalLine)
			playdate.graphics.setLineWidth(3)
			playdate.graphics.drawRoundRect(rect.x, rect.y, rect.w, rect.h, 6)
		else
			-- press a button outline
			playdate.graphics.setColor(playdate.graphics.kColorBlack)
			playdate.graphics.setLineWidth(3)
			playdate.graphics.drawRoundRect(rect.x, rect.y, rect.w, rect.h, 6)
		end
	end)
	
	local painterButtonPressStart = Painter(function(rect, state)
		if state.tick == 0 then
			-- press a text
			pressStart:drawFaded(rect.x, rect.y, 0.3, playdate.graphics.image.kDitherTypeDiagonalLine)
		else
			-- press a text
			pressStart:draw(rect.x, rect.y)
		end
	end)
	
	painterButton = Painter(function(rect, state) 
		painterButtonFill:draw({ x = 0, y = 0, w = rect.w, h = rect.h }, state)
		painterButtonOutline:draw({ x = 0, y = 0, w = rect.w, h = rect.h }, state)
		
		local imageSizePressStartW, imageSizePressStartH = pressStart:getSize()
		painterButtonPressStart:draw({x = 15, y = 5, w = imageSizePressStartW, h = imageSizePressStartH}, state)
	end)
	
	-- Painter Background
	
	local painterBackground1 = Painter(function(rect, state)
		playdate.graphics.setDitherPattern(0.4, playdate.graphics.image.kDitherTypeDiagonalLine)
		playdate.graphics.fillRect(0, 0, 400, 240)
	end)
	
	local painterBackground2 = Painter(function(rect, state)
		-- background - right hill
		backgroundImage3:drawFaded(0, -10, 0.2, playdate.graphics.image.kDitherTypeBayer8x8)
	end)
	
	local painterBackground3 = Painter(function(rect, state)
		-- background - flashing lights
		if state.tick == 0 then
			backgroundImage2:drawFaded(5, 0, 0.7, playdate.graphics.image.kDitherTypeDiagonalLine)
		else
			backgroundImage2:invertedImage():drawFaded(5, 0, 0.3, playdate.graphics.image.kDitherTypeDiagonalLine)
		end
	end)
	
	local painterBackground4 = Painter(function(rect, state)
		-- background - left hill
		backgroundImage4:drawFaded(-20, 120, 0.8, playdate.graphics.image.kDitherTypeBayer4x4)
		backgroundImage:draw(200,30)
	end)
	
	painterBackground = Painter(function(rect, state)
		local rectOffset = Rect.offset(rect, 0, -20)
		painterBackground1:draw(rectOffset)
		painterBackground2:draw(rectOffset)
		painterBackground3:draw(rectOffset, state)
		painterBackground4:draw(rectOffset)
		
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.setDitherPattern(0.1, playdate.graphics.image.kDitherTypeBayer4x4)
		playdate.graphics.fillRect(rect.x, (rect.y + rect.h) - 20, rect.w, 20)
	end)
	
	-- Painter Text
	
	local painterTitleRectangleOutline = Painter(function(rect, state)
		-- title rectangle outline
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.setDitherPattern(0.3, playdate.graphics.image.kDitherTypeDiagonalLine)
		playdate.graphics.fillRect(rect.x, rect.y, rect.w, rect.h)
	end)
	
	local painterTitleRectangleFill = Painter(function(rect, state)
		-- title rectangle fill
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.setDitherPattern(0.3, playdate.graphics.image.kDitherTypeDiagonalLine)
		playdate.graphics.fillRect(rect.x, rect.y, rect.w, rect.h)
	end)
	
	local painterTitleText = Painter(function(rect, state)
		textImage:draw(rect.x, rect.y)
	end)
	
	painterTitle = Painter(function(rect, state)
		painterTitleRectangleOutline:draw(rect)
		painterTitleRectangleFill:draw(Rect.inset(rect, 0, 10))
		local titleTextSizeW, titleTextSizeH = textImage:getSize()
		painterTitleText:draw({x = 40, y = 15, w = titleTextSizeW, h = titleTextSizeH })
	end)
	
	painterParticles = Painter(function(rect, state) 
		-- animated particles
		imagetable:getImage((state.index % 36) + 1):scaledImage(2):draw(rect.x, rect.y)
	end)
	
	painterWheel = Painter(function(rect, state, globals)
		table.insert(globals, { 
			fn = function() 
				painterParticles:draw({ x = rect.x - 55, y = rect.y - 35, w = 150, h = 150}, state, { absolute = true })
			end,
			state = state
		})

		-- animated wheel
		wheelImageTable:getImage((-state.index % 12) + 1):scaledImage(2):draw(rect.x, rect.y)
	end)
	-- Create game state manager
	--scenes.menu = MenuScene()
	
	-- Create Scene
	-- * calls load and present
	--sceneManager:setCurrentScene(scenes.menu)
	
	playdate.graphics.sprite.setBackgroundDrawingCallback(function()
		local w, h = playdate.display.getSize()
		local maxRect = 
		
		Painter.clearGlobal()
		
		painterBackground:draw({ x = 0, y = 0, w = w, h = h }, { tick = tick })
		
		painterWheel:draw({x = 70, y = 30, w = 150, h = 150}, { index = index % 36 })
		
		painterTitle:draw({x = 0, y = 130, w = 400, h = 57})
		painterButton:draw({x = 115, y = 200, w = 160, h = 27}, { tick = tick })
		
		Painter.drawGlobal()
	end)
	
end

function playdate.update()
	index += 2
	
	if index % 40 > 32 then
		tick = tick == 0 and 1 or 0
	end
	
	sprite.update()
	playdate.graphics.sprite.redrawBackground()
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
