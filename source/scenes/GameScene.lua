import "engine"
import "level/levels"
import "level/gameConfig"
import "config"

class('GameScene').extends(Scene)

gameStates = {
	created = "Created",
	loading = "Loading",
	readyToStart = "ReadyToStart",
	playing = "Playing",
	ended = "Ended"
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
	
	local chunkLength = AppConfig["chunkLength"]
	local recycleSpriteIds = {"platform", "killBlock", "coin", "checkpoint"}
	spriteCycler = SpriteCycler(chunkLength, recycleSpriteIds, function(id, position, config, spriteToRecycle)
		local sprite = spriteToRecycle;
			
		if sprite == nil then
			-- Create sprites
			
			if id == "platform" then
				sprite = Platform.new(GRID_SIZE, GRID_SIZE, false)
			elseif id == "killBlock" then
				sprite = KillBlock.new()
			elseif id == "coin" then
				sprite = Coin.new()
			elseif id == "checkpoint" then
				sprite = Checkpoint.new()
			elseif id == "player" then
				sprite = Wheel.new()
				sprite:resetValues()
				sprite:setAwaitingInput()
				self.wheel = sprite
			elseif id == "levelEnd" then
				sprite = LevelEnd.new()
			else 
				print("Unrecognized ID: ".. id)
			end
		end
		
		sprite:loadConfig(config)
		sprite:moveTo(GRID_SIZE * position.x, GRID_SIZE * position.y)
		sprite:add()
		
		return sprite
	end)
	
	self.spritesLoaded = false
end

function GameScene:load(level)
	Scene.load(self)
	
	if level ~= nil then
		self.level = level
	end
	
	print("Game Scene Load")
	
	local levelConfig = importLevel(self.level)
	assert(levelConfig)
	spriteCycler:load(levelConfig)
	self.config = levelConfig
	
	self.gameState = gameStates.loading
	
	-- Draw Background
	
	local theme = self.config.theme
	
	if theme ~= 0 then
		self.levelTheme = levels[theme]
	end
	
	if AppConfig.enableParalaxBackground and self.levelTheme ~= nil then
		self.background = ParalaxBackground.new()
		self.background:loadForTheme(self.levelTheme)
		
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
	
	-- Set background drawing callback
	
	if AppConfig.enableParalaxBackground and self.levelTheme ~= nil then
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
	
	if AppConfig.enableBackgroundMusic and self.levelTheme ~= nil then
		self.filePlayer = FilePlayer(self.levelTheme:getMusicFilepath())
		
		self.filePlayer:play()
	end
end

function GameScene:update()
	Scene.update(self)
	
	local drawOffsetX, drawOffsetY = gfx.getDrawOffset()
	
	-- Update background parallax based on current offset
	
	if AppConfig.enableParalaxBackground and self.levelTheme ~= nil then
		self.background:setParalaxDrawOffset(drawOffsetX)
	end
	
	-- Updates sprites cycling
	spriteCycler:update(-drawOffsetX / GRID_SIZE, drawOffsetY / GRID_SIZE)
	
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
		
		-- Level End Trigger
		
		if self.wheel.hasReachedLevelEnd and levelCompleteSprite == nil then
			
			if self.config.level ~= nil then
				local nextLevel = self.config.level + 1
				self:onLevelComplete(nextLevel)
			else
				self:onLevelComplete() 
			end
		end
		
		-- Camera movement based on wheel position
		
		self:updateDrawOffset()
		
		-- Game State checking
		
		if self.wheel.hasJustDied then
			self.gameState = gameStates.ended
		end
		
		-- Update image score
		
		self.textImageScore:setScoreText(self.wheel:getScoreText())
	end
end

function GameScene:dismiss()
	Scene.dismiss(self)
	
	spriteCycler:unloadAll()
	
	if AppConfig.enableBackgroundMusic and self.levelTheme ~= nil then
		self.filePlayer:stop()
	end
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
			levelCompleteSprite:remove()
			levelCompleteSprite = nil
			
			if nextLevel ~= nil and nextLevel < 4 then
			    sceneManager:switchScene(scenes.game, nil, GameConfig.getLevelConfig(nextLevel))
			else 
				sceneManager:switchScene(scenes.menu, function() self:destroy() end)
			end
			
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