local blinker = playdate.graphics.animation.blinker

local _new = blinker.new
function blinker.new(...)
	self = _new(...)
	
	self.hasJustChanged = false
	self._onPrev = nil
	
	return self
end

local _update = blinker.update
function blinker:update()
	_update(self)
	
	self.hasJustChanged = self._onPrev ~= self.on
	self._onPrev = self.on
end