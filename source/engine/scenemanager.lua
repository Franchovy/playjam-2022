import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/easing"

local gfx <const> = playdate.graphics

class('SceneManager').extends()

function SceneManager:init()
	self.transitionTime = 600
	self.transitioning = false
	self.currentScene = nil
end

sceneManager = SceneManager()

function SceneManager:setCurrentScene(scene)
	self.currentScene = scene
	
	self.currentScene.loadCompleteCallback = function() 
		self.currentScene:present()
	end
	
	self.currentScene:load()
end

function SceneManager:switchScene(scene, onComplete, ...)
	if self.transitioning then
		return
	end
	
	local args = {...}
	
	-- Update current Scene
	if self.currentScene ~= nil then 
		-- Remove previous scene as sprite
		self.currentScene:dismiss()
	end
	
	self.currentScene = scene
	
	-- Start animated transition
	self:startTransition(
		function (loadCompleteTransitionCallback) 
			-- Setup
			
			self.currentScene.loadCompleteCallback = function() 
				-- clear background color
				
				playdate.graphics.setBackgroundColor(playdate.graphics.kColorClear)
				
				-- wipe transition
				
				loadCompleteTransitionCallback()
				
				-- scene present
				
				self.currentScene:present()
			end
			
			-- Set background color
			
			playdate.graphics.setBackgroundColor(playdate.graphics.kColorBlack)
			
			-- Draw loading screen
			
			if self.currentScene.loadingDrawCallback ~= nil then
				self.currentScene:loadingDrawCallback()
			end
			
			-- Start Loading after a short delay - allowing for draw
			
			playdate.timer.performAfterDelay(1, function()
				-- Begin scene load
				self.currentScene:load(table.unpack(args))
			end)
		end,
		function ()
			if onComplete ~= nil then
				onComplete()
			end
		end
	)
end

function SceneManager:cleanup()
	gfx.sprite.removeAll()
	gfx.setDrawOffset(0, 0)
end

function SceneManager:startTransition(onHalfWay, onFinished)
	self.transitioning = true
	self.currentScene.isFinishedTransitioning = false
	
	local transitionTimer = self:wipeTransition(0, 400)

	transitionTimer.timerEndedCallback = function()
		-- Cleanup previous scene
		-- TODO: Make this scene-specific
		self:cleanup()
		
		function loadCompleteCallback()
			local transitionTimer = self:wipeTransition(400, 0)
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
		
		-- Call on half way completion
		onHalfWay(loadCompleteCallback)
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

function SceneManager:createTransitionSprite()
	local filledRect = gfx.image.new(400, 240, gfx.kColorBlack)
	local transitionSprite = gfx.sprite.new(filledRect)
	transitionSprite:moveTo(200, 120)
	--transitionSprite:setZIndex(1)
	transitionSprite:setIgnoresDrawOffset(true)
	transitionSprite:add()
	self.transitionSprite = transitionSprite
	return transitionSprite
end
