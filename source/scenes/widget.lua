class("Widget").extends()

Widget.topLevelWidget = nil

function Widget:init()
	self.children = {}
end

function Widget.setBackgroundDrawingCallback()
	playdate.graphics.sprite.setBackgroundDrawingCallback(
		function( x, y, width, height )
			Widget.draw()
		end
	)
end

function Widget:addChild(child)
	table.insert(self.children, child)
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
		
		Widget.topLevelWidget:draw()
	else
		for _, child in pairs(self.children) do
			child:draw()
		end
	end
end