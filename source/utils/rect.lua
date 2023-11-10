function rectInsetBy(rect, insetX, insetY)
	local x, y, width, height = rect:unpack()
	return x + insetX, y + insetY, width - (insetX * 2), height - (insetY * 2)
end

Rect = {}

function Rect.make(x, y, w, h)
	return { x = x, y = y, w = w, h = h }
end

function Rect.position(position, w, h)
	return { x = position.x, y = position.y, w = w, h = h }
end

function Rect.with(rect, properties)
	local rect = table.shallowcopy(rect)
	if properties.x ~= nil then
		rect.x = properties.x
	end
	if properties.y ~= nil then
		rect.y = properties.y
	end
	if properties.w ~= nil then
		rect.w = properties.w
	end
	if properties.h ~= nil then
		rect.h = properties.h
	end
	return rect
end

function Rect.bottom(rect)
	return rect.y + rect.h
end

function Rect.right(rect)
	return rect.x + rect.w
end

function Rect.center(rect, rectContainer)
	return { x = (rectContainer.w - rect.w) / 2, y = (rectContainer.h - rect.h) / 2, w = rect.w, h = rect.h }
end

function Rect.size(w, h)
	return { x = 0, y = 0, w = w, h = h }
end

function Rect.array(rect)
	return { rect.x, rect.y, rect.w, rect.h }
end

function Rect.unpack(rect)
	return rect.x, rect.y, rect.w, rect.h
end

function Rect.inset(rect, x, y)
	return { x = rect.x + x, y = rect.y + y, w = rect.w - (x * 2), h = rect.h - (y * 2) }
end

function Rect.offset(rect, x, y)
	return { x = rect.x + x, y = rect.y + y, w = rect.w, h = rect.h }
end

function Rect.at(rect, x, y)
	return { x = x, y = y + y, w = rect.w, h = rect.h }
end