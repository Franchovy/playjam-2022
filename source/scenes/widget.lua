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
		
		Widget.topLevelWidget:draw(Widget.topLevelWidget.position)
	end
end