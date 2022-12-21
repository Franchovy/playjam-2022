import "engine"

class('GameOverScene').extends(Scene)

--------------------
-- Lifecycle Methods

function GameOverScene:init()
	Scene.init(self)
end

function GameOverScene:load()
	Scene.load(self)
	
	-- Titles
	
	self.gameOverTextSprite = self:createTextSprite("*Game Over*", 200, 120)
	self.tryAgainTextSprite = self:createTextSprite("Try again?", 200, 160)
	self.pressAIndicatorTextSprite = self:createTextSprite("*Press A*", 200, 190)
	
	-- Blinker
	
	self.pressAIndicatorBlinker = gfx.animation.blinker.new()
	self.pressAIndicatorBlinker.default = false
	self.pressAIndicatorBlinker.onDuration = 750
	self.pressAIndicatorBlinker.offDuration = 600
end

function GameOverScene:present()
	Scene.present(self)
	
	-- Start running blinker
	
	self.pressAIndicatorBlinker:startLoop()
	
	-- Add Sprites to screen
	
	self.tryAgainTextSprite:add()
	self.pressAIndicatorTextSprite:add()
	self.gameOverTextSprite:add()
	
end

function GameOverScene:update() 
	Scene.update(self)
	
	-- Update blinker display
	
	self.pressAIndicatorBlinker:update()
	self.pressAIndicatorTextSprite:setVisible(self.pressAIndicatorBlinker.on)
	
	-- Detect player "press A"
	if self.isFinishedTransitioning then
		if buttons.isAButtonJustPressed() then
			notify.gameRestart = true
		end
	end
end

function GameOverScene:dismiss()
	Scene.dismiss(self)
	
end

function GameOverScene:destroy()
	Scene.destroy(self)
	
end

----------------
-- Other Methods

function GameOverScene:createTextSprite(text, positionX, positionY, ignoresDrawOffset)
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
	
	return textSprite
end
