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
	
	spriteCycler = SpriteCycler(AppConfig["chunkLength"])
	
	self.spritesLoaded = false
	--ChunkGenerator:configure(MAX_CHUNKS + 2, CHUNK_LENGTH)
	--SpritePositionManager:configure(MAX_CHUNKS, CHUNK_LENGTH)
end

-- TODO: Components frequency

-- config: { theme: [0,1,2,3], components: {
-- 	1 - Wind
--  2 - Coin, freq. 
-- }, (OR)
-- gameObjects: { (CHUNK) 1 = {
--	id = 1, x = 5, y = 10
-- }, (CHUNK) 2 = { ... }
-- }

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
	
	if self.config.components ~= nil then
		print("Level Mode: Procedural")
		--loadProceduralSprites(self.config.components)
	elseif self.config.objects ~= nil then
		print("Level Mode: Scripted")
		
		printTable(self.config)
		
		spriteCycler:load(self.config)
	end
	
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
	
	--ChunkGenerator:initialLoadChunks(4)
	spriteCycler:initializeChunks({1, 2}, function(id, position, config)
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
		
		return sprite
	end)
	
	-- Play music
	
	if AppConfig.enableBackgroundMusic and self.levelTheme ~= nil then
		self.filePlayer = FilePlayer(self.levelTheme:getMusicFilepath())
		
		self.filePlayer:play()
	end
end

function GameScene:update()
	Scene.update(self)
	
	-- Update background parallax based on current offset
	
	if AppConfig.enableParalaxBackground and self.levelTheme ~= nil then
		local drawOffsetX, _ = gfx.getDrawOffset()
		self.background:setParalaxDrawOffset(drawOffsetX)
	end
	
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
	
	--
	
	local currentChunk = math.ceil((self.wheel.x + 1) / CHUNK_LENGTH) 
	local chunksToLoad = {currentChunk, currentChunk + 1}
	
	spriteCycler:activateChunks(chunksToLoad, function(sprite) 
		print("Activate sprite: ".. tostring(sprite))
		sprite:add()
		printTable(sprite)
	end)
	
	--ChunkGenerator:updateChunks()
	
	--
	
	--local sprites = SpriteLoader:getAllSprites()
	
	--local minGeneratedX = -gfx.getDrawOffset() - 400
	--local maxGeneratedX = -gfx.getDrawOffset() + 400 + 400
	
	--for _, sprite in pairs(sprites) do
		--if (sprite.x + sprite.width < minGeneratedX) or (sprite.x > maxGeneratedX) then
			-- Sprite is out of loaded area
			--sprite:remove()
		--else
			-- Sprite has entered loading area
			--sprite:add()
		--end
	--end
	
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
	
	--SpriteData:reset()
	
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