import "engine"
import "levelgenerator"

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
	self.floorPlatform = nil
	self.wallOfDeath = nil
	self.textImageScore = nil
	self.wallOfDeathSpeed = 4
	self.numCoins = 60
	self.numKillBlocks = 80
	self.numPlatforms = 20
	self.numWinds = 15
	
	self.gameState = gameStates.created
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
		
	-- Create Player sprite
	
	self.wheel = Wheel.new(gfx.image.new("images/wheel1"))
	
	-- Draw Score Text
	
	self.textImageScore = Score.new("Score: 0")
	
	-- Create Floor sprite
	
	self.floorPlatform = Platform.new(gfx.image.new(9000, 20),false)
	
	-- Create great wall of death
	
	self.wallOfDeath = WallOfDeath.new(self.wallOfDeathSpeed)
	
	-- Generate Level
	
	generator:registerSprite(Wind, self.numWinds, gfx.image.new("images/wind"):scaledImage(6, 4), -4)
	generator:registerSprite(KillBlock, self.numKillBlocks, gfx.image.new("images/kill_block"))
	generator:registerSprite(Platform, self.numPlatforms, gfx.image.new(100, 20),true)
	generator:registerSprite(Coin, self.numCoins, gfx.image.new("images/coin"))
end

function GameScene:present()
	Scene.present(self)
	
	-- Play music
	
	self.soundFile:play(0)
	
	-- Reset sprites
	
	self.wheel:resetValues()
	self.wheel:setAwaitingInput()
	
	-- Position Sprites
	
	self.wheel:moveTo(80, 188)
	self.floorPlatform:moveTo(0, 220)
	self.wallOfDeath:moveTo(-600, 0)
	
	-- Set randomly generated sprite positions
	
	generator:setSpritePositionsRandomGeneration(Wind, 300, 40, 900, 50, 200)
	generator:setSpritePositionsRandomGeneration(Coin, 200, 30, 100, 50, 200)
	generator:setSpritePositionsRandomGeneration(Wind, 300, 40, 200, 50, 200)
	generator:setSpritePositionsRandomGeneration(Platform, 200, 100, 400, 140, 180)
	generator:setSpritePositionsRandomGeneration(KillBlock, 500, 20, 220, 20, 140)
	
	generator:loadLevelBegin()
	
	self.wheel:add()
	self.floorPlatform:add()
	self.wallOfDeath:add()
	self.textImageScore:add()
	
	-- Set game as ready to start
	self.gameState = gameStates.readyToStart
end

function GameScene:update()
	Scene.update(self)
	
	generator:update()
	
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
end

function GameScene:destroy()
	Scene.destroy(self)
end