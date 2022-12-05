import "engine"

class('GameScene').extends(Scene)

GameScene.type = sceneTypes.gameScene

local wheel = nil
local killBlocks = {}
local platforms = {}
local coins = {}

local textImageScore=nil

local winds = {}
local fullWind=8
local nbrRaw=2

function GameScene:init()
	Scene.init(self)
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
	
	local numCoins = 10
	local numKillBlocks = 28
	local numPlatforms = 3
	local numWinds = 5
	
	-- Create Coin sprites
	for i=1,numCoins do
		table.insert(coins, Coin.new(gfx.image.new("images/coin")))
	end
	
	-- Create Obstacle sprites
	for i=0,numKillBlocks do
		table.insert(killBlocks, KillBlock.new(gfx.image.new(40, 40)))
	end
	
	-- Create Platform sprites
	for i=1,numPlatforms do
		table.insert(platforms, Platform.new(gfx.image.new(4000, 20)))
	end
	
	-- Create wind sprites
	for i=1,numWinds do
		table.insert(winds, Wind.new(gfx.image.new("images/wind"):scaledImage(6, 4),-1))
	end
end

function GameScene:present()
	Scene.present(self)
	
	-- Reset sprites
	
	wheel:resetValues()
	wheel:setAwaitingInput()
	
	-- Position Sprites
	
	wheel:moveTo(80, 100)
	textImageScore:moveTo(42, 28)
	
	-- Obstacles, spread through level
	local previousObstacleX = 500
	for i=1,#killBlocks do
		local randY = math.random(20, 140)
		local randX = math.random(20, 420)
		local newX = previousObstacleX + randX
		previousObstacleX = newX
		killBlocks[i]:moveTo(newX, 240 - randY)
	end
		
	-- Wind, spread through level
	local windSizeX=winds[1]:getSize()
	local windSizeY=winds[1]:getSize()
	local distanceBeetwenWinds=200
	local firstWindPosX=300
	for i=1,#winds/fullWind do 
		for k=1,nbrRaw do
			for j=1,fullWind/nbrRaw do
				local x = firstWindPosX+(distanceBeetwenWinds+(fullWind/nbrRaw*windSizeX))*(i-1) +windSizeX*j
				local y = 50+windSizeY*(k-1)
				local index = (i-1)*fullWind+(fullWind/nbrRaw)*(k-1)+j
				
				winds[index]:moveTo(x,y)
			end
		end
	end
	
	-- Floor Platform, only two for now
	platforms[1]:moveTo(0, 230)
	platforms[2]:moveTo(0, -10)
	platforms[3]:moveTo(300, 210)
	
	-- Coins, spread through level
	for i=1,#coins do
		coins[i]:moveTo(150*i,200)
	end
	
	-- Add sprites back into scene
	
	for i=1,#winds do
		winds[i]:add()
	end
	for i=1,#coins do
		coins[i]:add()
	end
	for i=1,#killBlocks do
		killBlocks[i]:add()
	end
	for i=1,#platforms do
		platforms[i]:add()
	end	
	textImageScore:add()
	wheel:add()

end

function GameScene:update()
	Scene.update(self)
	
	
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