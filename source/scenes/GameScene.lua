import "engine"
import "generator/spritepositionmanager"
import "generator/spriteloader"
import "generator/spritedata"
import "generator/chunkgenerator"
import "services/blinker"
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

local spriteCycler = nil
local levelCompleteSprite = nil

function GameScene:init()
	Scene.init(self)
	
	--
	
	self.wheel = nil
	self.wallOfDeath = nil
	self.textImageScore = nil
	self.wallOfDeathSpeed = 4
	
	self.gameState = gameStates.created
	
	spriteCycler = SpriteCycler()
	
	self.spritesLoaded = false
end

function GameScene:load(config)
	Scene.load(self)
	
	if config ~= nil then
		self.config = config
	elseif self.config == nil then
		print("Error: No config found")
		sceneManager:switchScene(menuScene, nil)
		return
	end
	
	local theme = self.config.theme
	
	print("Load!")
	
	self.gameState = gameStates.loading
	
	-- Draw Background
	
	if theme ~= 0 then
		self.levelTheme = levels[theme]
	end
	
	if AppConfig.enableParalaxBackground and self.levelTheme ~= nil then
		self.background = ParalaxBackground.new()
		self.background:loadForTheme(self.levelTheme)
		
		self.background:setParalaxDrawingRatios()
	end
	
	-- Set up sprites
	
	local chunkLength = AppConfig["chunkLength"]
	local recycledSpriteIds = {"platform", "killBlock", "coin"}
	spriteCycler:load(self.config, chunkLength, recycledSpriteIds)
	
	if not self.spritesLoaded then
		
		-- Create Player sprite
		
		self.wheel = Wheel.new()
		
		-- Draw Score Text
		
		self.textImageScore = Score.new("Score: 0")
		
		-- Create great wall of death
		
		if AppConfig.enableComponents.wallOfDeath then
			self.wallOfDeath = WallOfDeath.new(self.wallOfDeathSpeed)
		end
		
		-- Generate Level
		
		self.spritesLoaded = true
	end
end

function GameScene:present()
	Scene.present(self)
	
	print("Game Scene Present")
	
	-- Reset sprites
	
	self.wheel:resetValues()
	self.wheel:setAwaitingInput()
	
	-- Position Sprites
	
	self.wheel:moveTo(80, 188)
	
	if AppConfig.enableComponents.wallOfDeath then
		self.wallOfDeath:moveTo(-600, 0)
		self.wallOfDeath:add()
	end
	
	-- Set randomly generated sprite positions
	
	self.wheel:add()
	self.textImageScore:add()
	
	-- Set background drawing callback
	
	if AppConfig.enableParalaxBackground and self.levelTheme ~= nil then
		local callback = self.background:getBackgroundDrawingCallback()
		
		gfx.sprite.setBackgroundDrawingCallback(callback)
		
		self.background:add()
	end
	
	-- Set game as ready to start
	
	self.gameState = gameStates.readyToStart
	
	spriteCycler.createSpriteCallback = function(id, position, config, spriteToRecycle)
		local sprite;
		
		if id == "platform" then
			sprite = Platform.new(GRID_SIZE, GRID_SIZE, false)
		elseif id == "killBlock" then
			sprite = KillBlock.new()
		elseif id == "coin" then
			sprite = Coin.new()
		else 
			print("Unrecognized ID: ".. id)
		end
		
		sprite:moveTo(GRID_SIZE * position.x, GRID_SIZE * position.y)
		sprite:add()
		
		return sprite
	end
	
	-- Initialize Sprite cycling using initial position
	
	spriteCycler:initialize(1, 1)
	
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
	
	-- Update Blinker
	
	if blinker ~= nil then
		blinker:update()
		if levelCompleteSprite ~= nil then	
			levelCompleteSprite:setVisible(blinker.on)
		end
	end
	
	--
	
	if self.wheel.x > (MAX_CHUNKS + 1) * CHUNK_LENGTH then
		
		if self.config.level ~= nil then
			local nextLevel = self.config.level + 1
			onLevelComplete(nextLevel)
		else
			onLevelComplete() 
		end
	end
	
	-- On game start
	
	if self.gameState == gameStates.readyToStart then
		-- Awaiting player input (jump / crank)
		if buttons.isUpButtonJustPressed() or (math.abs(playdate.getCrankChange()) > 5) then
			self.wheel:startGame()
			
			if AppConfig.enableComponents.wallOfDeath then
				self.wallOfDeath:beginMoving()
			end
			
			self.gameState = gameStates.playing
		end
	end
	
	if self.gameState ~= gameStates.playing then
		return
	end
	
	-- Update screen position based on wheel
	
	local drawOffset = gfx.getDrawOffset()
	local relativeX = self.wheel.x + drawOffset
	if relativeX > 150 then
		gfx.setDrawOffset(-self.wheel.x + 150, 0)
	elseif relativeX < 80 then
		gfx.setDrawOffset(-self.wheel.x + 80, 0)
	end
	
	-- Game State checking
	
	if self.wheel.hasJustDied then
		self.gameState = gameStates.ended
		
		if AppConfig.enableComponents.wallOfDeath then
			self.wallOfDeath:stopMoving()
		end
	end
	
	-- Update image score
	
	self.textImageScore:setScoreText(self.wheel:getScoreText())
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

