import "engine"
import "generator/spritepositionmanager"
import "generator/spriteloader"
import "generator/spritedata"
import "generator/chunkgenerator"
import "services/blinker"
import "level/levels"
import "level/theme"
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

function GameScene:init()
	Scene.init(self)
	
	--
	
	self.wheel = nil
	self.wallOfDeath = nil
	self.textImageScore = nil
	self.wallOfDeathSpeed = 4
	
	self.gameState = gameStates.created
	
	self.spritesLoaded = false
	
	ChunkGenerator:configure(MAX_CHUNKS + 2, CHUNK_LENGTH)
	SpritePositionManager:configure(MAX_CHUNKS, CHUNK_LENGTH)
end

function GameScene:load(level)
	Scene.load(self)
	
	print("Load!")
	
	self.gameState = gameStates.loading
	
	-- Draw Background
	
	self.levelTheme = levels[currentTheme]
	
	if not AppConfig.hideBackground then
		self.background = ParalaxBackground.new()
		self.background:loadForTheme(self.levelTheme)
		
		self.background:setParalaxDrawingRatios()
	end
	
	-- Set up sprites
	
	if not AppConfig.disableComponents.wind then
		SpriteData:registerSprite("Wind", Wind)
		SpriteData:setInitializerParams("Wind")
		SpriteData:setPositioning("Wind", 1, { yRange = { 40, 100 } } )
	end

	if not AppConfig.disableComponents.coin then
		SpriteData:registerSprite("Coin", Coin)
		SpriteData:setInitializerParams("Coin")
		SpriteData:setPositioning("Coin", 2, { yRange = { 30, 200 } } )
	end
	
	if not AppConfig.disableComponents.platformMoving then
		SpriteData:registerSprite("Platform/moving", Platform)
		SpriteData:setInitializerParams("Platform/moving", 100, 20, true)
		SpriteData:setPositioning("Platform/moving", 1, { yRange = { 130, 170 } } )
	end
	
	if not AppConfig.disableComponents.killBlock then
		SpriteData:registerSprite("Kill Block", KillBlock)
		SpriteData:setInitializerParams("Kill Block")
		SpriteData:setPositioning("Kill Block", 1, { yRange = { 20, 180 } } )
	end
	
	if not AppConfig.disableComponents.platformFloor then
		SpriteData:registerSprite("Platform/floor", Platform)
		SpriteData:setInitializerParams("Platform/floor", CHUNK_LENGTH, 20, false)
		SpriteData:setPositioning("Platform/floor", 1, { x = 0, y = 220 }, MAX_CHUNKS + 2 )
	end
	
	if not self.spritesLoaded then
		
		-- Create Player sprite
		
		self.wheel = Wheel.new()
		
		-- Draw Score Text
		
		self.textImageScore = Score.new("Score: 0")
		
		-- Create great wall of death
		
		if not AppConfig.disableComponents.wallOfDeath then
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
	
	if not AppConfig.disableComponents.wallOfDeath then
		self.wallOfDeath:moveTo(-600, 0)
		self.wallOfDeath:add()
	end
	
	-- Set randomly generated sprite positions
	
	self.wheel:add()
	self.textImageScore:add()
	
	-- Set background drawing callback
	
	if not AppConfig.hideBackground then
		local callback = self.background:getBackgroundDrawingCallback()
		
		gfx.sprite.setBackgroundDrawingCallback(callback)
		
		self.background:add()
	end
	
	-- Set game as ready to start
	
	self.gameState = gameStates.readyToStart
	
	ChunkGenerator:initialLoadChunks(4)
	
	-- Play music
	
	if not AppConfig.disableBackgroundMusic then
		self.filePlayer = FilePlayer(self.levelTheme:getMusicFilepath())
		
		self.filePlayer:play()
	end
end

function GameScene:update()
	Scene.update(self)
	
	-- Update background parallax based on current offset
	
	if not AppConfig.hideBackground then
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
		onLevelComplete()
	end
	
	--
	
	ChunkGenerator:updateChunks()
	
	--
	
	local sprites = SpriteLoader:getAllSprites()
	
	local minGeneratedX = -gfx.getDrawOffset() - 400
	local maxGeneratedX = -gfx.getDrawOffset() + 400 + 400
	
	for _, sprite in pairs(sprites) do
		if (sprite.x + sprite.width < minGeneratedX) or (sprite.x > maxGeneratedX) then
			-- Sprite is out of loaded area
			sprite:remove()
		else
			-- Sprite has entered loading area
			sprite:add()
		end
	end
	
	-- On game start
	
	if self.gameState == gameStates.readyToStart then
		-- Awaiting player input (jump / crank)
		if buttons.isUpButtonJustPressed() or (playdate.getCrankChange() > 5) then
			self.wheel:startGame()
			
			if not AppConfig.disableComponents.wallOfDeath then
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
		
		if not AppConfig.disableComponents.wallOfDeath then
			self.wallOfDeath:stopMoving()
		end
	end
	
	-- Update image score
	
	self.textImageScore:setScoreText(self.wheel:getScoreText())
end

function GameScene:dismiss()
	Scene.dismiss(self)
	
	if not AppConfig.disableBackgroundMusic then
		self.filePlayer:stop()
		end
end

function GameScene:destroy()
	Scene.destroy(self)
end

function onLevelComplete()
	if levelCompleteSprite ~= nil then
		return
	end
			
	addLevelCompleteSprite()
		
	timer.performAfterDelay(3000,
		function ()
			sceneManager:switchScene(scenes.menu, function() end)
		end
	)
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