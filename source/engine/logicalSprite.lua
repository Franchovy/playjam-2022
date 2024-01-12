class("LogicalSprite").extends()

local _createSpriteCallback = function() error("Not implemented") end
local _createSpriteFromIdCallback = function() error("Not implemented") end
local _saveConfigCallback = function() error("Not implemented") end
local _discardConfigCallback = function() error("Not implemented") end
local _loadConfigCallback = function() error("Not implemented") end

function LogicalSprite.setCreateSpriteCallback(callback)
	_createSpriteCallback = callback
end

function LogicalSprite.setCreateSpriteFromIdCallback(callback)
	_createSpriteFromIdCallback = callback
end

function LogicalSprite.setSaveConfigCallback(callback)
	_saveConfigCallback = callback
end

function LogicalSprite.setLoadConfigCallback(callback)
	_loadConfigCallback = callback
end

function LogicalSprite.setDiscardConfigCallback(callback)
	_discardConfigCallback = callback
end

function LogicalSprite.createSpriteFromId(id)
	return _createSpriteFromIdCallback(id)
end

function LogicalSprite:createSprite(spriteToRecycle)
	self.sprite = _createSpriteCallback(self, spriteToRecycle)
end

function LogicalSprite:discardConfig(shouldDiscardAll)
	_discardConfigCallback(self, shouldDiscardAll)
end

function LogicalSprite:loadConfig()
	_loadConfigCallback(self)
end

function LogicalSprite:saveConfig()
	_saveConfigCallback(self)
end

function LogicalSprite.loadObjects(levelObjects)
	local objects = table.create(#levelObjects, 0)
	local _insert = table.insert
	for _, object in pairs(levelObjects) do
		_insert(objects, LogicalSprite(object))
	end
	return objects
end

function LogicalSprite:init(object)
	self.id = object.id
	self.position = {
		x = object.position.x,
		y = object.position.y,
	}
	self.config = object.config
	self.isActive = false
	self.sprite = nil
end