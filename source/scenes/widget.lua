class("Widget").extends()

Widget.topLevelWidget = nil

function Widget:init()
	
end

function Widget.setBackgroundDrawingCallback()
	playdate.graphics.sprite.setBackgroundDrawingCallback(
		function( x, y, width, height )
			Widget.draw()
		end
	)
end

function Widget.update(self)
	if self == nil then
		if Widget.topLevelWidget == nil then
			return
		end
		
		Widget.topLevelWidget:update()
	end
end

function Widget.draw(self)
	if self == nil then
		if Widget.topLevelWidget == nil then
			return
		end
		
		local rect = playdate.display.getRect()
		Widget.topLevelWidget:draw(Rect.make(rect.x, rect.y, rect.width, rect.height))
	end
end