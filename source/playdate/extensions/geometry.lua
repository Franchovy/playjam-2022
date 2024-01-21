local _type = type

local _new = playdate.geometry.rect.new

function playdate.geometry.rect.new(x, y, w, h)
	return _new(
		x == nil and 0 or x,
		y == nil and 0 or y,
		w == nil and 0 or w,
		h == nil and 0 or h
	)
end

function playdate.geometry.rect:set(rectOrX, y, w, h)
	if _type(rectOrX) == "userdata" then
		self.x = rectOrX.x
		self.y = rectOrX.y
		self.w = rectOrX.w
		self.h = rectOrX.h
	else
		if rectOrX ~= nil then self.x = rectOrX end
		if y ~= nil then self.y = y end
		if w ~= nil then self.w = w end
		if h ~= nil then self.h = h end
	end
end

function playdate.geometry.rect:toLegacyRect()
	return Rect.make(self.x, self.y, self.w, self.h)
end

function playdate.geometry.rect.assign(rect, rectOrX, y, w, h)
	if rect == nil then
		if _type(rectOrX) == "userdata" then
			return rectOrX:copy()
		end
		
		return playdate.geometry.rect.new(rectOrX, y, w, h)
	else
		rect:set(rectOrX, y, w, h)
		return rect
	end
end

-- 

function playdate.geometry.rect.center(rect, rectContainer)
	rect:set(
		rectContainer.x + (rectContainer.w - rect.w) / 2,
		rectContainer.y + (rectContainer.h - rect.h) / 2,
		rect.w,
		rect.h
	)
end

-- "T" methods - transform methods. Transforms and returns input for convenience.

local function _transform(transformFunction)
	return function (rect, ...)
		transformFunction(rect, ...)
		return rect
	end
end

--function playdate.geometry.rect:tOffset(rect, offsetX, offsetY)
playdate.geometry.rect.tOffset = _transform(playdate.geometry.rect.offset)

--function playdate.geometry.rect:tCenter(rect, rectContainer)
playdate.geometry.rect.tCenter = _transform(playdate.geometry.rect.center)

--function playdate.geometry.rect:tSet(rectOrX, y, w, h)
playdate.geometry.rect.tSet = _transform(playdate.geometry.rect.set)

--function playdate.geometry.rect:inset(dx, dy)
playdate.geometry.rect.tInset = _transform(playdate.geometry.rect.inset)