local gfx <const> = playdate.graphics
local geo <const> = playdate.geometry

function frame(widget, config)
	config = config or {}
	
	if config.isVisible ~= nil then
		widget._state.isVisible = config.isVisible
	else
		widget._state.isVisible = true
	end
	
	function widget:setFrame(rect)
		self.frame:set(rect)
		
		if self.sprite ~= nil then
			self.sprite:setBounds(rect.x, rect.y, rect.w, rect.h)
		end
	end
	
	function widget:createSprite(zIndex)
		local sprite = gfx.sprite.new()
		local frame = self.frame 
		sprite:setBounds(frame.x, frame.y, frame.w, frame.h)
		--sprite:setCenter(0, 0)
		sprite:setZIndex(zIndex or -32768)
		sprite:setIgnoresDrawOffset(true)
		sprite:setUpdatesEnabled(false)
		sprite:add()
		
		local _drawRect = geo.rect.new(0, 0, 0, 0)
		sprite.draw = function(_, x, y, w, h)
			_drawRect:set(x, y, w, h)
			self:draw(_drawRect)
		end
		
		self.sprite = sprite
	end
	
	function widget:isVisible()
		return self._state.isVisible
	end

	widget.frame = geo.rect.new(0,0,0,0)
	widget.rects = table.create(0, 5)

	local isVisibleActual = widget._state.isVisible
	
	function widget:setVisible(isVisibleNew)
		isVisibleActual = isVisibleNew
	end
	
	local _state = widget._state
	local _frame = widget.frame
	local _draw = nil
	
	function widget:draw(rect)
		if _draw == nil then
			return
		end
		
		if (_state.isLoaded and _state.isVisible) == false then
			return
		end
	
		_draw(self, _frame, rect)
	end
	
	widget:_addLoadCallback(function(self)
		_draw = self._draw
	end)
	
	widget:_addUpdateCallback(function(self)
		if self._state.isVisible ~= isVisibleActual then
			self._state.isVisible = isVisibleActual
		end
	end)
end

Widget.register("frame", frame)