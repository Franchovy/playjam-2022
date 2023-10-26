import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "playdate"

local gfx <const> = playdate.graphics

class("Scene").extends()

local allScenes = {}
Scene.currentActiveScene = nil

sceneState = {
	initialized = "Not Yet Loaded",
	isLoaded = "Loaded",
	isPresented = "Presented",
	isDismissed = "Dismissed"
}

Scene.addedScenes = {}

function Scene:init()
	self._sprite = gfx.sprite.new()
	
	table.insert(allScenes, self)
	
	self._state = sceneState.initialized
	self.isFinishedTransitioning = true
	
	self.loadingDrawCallback = nil
	self.loadingDrawClearCallback = nil
	self.loadCompleteCallback = nil
end

function Scene:load()
	self._state = sceneState.isLoaded
end

function Scene:loadAsynchronously(...)
	local loadFunctions = {...}
	
	print(#loadFunctions.. " Loading functions...")
	
	local timer = playdate.timer.new(5)
	timer.repeats = true
	timer.discardOnCompletion = false
	
	local loadFunctionComplete = true
	
	timer.timerEndedArgs = { loadFunctionComplete }
	
	timer.timerEndedCallback = function(loadFunctionComplete)
		print("timer callback")
		if loadFunctionComplete then
			print("load function complete!")
				
			if #loadFunctions == 0 then
				print("all load functions complete. Ready to play")
				
				timer:remove()
				self:loadComplete()
			else
				local loadFunction = table.remove(loadFunctions, 1)
				
				print("Loading next function. Left: ".. #loadFunctions)
				
				loadFunctionComplete = loadFunction(loadFunctionComplete)
				assert(loadFunctionComplete, "Error: load function did not return 'true', was this a mistake?")
			end
		end
	end
end

function Scene:loadComplete()
	if self.loadingDrawClearCallback ~= nil then
		self.loadingDrawClearCallback()
	end
	
	if self.loadCompleteCallback ~= nil then
		self.loadCompleteCallback()
	end
end

function Scene:present()
	Scene.currentActiveScene = self
	self._state = sceneState.isPresented
	self._sprite:add()
	
	table.insert(Scene.addedScenes, self)
end

function Scene.update(self)
	if self == nil then
		for _, scene in pairs(Scene.addedScenes) do
			scene:update()
		end
	else 
		assert(false, "Cannot call Scene:update() on instance! Not implemented yet.")
	end
end

function Scene:dismiss()
	self._state = sceneState.isDismissed
	self._sprite:remove()
	
	table.removevalue(Scene.addedScenes, self)
end

function Scene:destroy()
	table.removevalue(allScenes, self)
end