class("LogicalSprite").extends()

function LogicalSprite.loadObjects(levelObjects)
	local objects = table.create(#levelObjects, 0)
	for _, object in pairs(levelObjects) do
		table.insert(objects, object)
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