import "engine"
import "config"
import "utils/themes"
import "utils/text"
import "utils/rect"

class('GameScene').extends(Scene)

gameStates = {
	created = "Created",
	loading = "Loading",
	readyToStart = "ReadyToStart",
	playing = "Playing",
	playerDied = "PlayerDied",
	levelEnd = "LevelEnd"
}

local MAX_CHUNKS = 16
local CHUNK_LENGTH = 1000
local GRID_SIZE = 24

local LEVEL_COMPLETE_SIZE = 3500

local spriteCycler = nil
local levelCompleteSprite = nil

function GameScene:init()
	Scene.init(self)
	
	--
	
	self.wheel = nil
	self.textImageScore = nil
	
	self.gameState = gameStates.created
	
	self.spritesLoaded = false
end

function GameScene:load(level)
	Scene.load(self)
	
	-- Level nil check for restarting after Game Over
	if level ~= nil then
		self.level = level
	end
	
	print("Game Scene Load")
	
	self.gameState = gameStates.loading
	
	-- Create periodic blinker
	
	self.periodicBlinker = periodicBlinker({onDuration = 50, offDuration = 50, cycles = 8}, 300)
	
	-- Set up spritecycler
	
	local chunkLength = AppConfig["chunkLength"]
	local recycleSpriteIds = {"platform", "killBlock", "coin", "checkpoint"}
	spriteCycler = SpriteCycler(chunkLength, recycleSpriteIds, function(id, position, config, spriteToRecycle)
		local sprite = spriteToRecycle;
			
		if sprite == nil then
			-- Create sprites
			if id == "platform" then
				sprite = Platform.new(GRID_SIZE, GRID_SIZE, false)
			elseif id == "killBlock" then
				sprite = KillBlock.new(self.periodicBlinker)
			elseif id == "coin" then
				sprite = Coin.new()
			elseif id == "checkpoint" then
				sprite = Checkpoint.new()
			elseif id == "player" then
				sprite = Wheel.new()
				sprite:resetValues()
				sprite:setAwaitingInput()
				self.wheel = sprite
				
				if self.previousLoadPoint ~= nil then
					position = self.previousLoadPoint
				end
			elseif id == "levelEnd" then
				sprite = LevelEnd.new()
			else 
				print("Unrecognized ID: ".. id)
			end
		end
		
		if config ~= nil then
			sprite:loadConfig(config)
		end
		
		if position ~= nil then
			sprite:moveTo(GRID_SIZE * position.x, GRID_SIZE * position.y)
			sprite:add()
		end
		
		return sprite
	end)
	
	-- Load Level Config
	
	local path = kFilePath.levels.."/"..self.level
	local levelConfig = json.decodeFile(path)
	
	assert(levelConfig)
	
	spriteCycler:load(levelConfig)
	
	spriteCycler:preloadSprites({
		id = "platform",
		count = 40
	}, {
		id = "killBlock",
		count = 10
	}, {
		id = "coin",
		count = 20
	}, {
		id = "checkpoint",
		count = 1
	})
	
	self.config = levelConfig
	
	-- Draw Background
	
	local themeId = self.config.theme
	
	if themeId ~= 0 then
		self.theme = kThemes[themeId]
	end
	
	if AppConfig.enableParalaxBackground and self.theme ~= nil then
		self.background = ParalaxBackground.new()
		self.background:loadTheme(self.theme)
		
		self.background:setParalaxDrawingRatios()
	end
	
	-- set up other sprites
	
	if not self.spritesLoaded then
		
		-- Draw Score Text
		
		self.textImageScore = Score.new("Score: 0")
		
		-- Generate Level
		
		self.spritesLoaded = true
	end
end

function GameScene:present()
	Scene.present(self)
	
	print("Game Scene Present")
	
	-- Position Sprites
	
	self.textImageScore:add()
	
	-- Start periodicBlinker for flashing animations
	
	self.periodicBlinker:start()
	
	-- Set background drawing callback
	
	if AppConfig.enableParalaxBackground and self.theme ~= nil then
		local callback = self.background:getBackgroundDrawingCallback()
		
		gfx.sprite.setBackgroundDrawingCallback(callback)
		
		self.background:add()
	end
	
	-- Set game as ready to start
	
	self.gameState = gameStates.readyToStart
	
	-- Initialize sprite cycling using initial wheel position
	
	local initialChunk = spriteCycler:getFirstInstanceChunk("player")
	spriteCycler:loadInitialSprites(initialChunk, 1)
	
	-- Set camera to center on wheel
	
	self:updateDrawOffset()
	
	-- Play music
	
	if AppConfig.enableBackgroundMusic and self.theme ~= nil then
		local musicFilePath = getMusicFilepathForTheme(self.theme)
		self.filePlayer = FilePlayer(musicFilePath)
		
		self.filePlayer:play()
	end
end

