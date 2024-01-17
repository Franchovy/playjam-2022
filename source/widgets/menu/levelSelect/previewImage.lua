local gfx <const> = playdate.graphics
class("LevelSelectPreviewImage").extends(Widget)

function Widget:init(config)
	self.config = config
	
	self.images = {}
	self.painters = {}
end

function Widget:_load()
	self.images.image = gfx.image.new(self.config.path)
	self.images.title = gfx.imageWithText(self.config.title, 100, 20):scaledImage(1.5)
	
	self.painters.title = Painter(function(rect)
		gfx.setColor(gfx.kColorBlack)
		gfx.fillRoundRect(rect.x, rect.y, rect.w, rect.h, 6)
		
		local insetRect = Rect.inset(rect, 1, 1, 2, 2)
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRoundRect(insetRect.x, insetRect.y, insetRect.w, insetRect.h, 5)
		
		self.images.title:drawCentered(rect.x + rect.w / 2, rect.y + rect.h / 2)
	end)
end

function Widget:_draw(frame, rect)
	self.images.image:drawCentered(frame.x + frame.w / 2, frame.y + frame.h / 2 - 15)
	
	local rectTitle = Rect.with(Rect.center(Rect.size(125, 30), frame), { y = 170 })
	self.painters.title:draw(rectTitle)
end

function Widget:_update()
	
end

function Widget:_unload()
	self.painters = nil
	self.images = nil
end