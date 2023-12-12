class("WidgetTransition").extends(Widget)

function WidgetTransition:init()
	self:supply(Widget.kDeps.state)
	self:supply(Widget.kDeps.animators)
	self:supply(Widget.kDeps.samples)
	
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
	
	self:loadSample(kAssetsSounds.transitionSwoosh, 0.8, "swoosh")
	self:loadSample(kAssetsSounds.transitionSlam, 0.8, "slam")
	self:loadSample(kAssetsSounds.transitionOut, 0.8, "out")
end

function WidgetTransition:_draw(frame)
	local animatorValue = self:getAnimatorValue(self.animators.animator)
	self.painters.screen:draw(Rect.offset(frame, animatorValue, 0))
end

function WidgetTransition:_update()
	if self:isAnimating() then
		playdate.graphics.sprite.addDirtyRect(0, 0, 400, 240)
	end
end

function WidgetTransition:changeState(stateFrom, stateTo)
	if stateFrom == self.kStates.open and stateTo == self.kStates.closed then
		self.animators.animator = playdate.graphics.animator.new(400, -400, 0, playdate.easingFunctions.inQuad, 100)
		self:playSample("swoosh")
		
		self.animators.animator.finishedCallback = function()
			self:playSample("slam")
			
			if self.signals.animationFinished ~= nil then
				self.signals.animationFinished()
			end
		end
	end
	
	if stateFrom == self.kStates.closed and stateTo == self.kStates.open then
		self.animators.animator = playdate.graphics.animator.new(600, 0, -400, playdate.easingFunctions.inQuint)
		self:playSample("out")
		
		self.animators.animator.finishedCallback = function()
			if self.signals.animationFinished ~= nil then
				self.signals.animationFinished()
			end
		end
	end
end