function GameScene:update()
	local drawOffsetX, drawOffsetY = gfx.getDrawOffset()
	
	-- Update periodicBlinker
	
	self.periodicBlinker:update()
	
	-- Update background parallax based on current offset
	
	if AppConfig.enableParalaxBackground and self.theme ~= nil then
		self.background:setParalaxDrawOffset(drawOffsetX)
	end
	
	-- Updates sprites cycling
	spriteCycler:update(-drawOffsetX / GRID_SIZE, drawOffsetY / GRID_SIZE)
	
	if not self.isFinishedTransitioning then
		return
	end
	
	-- On game start
	
	if self.gameState == gameStates.readyToStart then
		-- Awaiting player input (jump / crank)
		if playdate.buttonIsPressed(playdate.kButtonA) or (math.abs(playdate.getCrankChange()) > 5) then
			self.wheel:startGame()
			
			self.gameState = gameStates.playing
		end
	end
	
	if self.gameState == gameStates.playing then
		
		-- Update Blinker
		
		if blinker ~= nil then
			blinker:update()
			if levelCompleteSprite ~= nil then	
				levelCompleteSprite:setVisible(blinker.on)
			end
		end
		
		-- Touch Checkpoint: set new load point
		
		if self.wheel.hasTouchedNewCheckpoint == true then
			local position = self.wheel:getRecentCheckpoint()
			self.previousLoadPoint = { x = position.x / GRID_SIZE, y = position.y / GRID_SIZE }
		end
		
		-- Level End Trigger
		
		if self.wheel.hasReachedLevelEnd and levelCompleteSprite == nil then
			
			self:onLevelComplete()
		end
		
		-- Camera movement based on wheel position
		
		self:updateDrawOffset()
		
		-- Game State checking
		
		if self.wheel.hasJustDied then
			self.gameState = gameStates.playerDied
		end
		
		-- Update image score
		
		self.textImageScore:setScoreText(self.wheel:getScoreText())
	end
	
	if self.gameState == gameStates.levelEnd then
		if playdate.buttonJustPressed(playdate.kButtonA) then
			sceneManager:switchScene(scenes.menu, function() self:destroy() end)
		elseif playdate.buttonJustPressed(playdate.kButtonB) then
			self.previousLoadPoint = nil
			sceneManager:switchScene(scenes.game, function () end)
		end
	end
end

function GameScene:dismiss()
	Scene.dismiss(self)
	
	spriteCycler:unloadAll()
	
	if AppConfig.enableBackgroundMusic and self.theme ~= nil then
		self.filePlayer:stop()
	end
	
	self.periodicBlinker:destroy()
end

function GameScene:destroy()
	Scene.destroy(self)
end

function GameScene:updateDrawOffset()
	local drawOffset = gfx.getDrawOffset()
	local relativeX = self.wheel.x + drawOffset
	if relativeX > 150 then
		gfx.setDrawOffset(-self.wheel.x + 150, 0)
	elseif relativeX < 80 then
		gfx.setDrawOffset(-self.wheel.x + 80, 0)
	end
end

function GameScene:onLevelComplete(nextLevel)

	addLevelCompleteSprite()
		
	timer.performAfterDelay(3000,
		function ()
			self.gameState = gameStates.levelEnd
			
			levelCompleteSprite:remove()
			levelCompleteSprite = nil
			
			drawLevelClearSprite()
		end
	)
end

function addLevelCompleteSprite()
	levelCompleteSprite = sizedTextSprite("LEVEL COMPLETE", 3)
	
	levelCompleteSprite:setImage(levelCompleteSprite:getImage())
	levelCompleteSprite:setIgnoresDrawOffset(true)
	
	levelCompleteSprite:add()
	levelCompleteSprite:moveTo(10, 110)

	blinker = playdate.graphics.animation.blinker.new(300, 100)
	blinker:startLoop()
end

