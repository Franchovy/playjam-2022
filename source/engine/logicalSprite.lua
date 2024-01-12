class("LogicalSprite").extends()

local _createSpriteCallback = function() error("Not implemented") end

function LogicalSprite.setCreateSpriteCallback(callback)
	_createSpriteCallback = callback
end

function LogicalSprite.createSpriteFromId(id)
	return _createSpriteCallback(id)
end

function LogicalSprite:createSprite(spriteToRecycle)
	self.sprite = _createSpriteCallback(self, spriteToRecycle)
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