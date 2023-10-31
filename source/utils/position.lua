Position = {}

function Position.zero()
	return { x = 0, y = 0 }
end

function Position.offset(position, x, y)
	return { x = position.x + x, y = position.y + y }
end