import "engine"
import "generator/spritepositionmanager"
import "generator/spriteloader"
import "generator/spritedata"
import "generator/chunkgenerator"
import "services/blinker"
import "level/levels"

class('GameScene').extends(Scene)

gameStates = {
	created = "Created",
	loading = "Loading",
	readyToStart = "ReadyToStart",
	playing = "Playing",
	ended = "Ended"
}

local MAX_CHUNKS = 10
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

function GameScene:load()
	Scene.load(self)
	
	print("Load!")
	
	self.gameState = gameStates.loading
	
	-- Draw Background
	
	self.background = ParalaxBackground.new()
	self.background:loadForTheme(levels[1])
	
	self.background:setParalaxDrawingRatios()
	
	-- Set up sprites
	
	SpriteData:registerSprite("Wind", Wind)
	SpriteData:setInitializerParams("Wind", gfx.image.new("images/winds/wind1"):scaledImage(6, 4), -4)
	SpriteData:setPositioning("Wind", 1, { yRange = { 40, 100 } } )
	
	SpriteData:registerSprite("Coin", Coin)
	SpriteData:setInitializerParams("Coin")
	SpriteData:setPositioning("Coin", 2, { yRange = { 30, 200 } } )
	
	SpriteData:registerSprite("Platform/moving", Platform)
	SpriteData:setInitializerParams("Platform/moving", gfx.image.new(100, 20), true)
	--SpriteData:setPositioning("Platform/moving", 1, { yRange = { 130, 170 } } )
	
	SpriteData:registerSprite("Kill Block", KillBlock)
	SpriteData:setInitializerParams("Kill Block")
	--SpriteData:setPositioning("Kill Block", 1, { yRange = { 20, 180 } } )
	
	SpriteData:registerSprite("Platform/floor", Platform)
	SpriteData:setInitializerParams("Platform/floor", gfx.image.new(CHUNK_LENGTH, 20), false)
	SpriteData:setPositioning("Platform/floor", 1, { x = 0, y = 220 }, MAX_CHUNKS + 2 )
	
	if not self.spritesLoaded then
		
		-- Create Player sprite
		
		self.wheel = Wheel.new(gfx.image.new("images/wheel_v3/new_wheel1"))
		
		-- Draw Score Text
		
		self.textImageScore = Score.new("Score: 0")
		
		-- Create great wall of death
		
		self.wallOfDeath = WallOfDeath.new(self.wallOfDeathSpeed)
		
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
	self.wallOfDeath:moveTo(-600, 0)
	
	-- Set randomly generated sprite positions
	
	self.wheel:add()
	self.wallOfDeath:add()
	self.textImageScore:add()
	
	-- Set background drawing callback
	
	local callback = self.background:getBackgroundDrawingCallback()
	
	gfx.sprite.setBackgroundDrawingCallback(callback)
	
	self.background:add()
	
	-- Set game as ready to start
	
	self.gameState = gameStates.readyToStart
	
	ChunkGenerator:initialLoadChunks(4)
	
	-- Play music
	
	self.filePlayer = FilePlayer("music/main")
	
	self.filePlayer:play()
end

function GameScene:update()
	Scene.update(self)
	
	-- Update background paralax based on current offset
	local drawOffsetX, _ = gfx.getDrawOffset()
	self.background:setParalaxDrawOffset(drawOffsetX)
	
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
			self.wallOfDeath:beginMoving()
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
		self.wallOfDeath:stopMoving()
	end
	
	-- Update image score
	
	self.textImageScore:setScoreText(self.wheel:getScoreText())
end

function GameScene:dismiss()
	Scene.dismiss(self)
	
	self.filePlayer:stop()
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
			print("Transition!")
			
			print("Unlock new level")
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