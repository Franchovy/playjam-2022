import "engine"
import "utils/text"
import "scenes"

class('GameOverScene').extends(Scene)

--------------------
-- Lifecycle Methods

function GameOverScene:init()
	Scene.init(self)
end

function GameOverScene:load()
	Scene.load(self)
	
	-- TODO: these should be images (draw), not sprites.
	
	-- Titles
	
	self.gameOverTextSprite = sizedTextSprite("*Game Over*", 2)
	self.gameOverTextSprite:moveTo(120, 80)
	self.tryAgainTextSprite = self:createTextSprite("*Try again?*", 200, 160)
	self.pressAIndicatorTextSprite = self:createTextSprite("** *Press A* **", 200, 190)
	
	-- Blinker
	
	self.pressAIndicatorBlinker = playdate.graphics.animation.blinker.new(750, 600, true, nil, false)
	
	self:loadComplete()
end

function GameOverScene:present()
	Scene.present(self)
	
	playdate.graphics.setBackgroundColor(playdate.graphics.kColorWhite)
	
	-- Start running blinker
	
	self.pressAIndicatorBlinker:startLoop()
	
	-- Add Sprites to screen
	
	self.tryAgainTextSprite:add()
	self.pressAIndicatorTextSprite:add()
	self.gameOverTextSprite:add()
	
	
end

function GameOverScene:update() 
	-- Update blinker display
	
	self.pressAIndicatorBlinker:update()
	self.pressAIndicatorTextSprite:setVisible(self.pressAIndicatorBlinker.on)
	
	-- Detect player "press A"
	if self.isFinishedTransitioning then
		if playdate.buttonJustPressed(playdate.kButtonA) then
			sceneManager:switchScene(scenes.game, function () end)
		elseif playdate.buttonJustPressed(playdate.kButtonB) then
			sceneManager:switchScene(scenes.menu, function () end)
		end
	end
end

function GameOverScene:dismiss()
	Scene.dismiss(self)
	
	playdate.graphics.setBackgroundColor(playdate.graphics.kColorClear)
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
