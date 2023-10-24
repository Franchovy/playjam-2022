
-- TODO:
-- This is kind of a draft file. Not really for use, since we want to instead migrate
-- the "Scene" class which is already in use.
--
-- This scene class adds an implementation of hierarchy and callback, using a tree of active scenes to manage add/remove of scene.

class("SceneV2").extends()

-- local gameScene = Scene()
-- gameScene:present()

function SceneV2:init()
	
end

SceneV2._scenes = {}

function SceneV2:present(scene)
	if scene == nil then
		self:_scenePresentInitial()
	else
		self:_scenePresent(scene)
	end
end

function SceneV2:_scenePresentInitial()
	assert(SceneV2._scenes == nil and #SceneV2._scenes == 0, "Only an initial scene can be presented without a parent. Use <Parent Scene>:present(<child scene>) to present further scenes.")
	
	-- Create tree with initial node
	SceneV2._scenes = Tree(self)
	
	-- TODO: Scene present
end

function SceneV2:_scenePresent(scene)
	table.insert(SceneV2._scenes, scene)
	
	local parentNode = SceneV2._scenes:find(self)
	SceneV2._scenes:addChild(parentNode, scene)
end