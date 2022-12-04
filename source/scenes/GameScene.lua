import "engine"

class('GameScene').extends(Scene)

GameScene.type = sceneTypes.gameScene

local wheel = nil
local floors = {}
local coins = {} --new

local textImageScore=nil --new


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
	
	local imageScore = gfx.image.new(30, 30)
	textImageScore = gfx.sprite.new(imageScore)
	
	gfx.pushContext(imageScore)
	gfx.drawTextAligned(wheel.score, imageScore.width / 2, imageScore.height / 2, textAlignment.center)
	gfx.popContext()
	
	textImageScore:moveTo(imageScore.width/2, imageScore.height/2)
	textImageScore:setIgnoresDrawOffset(true)
	
	-- Create Coin sprites
	for i=1,10 do
		table.insert(coins, Coin.new(gfx.image.new("images/coin")))
	end
	
	-- Create Obstacle sprites
	for i=0,28 do
		table.insert(floors, Floor.new(gfx.image.new(40, 40)))
	end
end

function GameScene:present()
	Scene.present(self)
	
	-- Reset sprites
	
	wheel:resetValues()
	wheel:setAwaitingInput()
	
	-- Position Sprites
	
	wheel:moveTo(80, 100)
	
	-- Obstacles, spread through level
	local previousObstacleX = 20
	for i=2,#floors do
		local randY = math.random(20, 140)
		local randX = math.random(20, 420)
		local newX = previousObstacleX + randX
		previousObstacleX = newX
		floors[i]:moveTo(newX, 240 - randY)
	end
	
	-- Coins, spread through level
	for i=1,#coins do
		coins[i]:moveTo(150*i,200)
	end
	
	-- Add sprites back into scene
	
	wheel:add()
	textImageScore:add()
	for i=1,#floors do
		floors[i]:add()
	end
	for i=1,#coins do
		coins[i]:add()
	end
	
	-- Actual Floor
	--floors[1]:setSize(1000, 20)
	floors[1]:moveTo(30, 200)

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
	
	local imageScore = gfx.image.new(30, 30)
	
	gfx.pushContext(imageScore)
	
	gfx.drawTextAligned(wheel.score, imageScore.width / 2, imageScore.height / 2, textAlignment.center)
	gfx.popContext()
	
	textImageScore:moveTo(imageScore.width/2, imageScore.height/2)
	textImageScore:setIgnoresDrawOffset(true)
	textImageScore:setImage(imageScore)
end

function GameScene:dismiss()
	Scene.dismiss(self)
end

function GameScene:destroy()
	Scene.destroy(self)
end