function drawLevelClearSprite()
	local bounds = playdate.display.getRect()
	local x1, y1, width1, height1 = rectInsetBy(bounds, 30, 30)
	local x2, y2, width2, height2 = rectInsetBy(bounds, 34, 36)
	
	local imageCardBackground = playdate.graphics.image.new(width2, height2)
	
	playdate.graphics.pushContext(imageCardBackground)
	
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	playdate.graphics.fillRoundRect(0, 0, width2, height2, 18)
	
	playdate.graphics.popContext()
	
	local imageCard = playdate.graphics.image.new(width1, height1)
	
	playdate.graphics.pushContext(imageCard)
	
	-- Frame
		
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.fillRoundRect(0, 0, width1, height1, 16)
	playdate.graphics.setColor(playdate.graphics.kColorClear)
	playdate.graphics.fillRoundRect(x2 - x1, (y2 - y1) / 2, width2, height2, 18)
	
	imageCardBackground:fadedImage(0.8, playdate.graphics.image.kDitherTypeDiagonalLine):draw(x2 - x1, (y2 - y1) / 2)
	
	gfx.setFontTracking(1)
	local textImageTitle = createTextImage("LEVEL COMPLETE!"):scaledImage(2)
	
	gfx.setFontTracking(1)
	local textImageCoinsLabel = createTextImage("COINS"):scaledImage(1)
	local textImageTimeLabel = createTextImage("TIME"):scaledImage(1)
	gfx.setFontTracking(0)
	local textImageCoinsValue = createTextImage("".. 40 .. "/".. 40):scaledImage(2)
	local textImageTimeValue = createTextImage("02:00".. "/".. "02:00"):scaledImage(2)
	
	local widthTitle, _ = textImageTitle:getSize()
	textImageTitle:draw((width1 - widthTitle) / 2, 10)
	
	local widthCoinsLabel, heightCoinsLabel = textImageCoinsLabel:getSize()
	local widthCoinsValue, heightCoinsValue = textImageCoinsValue:getSize()
	textImageCoinsLabel:draw(20 + (widthCoinsValue - widthCoinsLabel) / 2, height1 - heightCoinsLabel - 15 - heightCoinsValue - 20)
	textImageCoinsValue:draw(20, height1 - heightCoinsValue - 20)
	
	local widthTimeLabel, heightTimeLabel = textImageTimeLabel:getSize()
	local widthTimeValue, heightTimeValue = textImageTimeValue:getSize()
	textImageTimeLabel:draw(width1 - widthTimeValue + (widthTimeValue - widthTimeLabel) / 2 - 20, height1 - heightTimeLabel - 15 - heightCoinsValue - 20)
	textImageTimeValue:draw(width1 - widthTimeValue - 20, height1 - heightTimeValue - (heightCoinsValue - heightTimeValue) / 2 - 20)
	
	playdate.graphics.popContext()
	
	local sprite = playdate.graphics.sprite.new(imageCard)
	sprite:add()
	sprite:setCenter(0, 0)
	sprite:setIgnoresDrawOffset(true)
	
	-- Button Labels
	
	local buttonALabelText = createTextImage("B - RETRY")
	local buttonALabel = createRoundedRectFrame(buttonALabelText, 4, 8, 5)
	
	local buttonBLabelText = createTextImage("A - LEVELS")
	local buttonBLabel = createRoundedRectFrame(buttonBLabelText, 4, 8, 5)
	
	local buttonBLabelWidth, buttonBLabelHeight = buttonBLabel:getSize()
	local buttonsImage = playdate.graphics.image.new(360, buttonBLabelHeight)
	
	playdate.graphics.pushContext(buttonsImage)
	local margin = 44
	buttonALabel:draw(0, 0)
	buttonBLabel:draw(bounds.width - (margin * 2) - buttonBLabelWidth, 0)
	
	playdate.graphics.popContext(buttonsImage)
	
	local spriteButtons = playdate.graphics.sprite.new(buttonsImage)
	spriteButtons:add()
	spriteButtons:setCenter(0, 0)
	spriteButtons:setIgnoresDrawOffset(true)
	spriteButtons:moveTo(margin, bounds.height - 6 - buttonBLabelHeight)
	
	-- Stars
	
	local imageTable = playdate.graphics.imagetable.new(kAssetsImages.star)
	local star1 = playdate.graphics.animation.loop.new(200, imageTable)
	local star2 = playdate.graphics.animation.loop.new(200, imageTable)
	local star3 = playdate.graphics.animation.loop.new(200, imageTable)
	star1.paused = true
	star2.paused = true
	star3.paused = true
	
	local marginStar = 20
	local starWidth, starHeight = imageTable:getImage(1):getSize()
	
	local starSprite = playdate.graphics.sprite.new()
	starSprite:setSize(starWidth * 3 + marginStar * 2, starHeight)
	starSprite:setCenter(0, 0)
	starSprite:setIgnoresDrawOffset(true)
	starSprite:setAlwaysRedraw(true)
	
	star1.paused = false
	star2.paused = false
	star3.paused = false
	
	starSprite.draw = function (self, x, y)
		star1:draw(0, 0)
		star2:draw(starWidth + marginStar, 0)
		star3:draw((starWidth + marginStar) * 2, 0)
	end
	
	starSprite:add()
	starSprite:moveTo(70, 65)
	
	-- Animations
	
	local animationStartPosition = 240
	local animationEndPosition = y1
	
	sprite:moveTo(x1, animationStartPosition)
	
	
	local animationTimer = playdate.timer.new(400, animationStartPosition, animationEndPosition, playdate.easingFunctions.inQuad)
	
	animationTimer.updateCallback = function(timer)
		sprite:moveTo(x1, timer.value)
	end
	
	animationTimer.timerEndedCallback = function(timer)
		sprite:moveTo(x1, animationEndPosition)
		timer:remove()
	end
end