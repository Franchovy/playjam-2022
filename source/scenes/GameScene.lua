import "engine"
import "levelgenerator"

class('GameScene').extends(Scene)

GameScene.type = sceneTypes.gameScene

local wheel = nil
local floorPlatform = nil
local killBlocks = {}
local platforms = {}
local coins = {}

local textImageScore=nil

local winds = {}
local fullWind=8
local nbrRaw=2

local numCoins = 60
local numKillBlocks = 80
local numPlatforms = 20
local numWinds = 15

function GameScene:init()
	Scene.init(self)
	
	self:setImage(gfx.image.new("images/background_clouds"):scaledImage(2))
	self:setZIndex(-2)
	self:setIgnoresDrawOffset(true)
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
	
	wheel = Wheel.new(gfx.image.new("images/wheel1"))
	
	-- Draw Score Text
	
	local scoreText = wheel:getScoreText()
	local scoreTextWidth, scoreTextHeight = gfx.getTextSize(scoreText)
	local imageScore = gfx.image.new(scoreTextWidth, scoreTextHeight)
	textImageScore = gfx.sprite.new(imageScore)
	
	gfx.pushContext(imageScore)
	gfx.drawTextAligned(scoreText, 0, 0, textAlignment.left)
	gfx.popContext()
	
	textImageScore:setIgnoresDrawOffset(true)
	
	-- Create Floor sprite
	
	floorPlatform = Platform.new(gfx.image.new(9000, 20))
	
	-- Generate Level
	
	generator:registerSprite(Wind, numWinds, gfx.image.new("images/wind"):scaledImage(6, 4), -4)
	generator:registerSprite(KillBlock, numKillBlocks, gfx.image.new("images/kill_block"))
	generator:registerSprite(Platform, numPlatforms, gfx.image.new(400, 20))
	generator:registerSprite(Coin, numCoins, gfx.image.new("images/coin"))
end

function GameScene:present()
	Scene.present(self)
	
	-- Reset sprites
	
	wheel:resetValues()
	wheel:setAwaitingInput()
	
	-- Position Sprites
	
	wheel:moveTo(80, 100)
	textImageScore:moveTo(42, 28)
	floorPlatform:moveTo(0, 220)
	
	-- Set randomly generated sprite positions
	
	generator:setSpritePositionsRandomGeneration(Wind, 300, 400, 1300, 50, 200)
	generator:setSpritePositionsRandomGeneration(Coin, 200, 30, 100, 50, 200)
	generator:setSpritePositionsRandomGeneration(Wind, 300, 400, 1200, 50, 200)
	generator:setSpritePositionsRandomGeneration(Platform, 200, 400, 1300, 140, 180)
	generator:setSpritePositionsRandomGeneration(KillBlock, 500, 20, 120, 20, 140)
	
	generator:loadLevelBegin()
	
	wheel:add()
	floorPlatform:add()
end

function GameScene:update()
	Scene.update(self)
	
	generator:updateSpritesInView()
	
	-- Update screen position
	
	local drawOffset = gfx.getDrawOffset()
	local relativeX = wheel.x + drawOffset
	--print(relativeX) -new
	if relativeX > 150 then
		gfx.setDrawOffset(-wheel.x + 150, 0)
	elseif relativeX < 80 then
		gfx.setDrawOffset(-wheel.x + 80, 0)
	end
	
	-- Game State checking
	
	if wheel.hasJustDied then
		notify.playerHasDied = true
	end
	
	-- Update image score
	
	local scoreText = wheel:getScoreText()
	local scoreTextWidth, scoreTextHeight = gfx.getTextSize(scoreText)
	local imageScore = gfx.image.new(scoreTextWidth, scoreTextHeight)
	
	gfx.pushContext(imageScore)
	gfx.drawTextAligned(wheel:getScoreText(), 0, 0, textAlignment.left)
	gfx.popContext()
	
	textImageScore:setImage(imageScore)
end

function GameScene:dismiss()
	Scene.dismiss(self)
end

function GameScene:destroy()
	Scene.destroy(self)
end