import "engine"

class('GameOverScene').extends(gfx.sprite)

GameOverScene.type = sceneTypes.gameOver

function GameOverScene:init()
	
	-------------
	-- Titles
	
	-- "Game Over" main title
	self.gameOverTextSprite = self:addTextSprite("*Game Over*", 200, 120)
	
	-- "Try again?" subtitle
	self.tryAgainTextSprite = self:addTextSprite("Try again?", 200, 160)
	
	-- "Press A" indicator text
	self.pressAIndicatorTextSprite = self:addTextSprite("*Press A*", 200, 190)
	
	-----------
	-- Blinker
	
	-- Create Blinker for "Press A" indicator text
	self.pressAIndicatorBlinker = gfx.animation.blinker.new()
	-- Set start state to "off"
	self.pressAIndicatorBlinker.default = false
	self.pressAIndicatorBlinker.onDuration = 750
	self.pressAIndicatorBlinker.offDuration = 600
	-- Start running blinker
	self.pressAIndicatorBlinker:startLoop()
	
	----------
	-- Other
	
	-- Add self to screen
	self:add()
end

function GameOverScene:update() 
	-- Update blinker display
	self.pressAIndicatorBlinker:update()
	
	self.pressAIndicatorTextSprite:setVisible(self.pressAIndicatorBlinker.on)
end

function GameOverScene:addTextSprite(text, positionX, positionY, ignoresDrawOffset)
	local textImage = gfx.image.new(
		gfx.getTextSize(text)
	)
	
	-- Draw Text in graphics context
	gfx.pushContext(textImage)
		gfx.drawText(text, 0, 0)
	gfx.popContext()
	
	-- Create text sprite
	local textSprite = gfx.sprite.new(textImage)
	textSprite:moveTo(positionX, positionY)
	textSprite:setIgnoresDrawOffset(true)	
	
	textSprite:add()
	
	return textSprite
end