class("Widget").extends()

Widget.topLevelWidget = nil

function Widget:init()
	self.children = {}
	self.position = { x = 0, y = 0 }
end

function Widget.setBackgroundDrawingCallback()
	playdate.graphics.sprite.setBackgroundDrawingCallback(
		function( x, y, width, height )
			Widget.draw()
		end
	)
end

function Widget:load()
	
end

function Widget:setPosition(x, y)
	self.position = { x = x, y = y }
end

function Widget:addChild(child)
	table.insert(self.children, child)
end

function Widget:removeChild(child)
	table.removevalue(self.children, child)	
end

function Widget.update(self)
	if self == nil then
		if Widget.topLevelWidget == nil then
			return
		end
		
		Widget.topLevelWidget:update()
	else 
		for _, child in pairs(self.children) do
			child:update()
		end
	end
end

function Widget.draw(self)
	if self == nil then
		if Widget.topLevelWidget == nil then
			return
		end
		
		Widget.topLevelWidget:draw(Widget.topLevelWidget.position, Widget.topLevelWidget.children)
	end
end