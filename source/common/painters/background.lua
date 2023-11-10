class("PainterBackground").extends(Painter)

function PainterBackground:init()
	PainterBackground.super.init(self,
		function(rect)
			playdate.graphics.setColor(playdate.graphics.kColorBlack)
			playdate.graphics.setDitherPattern(0.1, playdate.graphics.image.kDitherTypeBayer4x4)
			playdate.graphics.fillRect(0, 0, rect.w, rect.h)
		end)
end
