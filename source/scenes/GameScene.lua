import "engine"
import "levelgenerator"
import "generator/spritepositionmanager"
import "generator/spriteloader"

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
	
	-- "Coin", Coin, self.numCoins, gfx.image.new("images/coin"))
	-- "Platform.moving", Platform, self.numPlatforms, gfx.image.new(100, 20), true)
	-- "KillBlock", KillBlock, self.numKillBlocks, gfx.image.new("images/kill_block"))
	-- "Platform.ground", Platform, 3, gfx.image.new(3000, 20), false)
	self.spriteData = {
		{
			name = "Wind",
			className = Wind,
			yRange = {
				top = 40,
				bottom = 100
			},
			initParams = {
				gfx.image.new("images/winds/wind1"):scaledImage(6, 4), -4
			},
			
		}
	}
	
	if not self.spritesLoaded then
		
		-- Create Player sprite
		
		self.wheel = Wheel.new(gfx.image.new("images/wheel_v3/new_wheel1"))
		
		-- Draw Score Text
		
		self.textImageScore = Score.new("Score: 0")
		
		-- Create great wall of death
		
		self.wallOfDeath = WallOfDeath.new(self.wallOfDeathSpeed)
		
		-- Generate Level
		
		for _, spriteData in pairs(self.spriteData) do
			SpriteLoader:registerSprite(spriteData.name)
		end
		
		self.spritesLoaded = true
	end
	
	self.loadedChunks = {}
	
	-- Create sprite positions
	for _, spriteData in pairs(self.spriteData) do
		SpritePositionManager:populate(spriteData.name, spriteData.yRange)
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
	
	
	-- TODO: Move
	self.assignedPositions = {}
end

function GameScene:update()
	Scene.update(self)
	
	--
	
	-- Remove / Add Sprites based on range
	
	local chunk = math.floor((-gfx.getDrawOffset()) / 1000)

	-- TODO: - Improve chunks being loaded
	local chunkToLoad = chunk + 1
	
	if self.loadedChunks[chunkToLoad] ~= true then
		
		local spritePositions = SpritePositionManager:getPositionsInChunk("Wind", chunkToLoad)
		
		for _, position in pairs(spritePositions) do
			for _, spriteData in pairs(self.spriteData) do
				local name = spriteData.name
				local className = spriteData.className
				local args = spriteData.initParams
				
				-- Reuse or create new sprite
				local sprite = SpriteLoader:loadSprite(name)
				if sprite == nil then
					sprite = SpriteLoader:createSprite(name, className, args)
				end
				
				-- Move sprite to assigned position
				sprite:moveTo(position.x, position.y)
				
				-- TODO: Set Difficulty params (based on chunk)
			end
		end
		
		self.loadedChunks[chunkToLoad] = true
	end
	
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
	
	-- Update sprites
	
	generator:update()
	
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
	
	generator:degenerateAllLevels()
end

function GameScene:destroy()
	Scene.destroy(self)
end