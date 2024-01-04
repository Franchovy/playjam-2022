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
	return { x = rectContainer.x + (rectContainer.w - rect.w) / 2, y = rectContainer.y + (rectContainer.h - rect.h) / 2, w = rect.w, h = rect.h }
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

function Rect.inset(rect, x, y, w, h)
	assert(x ~= nil, "x must not be nil")
	if y == nil then
		y = x
	end
	if w == nil then
		w = x
	end
	if h == nil then
		h = y
	end
	return { x = rect.x + x, y = rect.y + y, w = rect.w - (x + w), h = rect.h - (y + h) }
end

function Rect.offset(rect, x, y)
	return { x = rect.x + x, y = rect.y + y, w = rect.w, h = rect.h }
end

function Rect.at(rect, x, y)
	return { x = x, y = y + y, w = rect.w, h = rect.h }
end

function Rect.overlap(rect1, rect2)
	local x1, y1, w1, h1 = rect1.x, rect1.y, rect1.w, rect1.h
	local x2, y2, w2, h2 = rect2.x, rect2.y, rect2.w, rect2.h
	
	local overlapX = math.max(0, math.min(x1 + w1, x2 + w2) - math.max(x1, x2))
	local overlapY = math.max(0, math.min(y1 + h1, y2 + h2) - math.max(y1, y2))
	
	return {
		x = math.max(x1, x2),
		y = math.max(y1, y2),
		w = overlapX,
		h = overlapY
	}
end

function Rect.splitHorizontal(rect, count)
	local rects = {}
	local width = rect.w / count
	for i=1,count do
		table.insert(rects, Rect.make(rect.x + (i - 1) * width, rect.y, width, rect.h))
	end
	
	return table.unpack(rects)
end