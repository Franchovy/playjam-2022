class("Widget").extends()

Widget.deps = {}

function Widget.register(name, dep, config)
	Widget.deps[name] = {
		_supply = dep,
		_config = config
	}
end

import "widget/input"
import "widget/state"
import "widget/animators"
import "widget/animations"
import "widget/frame"
import "widget/keyValueState"
import "widget/samples"
import "widget/fileplayer"

local disp <const> = playdate.display
local gfx <const> = playdate.graphics

function Widget.init(self)
	self._state = {}
end

function Widget.new(class, ...)
	local widget = class(...)
	
	ifNil(widget._state, 
		function()
			widget._state = {
				isLoaded = false,
				isVisble = true
			}
		end,
		function()
			ifNil(widget._state.isLoaded, function()
				widget._state.isLoaded = false
			end)
			
			ifNil(widget._state.isVisible, function()
				widget._state.isVisible = true
			end)
		end
	)
	
	widget.children = table.create(0, 4)
	
	return widget
end

function Widget:supply(dep, config)
	if dep._config ~= nil then
		if dep._config.dependsOn ~= nil then
			for _, dep in pairs(dep._config.dependsOn) do
				assert(Widget.deps[dep] ~= nil, "Missing dependency: ".. dep)
				
				self:supply(Widget.deps[dep])
			end
		end
	end
	
	dep._supply(self, config)
end

function Widget:createSprite(zIndex)
	if self.sprite == nil then
		local sprite = gfx.sprite.new()
		sprite:setSize(disp.getSize())
		sprite:setCenter(0, 0)
		sprite:moveTo(0, 0)
		
		if zIndex ~= nil then
			sprite:setZIndex(zIndex)
		else
			sprite:setZIndex(-32768)
		end
		
		sprite:setIgnoresDrawOffset(true)
		sprite:setUpdatesEnabled(false)
		sprite.draw = function(s, x, y, w, h)
			local frame = Rect.make(s.x, s.y, s.width, s.height)
			local drawRect = Rect.make(x, y, w, h)
			self:draw(frame, drawRect)
		end
		
		sprite:add()
		self.sprite = sprite
	end
end

function Widget.setVisible(self, isVisible)
	self._state.isVisible = isVisible
	
	if self.children ~= nil then
		for _, child in pairs(self.children) do
			child:setVisible(isVisible)
		end
	end	
end

function Widget.isVisible(self)
	return self._state.isVisible
end

function Widget.load(self)
	self:_load()
	
	self._state.isLoaded = true
	
	if self._loadCallbacks ~= nil then
		for _, callback in pairs(self._loadCallbacks) do
			callback(self)
		end
	end
end

function Widget.unload(self)
	if self._state.isLoaded == false then
		return
	end
	
	self._state.isLoaded = false
	
	if self._unload ~= nil then
		self:_unload()
	end
end

function Widget:isLoaded()
	return self._state.isLoaded	
end

function Widget:update()
	if self._state.isLoaded == false then
		return
	end
	
	if self._update ~= nil then
		self:_update()
	end
	
	if self.children ~= nil then
		for _, child in pairs(self.children) do
			child:update()
		end
	end
	
	if self._updateCallbacks ~= nil then
		for _, callback in pairs(self._updateCallbacks) do
			callback(self)
		end
	end
end

function Widget:_addLoadCallback(callback)
	if self._loadCallbacks == nil then
		self._loadCallbacks = {}
	end
	
	table.insert(self._loadCallbacks, callback)
end

function Widget:_addUpdateCallback(callback)
	if self._updateCallbacks == nil then
		self._updateCallbacks = {}
	end
	
	table.insert(self._updateCallbacks, callback)
end

function Widget:draw(frame, rect)
	if self._state.isLoaded == false or (self._state.isVisible == false) then
		return
	end

	self:_draw(frame, rect)
end