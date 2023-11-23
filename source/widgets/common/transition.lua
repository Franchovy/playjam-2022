class("Transition").extends(Widget)

function Transition:init()
	self:supply(Widget.kDeps.state)
	
	self:createSprite()
	self.sprite:add()
	self.sprite:setZIndex(100)
	self.sprite:setIgnoresDrawOffset(true)
	
	self:setStateInitial({ outside = 1, inside = 2 }, 1)
	
	self.painters = {}
	self.animators = {}
end

function Transition:_load()
	self.painters.screen = Painter(function(rect)
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.setDitherPattern(0.7, playdate.graphics.image.kDitherTypeBayer8x8)
		playdate.graphics.fillRect(rect.x, rect.y, rect.w, rect.y)
	end)
	
	self.animators.animator = playdate.graphics.animator.new(0, 0, 0)
end

function Transition:_draw(rect)
	local animatorValue = self.animators.animator:currentValue()
	self.painters.screen:draw(Rect.offset(rect, animatorValue, 0))
end

function Transition:_update()
	
end

function Transition:changeState(stateFrom, stateTo)
	if stateFrom == self.kStates.outside and stateTo == self.kStates.inside then
		self.animators.animator = playdate.graphics.animator.new(700, -400, 0, playdate.easingFunctions.inCubic)
	end
	
	if stateFrom == self.kStates.inside and stateTo == self.kStates.outside then
		self.animators.animator = playdate.graphics.animator.new(700, 0, -400, playdate.easingFunctions.outCubic)
	end
end