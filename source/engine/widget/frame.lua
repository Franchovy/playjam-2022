local gfx <const> = playdate.graphics
local geo <const> = playdate.geometry

function frame(widget, config)
	config = config or {}
	
	if config.isVisible ~= nil then
		widget._state.isVisible = config.isVisible
	else
		widget._state.isVisible = true
	end
	
	if config.needsLayout ~= nil then
		widget._state.needsLayout = config.needsLayout
	else
		widget._state.needsLayout = true
	end
	
	function widget:setFrame(rect)
		self.frame:set(rect)
		
		if self.sprite ~= nil then
			self.sprite:setBounds(rect.x, rect.y, rect.w, rect.h)
		end
		
		self._state.needsLayout = true
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
		
		self:_addUnloadCallback(function()
			if self.sprite ~= nil then
				self.sprite:remove()
				self.sprite = nil
			end
		end)
	end
	
	function widget:setNeedsLayout()
		self._state.needsLayout = true
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
		
		if (_state.isLoaded and _state.isVisible and not _state.needsLayout) == false then
			return
		end
	
		_draw(self, _frame, rect)
	end
	
	function widget:performLayout()
		if self._performLayout ~= nil then
			self:_performLayout()
			self._state.needsLayout = false
		end
	end
	
	widget:_addLoadCallback(function(self)
		_draw = self._draw
	end)
	
	widget:_addUpdateCallback(function(self)
		if self._state.isVisible ~= isVisibleActual then
			self._state.isVisible = isVisibleActual
		end
		
		if self._state.needsLayout == true then
			if self._performLayout ~= nil then
				self:_performLayout()
			end

			self._state.needsLayout = false
		end
	end)
end

Widget.register("frame", frame)