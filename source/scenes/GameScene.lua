import "engine"
import "generator/spritepositionmanager"
import "generator/spriteloader"
import "generator/spritedata"

class('GameScene').extends(Scene)

GameScene.type = sceneTypes.gameScene

gameStates = {
	created = "Created",
	loading = "Loading",
	readyToStart = "ReadyToStart",
	playing = "Playing",
	ended = "Ended"
}

function GameScene:init()
	Scene.init(self)
	
	self:setImage(gfx.image.new("images/background_clouds"):scaledImage(2))
	self:setZIndex(-2)
	self:setIgnoresDrawOffset(true)
	
	self.wheel = nil
	self.wallOfDeath = nil
	self.textImageScore = nil
	self.wallOfDeathSpeed = 4
	
	self.gameState = gameStates.created
	
	self.spritesLoaded = false
end

function GameScene:load()
	Scene.load(self)
	
	print("Load!")
	
	self.gameState = gameStates.loading
	
	-- Load Music
	
	self.soundFile = sound.fileplayer.new("music/music_main")
	self.soundFile:play(0)
	self.soundFile:pause()
	
	-- Draw Background
	
	local backgroundImage = gfx.image.new("images/background")
	gfx.sprite.setBackgroundDrawingCallback(
		function()
			backgroundImage:draw(0, 0)
		end
	)
	
	-- Set up sprites
	
	SpriteData:registerSprite("Wind", Wind)
	SpriteData:setInitializerParams("Wind", gfx.image.new("images/winds/wind1"):scaledImage(6, 4), -4)
	SpriteData:setPositioning("Wind", 0, { yRange = { 40, 100 } } )
	
	SpriteData:registerSprite("Coin", Coin)
	SpriteData:setInitializerParams("Coin", gfx.image.new("images/coin"))
	SpriteData:setPositioning("Coin", 6, { yRange = { 30, 200 } } )
	
	SpriteData:registerSprite("Platform/moving", Platform)
	SpriteData:setInitializerParams("Platform/moving", gfx.image.new(100, 20), true)
	SpriteData:setPositioning("Platform/moving", 1, { yRange = { 130, 170 } } )
	
	SpriteData:registerSprite("Kill Block", KillBlock)
	SpriteData:setInitializerParams("Kill Block", gfx.image.new("images/kill_block"))
	SpriteData:setPositioning("Kill Block", 0, { yRange = { 20, 180 } } )
	
	SpriteData:registerSprite("Platform/floor", Platform)
	SpriteData:setInitializerParams("Platform/floor", gfx.image.new(1000, 20), false)
	SpriteData:setPositioning("Platform/floor", 1, { yRange = { 220, 220 } } )
	
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
	
	-- Play music
	
	self.soundFile:play(0)
	
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
	
	-- Set game as ready to start
	
	self.gameState = gameStates.readyToStart
	
	self.chunksGenerated = {0, 1, 2, 3}
	
	SpriteData:loadSpritesInChunk(0)
	SpriteData:loadSpritesInChunk(1)
	SpriteData:loadSpritesInChunk(2)
	SpriteData:loadSpritesInChunk(3)
end

function GameScene:update()
	Scene.update(self)
	
	-- Remove / Add Sprites based on range
	
	local currentChunk = math.floor((-gfx.getDrawOffset()) / 1000)
	
	--
	
	local nextChunk = currentChunk + 2
	local previousChunk = currentChunk - 1
	
	if nextChunk > self.chunksGenerated[4] and nextChunk <= 10 then
		
		self.chunksGenerated = {
			currentChunk - 1,
			currentChunk,
			currentChunk + 1,
			currentChunk + 2
		}
		
		SpriteData:recycleSpritesInChunk(self.chunksGenerated[1])
		SpriteData:loadSpritesInChunk(nextChunk)
		
	elseif previousChunk >= 0 and previousChunk < self.chunksGenerated[1] then
		
		self.chunksGenerated = {
			currentChunk - 1,
			currentChunk,
			currentChunk + 1,
			currentChunk + 2
		}
		
		SpriteData:recycleSpritesInChunk(self.chunksGenerated[4])
		SpriteData:loadSpritesInChunk(previousChunk)
	end
	
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
	
	self.soundFile:stop()
end

function GameScene:destroy()
	Scene.destroy(self)
end