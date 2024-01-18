local gfx <const> = playdate.graphics
local geo <const> = playdate.geometry

function frame(widget)
	function widget:setNeedsLayout()
		self._needsLayout = true
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
	
	widget.frame = geo.rect.new(0,0,0,0)
	widget.rects = table.create(0, 5)
	
	widget:_addUpdateCallback(function(self)
		local _state = self._state
		
		if self._needsLayout then
			self:_layout()
			
			self._needsLayout = false
		end
	end)
end

Widget.register("frame", frame)