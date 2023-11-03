Position = {}

function Position.zero()
	return { x = 0, y = 0 }
end

function Position.make(x, y)
	return { x = x, y = y }
end

function Position.offset(position, x, y)
	return { x = position.x + x, y = position.y + y }
end