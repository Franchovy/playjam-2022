local gfx <const> = playdate.graphics
local geo <const> = playdate.geometry

local padding = 3

class("WidgetLoadingCircle").extends(Widget)

function WidgetLoadingCircle:_init()
	self:supply(Widget.deps.frame)
end

function WidgetLoadingCircle:_load()
	self:createSprite(kZIndex.overlay)
	self.sprite:setIgnoresDrawOffset(false)
	
	self.color = self.config.color or gfx.kColorBlack
	self.backgroundColor = self.config.backgroundColor or gfx.kColorWhite
	
	self:setFrame(geo.rect.new(0, 0, self.config.size, self.config.size))
	
	local radius = self.config.size - padding * 2
	self.arc = playdate.geometry.arc.new(padding + radius / 2, padding + radius / 2, radius / 2, 0, 1)
	
	self.setProgress = function(progress)
		if progress > 0 then
			self.arc.endAngle = progress * 360
		else
			self.arc.endAngle = 1
		end
	end
	
	self.setPositionCentered = function(x, y)
		self.sprite:moveTo(x, y)
	end
end

function WidgetLoadingCircle:_draw(frame, rect)
	gfx.setColor(self.backgroundColor)
	gfx.setLineWidth(3)
	gfx.drawArc(self.arc)
	
	gfx.setColor(self.color)
	gfx.setLineWidth(2)
	gfx.drawArc(self.arc)
end