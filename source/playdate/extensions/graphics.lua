
function playdate.graphics.drawImage(image, x, y)
	image:draw(x, y)
	
	return x, y, image:getSize()
end