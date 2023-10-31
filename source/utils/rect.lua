function rectInsetBy(rect, insetX, insetY)
	local x, y, width, height = rect:unpack()
	return x + insetX, y + insetY, width - (insetX * 2), height - (insetY * 2)
end

Rect = {}

function Rect.make(x, y, w, h)
	return { x = x, y = y, w = w, h = h }
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