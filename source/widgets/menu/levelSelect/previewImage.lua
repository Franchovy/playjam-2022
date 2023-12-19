class("LevelSelectPreviewImage").extends(Widget)


function Widget:init(config)
	self.config = config
	
	self.images = {}
end

function Widget:_load()
	self.images.image = playdate.graphics.image.new(self.config.path)
end

function Widget:_draw(frame, rect)
	self.images.image:draw(frame.x, frame.y)
end

function Widget:_update()
	
end