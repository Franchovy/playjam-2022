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
	
	self.loadCompleteCallback = nil
end

function Scene:load()
	self._state = sceneState.isLoaded
end

function Scene:loadComplete()
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