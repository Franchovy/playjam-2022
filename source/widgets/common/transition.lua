class("WidgetTransition").extends(Widget)

function WidgetTransition:init()
	self:supply(Widget.kDeps.state)
	self:supply(Widget.kDeps.animators)
	
	self:createSprite(kZIndex.transition)
	
	self:setStateInitial({ open = 1, closed = 2 }, 1)
	
	self.painters = {}
	self.animators = {}
	self.signals = {}
end

function WidgetTransition:_load()
	self.painters.screen = Painter(function(rect)
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.fillRect(rect.x, rect.y, rect.w, rect.h)
	end)
end

function WidgetTransition:_draw(frame)
	local animatorValue = self:getAnimatorValue(self.animators.animator)
	self.painters.screen:draw(Rect.offset(frame, animatorValue, 0))
	
	self.frame = frame
end

function WidgetTransition:_update()
	if self:isAnimating() and (self.frame ~= nil) then
		playdate.graphics.sprite.addDirtyRect(self.frame.x, self.frame.y, self.frame.w, self.frame.h)
	end
end

function WidgetTransition:changeState(stateFrom, stateTo)
	if stateFrom == self.kStates.open and stateTo == self.kStates.closed then
		self.animators.animator = playdate.graphics.animator.new(600, -400, 0, playdate.easingFunctions.outBounce)
		
		self.animators.animator.finishedCallback = function()
			if self.signals.animationFinished ~= nil then
				self.signals.animationFinished()
			end
		end
	end
	
	if stateFrom == self.kStates.closed and stateTo == self.kStates.open then
		self.animators.animator = playdate.graphics.animator.new(600, 0, -400, playdate.easingFunctions.inQuint)
		
		self.animators.animator.finishedCallback = function()
			if self.signals.animationFinished ~= nil then
				self.signals.animationFinished()
			end
		end
	end
end