function onLevelComplete(nextLevel)
	if levelCompleteSprite ~= nil then
		return
	end
			
	addLevelCompleteSprite()
		
	timer.performAfterDelay(3000,
		function ()
			levelCompleteSprite:remove()
			levelCompleteSprite = nil
			
			if nextLevel ~= nil and nextLevel < 4 then
			    sceneManager:switchScene(scenes.game, function() end, GameConfig.getLevelConfig(nextLevel))
			else 
				sceneManager:switchScene(scenes.menu, function() end)
			end
			
		end
	)
end

function loadProceduralSprites(components)
	if AppConfig.enableComponents.wind and components.wind then
		print("Wind")
		SpriteData:registerSprite("Wind", Wind)
		SpriteData:setInitializerParams("Wind")
		SpriteData:setPositioning("Wind", 1, { yRange = { 40, 100 } } )
	end
	
	if AppConfig.enableComponents.coin and components.coin then
		print("Coin")
		SpriteData:registerSprite("Coin", Coin)
		SpriteData:setInitializerParams("Coin")
		SpriteData:setPositioning("Coin", 2, { yRange = { 30, 200 } } )
	end
	
	if AppConfig.enableComponents.platformMoving and components.platformMoving then
		print("PlatformMoving")
		SpriteData:registerSprite("Platform/moving", Platform)
		SpriteData:setInitializerParams("Platform/moving", 100, 20, true)
		SpriteData:setPositioning("Platform/moving", 1, { yRange = { 130, 170 } } )
	end
	
	if AppConfig.enableComponents.killBlock and components.killBlock then
		print("Kill Block")
		SpriteData:registerSprite("Kill Block", KillBlock)
		SpriteData:setInitializerParams("Kill Block")
		SpriteData:setPositioning("Kill Block", 1, { yRange = { 20, 180 } } )
	end
	
	if AppConfig.enableComponents.platformFloor and components.platformFloor then
		print("PlatformFloor")
		SpriteData:registerSprite("Platform/floor", Platform)
		SpriteData:setInitializerParams("Platform/floor", CHUNK_LENGTH, 20, false)
		SpriteData:setPositioning("Platform/floor", 1, { x = 0, y = 220 }, MAX_CHUNKS + 2 )
	end
end

function addLevelCompleteSprite()
	levelCompleteSprite = sizedTextSprite("LEVEL COMPLETE", 3)
	
	levelCompleteSprite:setImage(levelCompleteSprite:getImage():invertedImage())
	levelCompleteSprite:setIgnoresDrawOffset(true)
	
	levelCompleteSprite:add()
	levelCompleteSprite:moveTo(10, 110)

	blinker = defaultBlinker(300, 100)
	blinker:startLoop()
end