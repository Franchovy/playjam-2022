class("Widget").extends()

Widget.topLevelWidget = nil

Widget.kDeps = {
	children = 1,
	state = 2
}

function Widget.init(topLevelWidget)
	Widget.setBackgroundDrawingCallback()
	
	Widget.topLevelWidget = topLevelWidget
end

function Widget.supply(widget, dep)
	if dep == Widget.kDeps.children then
		widget:_supplyDepChildren()
	elseif dep == Widget.kDeps.state then
		widget:_supplyDepState()
	end
end

function Widget._supplyDepChildren(self)
	self.children = {}
end

function Widget._supplyDepState(self)
	function self:setStateInitial(states, state)
		self.kStates = states
		self.state = state
	end
	function self:setState(targetState)
		if self.changeState ~= nil then
			self:changeState(self.state, targetState)
		end
		
		self.state = targetState
	end
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