local gfx <const> = playdate.graphics
local geo <const> = playdate.geometry

function frame(widget, config)
	config = config or {}
	
	if config.isVisible ~= nil then
		widget._state.isVisible = config.isVisible
	else
		widget._state.isVisible = true
	end
	
	function widget:draw(rect)
		if self._state.isLoaded == false or (self._state.isVisible == false) then
			return
		end
	
		self:_draw(self.frame, rect)
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
	
	widget:_addUpdateCallback(function(self)
		if self._state.isVisible ~= isVisibleActual then
			self._state.isVisible = isVisibleActual
		end
	end)
end

Widget.register("frame", frame)