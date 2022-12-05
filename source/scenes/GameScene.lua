import "engine"
import "levelgenerator"

class('GameScene').extends(Scene)

GameScene.type = sceneTypes.gameScene

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
end

function GameScene:load()
	Scene.load(self)
	
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
	--generator:registerSprite(Platform, numPlatforms, gfx.image.new(400, 20),false)
	generator:registerSprite(Platform, self.numPlatforms, gfx.image.new(100, 20),true)

	generator:registerSprite(Coin, self.numCoins, gfx.image.new("images/coin"))
end

function GameScene:present()

	
	Scene.present(self)
	
	-- Reset sprites
	
	self.wheel:resetValues()
	self.wheel:setAwaitingInput()
	
	-- Position Sprites
	
	self.wheel:moveTo(80, 100)
	self.floorPlatform:moveTo(0, 220)
	self.wallOfDeath:moveTo(-600, 0)
	
	-- Set randomly generated sprite positions
	
	generator:setSpritePositionsRandomGeneration(Wind, 300, 400, 1300, 50, 200)
	generator:setSpritePositionsRandomGeneration(Coin, 200, 30, 100, 50, 200)
	generator:setSpritePositionsRandomGeneration(Wind, 300, 400, 1200, 50, 200)
	generator:setSpritePositionsRandomGeneration(Platform, 200, 400, 1300, 140, 180)
	generator:setSpritePositionsRandomGeneration(KillBlock, 500, 20, 120, 20, 140)
	
	generator:loadLevelBegin()
	
	self.wheel:add()
	self.floorPlatform:add()
	self.wallOfDeath:add()
	self.textImageScore:add()
end

function GameScene:update()
	Scene.update(self)
	
	generator:updateSpritesInView()
	
	-- Update screen position
	
	local drawOffset = gfx.getDrawOffset()
	local relativeX = self.wheel.x + drawOffset
	if relativeX > 150 then
		gfx.setDrawOffset(-self.wheel.x + 150, 0)
	elseif relativeX < 80 then
		gfx.setDrawOffset(-self.wheel.x + 80, 0)
	end
	
	-- Game State checking
	
	if self.wheel.hasJustDied then
		notify.playerHasDied = true
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