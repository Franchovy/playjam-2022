class("LogicalSprite").extends()

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