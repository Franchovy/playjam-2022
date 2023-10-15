function rectInsetBy(rect, insetX, insetY)
	local x, y, width, height = rect:unpack()
	return x + insetX, y + insetY, width - (insetX * 2), height - (insetY * 2)
end