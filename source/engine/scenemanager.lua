import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/easing"

local gfx <const> = playdate.graphics

local fadedRects = {}
for i=0,1,0.01 do
	local fadedImage = gfx.image.new(400, 240)
	gfx.pushContext(fadedImage)
		local filledRect = gfx.image.new(400, 240, gfx.kColorBlack)
		filledRect:drawFaded(0, 0, i, gfx.image.kDitherTypeBayer8x8)
	gfx.popContext()
	fadedRects[math.floor(i * 100)] = fadedImage
end
fadedRects[100] = gfx.image.new(400, 240, gfx.kColorBlack)

class('SceneManager').extends()

function SceneManager:init()
	self.transitionTime = 600
	self.transitioning = false
	self.currentScene = nil
end

sceneManager = SceneManager()

function SceneManager:setCurrentScene(scene)
	self.newScene = scene
	self.currentScene = scene

	self.currentScene:load()
	self.currentScene:present()
end

function SceneManager:switchScene(scene, onComplete)
	if self.transitioning then
		return
	end
	
	-- Update current Scene
	if self.currentScene ~= nil then 
		-- Remove previous scene as sprite
		self.currentScene:dismiss()
	end
	
	self.newScene = scene
	self.currentScene = scene
	
	-- Begin scene load
	self.currentScene:load()

	-- Start animated transition
	self:startTransition(
		function () 
			self:cleanup()
			self.currentScene:present()
		end,
		function ()
			onComplete()
		end
	)
end

function SceneManager:cleanup()
	gfx.sprite.removeAll()
	self:removeAllTimers()
	gfx.setDrawOffset(0, 0)
end

function SceneManager:startTransition(onHalfWay, onFinished)
	self.transitioning = true
	self.currentScene.isFinishedTransitioning = false
	
	-- local transitionTimer = self:fadeTransition(0, 1)
	local transitionTimer = self:wipeTransition(0, 400)

	transitionTimer.timerEndedCallback = function()
		-- transitionTimer = self:fadeTransition(1, 0)
		
		-- Call on half way completion
		onHalfWay()
		
		transitionTimer = self:wipeTransition(400, 0)
		transitionTimer.timerEndedCallback = function()
			self.transitioning = false
			self.transitionSprite:remove()
			self.currentScene.isFinishedTransitioning = true
			
			-- Temp fix to resolve bug with sprite artifacts/smearing after transition
			local allSprites = gfx.sprite.getAllSprites()
			for i=1,#allSprites do
				allSprites[i]:markDirty()
			end
			
			-- Call finished completion
			onFinished()
		end
	end
end

function SceneManager:wipeTransition(startValue, endValue)
	local transitionSprite = self:createTransitionSprite()
	transitionSprite:setClipRect(0, 0, startValue, 240)

	local transitionTimer = timer.new(self.transitionTime, startValue, endValue, easingFunctions.outBounce)
	transitionTimer.updateCallback = function(timer)
		transitionSprite:setClipRect(0, 0, timer.value, 240)
	end
	return transitionTimer
end

function SceneManager:fadeTransition(startValue, endValue)
	local transitionSprite = self:createTransitionSprite()
	transitionSprite:setImage(self:getFadedImage(startValue))

	local transitionTimer = timer.new(self.transitionTime, startValue, endValue, easingFunctions.inOutCubic)
	transitionTimer.updateCallback = function(timer)
		transitionSprite:setImage(self:getFadedImage(timer.value))
	end
	return transitionTimer
end

function SceneManager:getFadedImage(alpha)
	return fadedRects[math.floor(alpha * 100)]
end

function SceneManager:createTransitionSprite()
	local filledRect = gfx.image.new(400, 240, gfx.kColorBlack)
	local transitionSprite = gfx.sprite.new(filledRect)
	transitionSprite:moveTo(200, 120)
	transitionSprite:setZIndex(10000)
	transitionSprite:setIgnoresDrawOffset(true)
	transitionSprite:add()
	self.transitionSprite = transitionSprite
	return transitionSprite
end

function SceneManager:removeAllTimers()
	local allTimers = timer.allTimers()
	for _, timer in ipairs(allTimers) do
		timer:remove()
	end
end