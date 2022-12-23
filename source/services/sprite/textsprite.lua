import "engine"

function createTextImage(text, marginHorizontal, marginVertical)
	if marginHorizontal == nil then
		marginHorizontal = 0
	end
	
	if marginVertical == nil then
		marginVertical = 0
	end

	local textWidth, textHeight = gfx.getTextSize(text)
	local image = gfx.image.new(textWidth + marginHorizontal * 2, textHeight + marginVertical * 2)
	local width, height = image:getSize()
	
	gfx.pushContext(image)
	
	-- Draw Score text
	gfx.drawTextAligned(text, marginHorizontal, marginVertical, textAlignment.left)
	gfx.popContext()
	
	return image
end

function sizedTextSprite(text, size) 
	local image = createTextImage(text):scaledImage(size)
	local sprite = gfx.sprite.new(image)
	
	sprite:setCenter(0, 0)
	return sprite
end