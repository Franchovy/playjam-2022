import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"

local gfx <const> = playdate.graphics

class("Scene").extends(gfx.sprite)

local allScenes = {}
Scene.currentActiveScene = nil

sceneState = {
	initialized = "Not Yet Loaded",
	isLoaded = "Loaded",
	isPresented = "Presented",
	isDismissed = "Dismissed"
}

function Scene:init()
	gfx.sprite.init(self)
	
	table.insert(allScenes, self)
	
	self.state = sceneState.initialized
	self.isFinishedTransitioning = true
end

function Scene:load()
	self.state = sceneState.isLoaded
end

function Scene:present()
	Scene.currentActiveScene = self
	self.state = sceneState.isPresented
	self:add()
end

function Scene:update()
	gfx.sprite.update(self)
end

function Scene:dismiss()
	self.state = sceneState.isDismissed
	self:remove()
end

function Scene:destroy()
	table.removevalue(allScenes, self)
end