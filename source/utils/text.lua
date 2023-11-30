import "engine"

function createRoundedRectFrame(imageContent, roundedCornerSize, marginHorizontal, marginVertical, marginRight, marginBottom)
	local marginTop = marginVertical or 0
	local marginBottom = marginBottom or marginTop
	local marginLeft = marginHorizontal or 0
	local marginRight = marginRight or marginLeft
	
	local contentWidth, contentHeight = imageContent:getSize()
	local imageFrame = playdate.graphics.image.new(contentWidth + marginLeft + marginRight, contentHeight + marginTop + marginBottom)
	
	playdate.graphics.pushContext(imageFrame)
	
	playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
	playdate.graphics.fillRoundRect(0, 0, contentWidth + marginLeft + marginRight, contentHeight + marginTop + marginBottom, roundedCornerSize)
	
	--playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillBlack)
	--playdate.graphics.drawRoundRect(0, 0, contentWidth + marginLeft + marginRight, contentHeight + marginTop + marginBottom, roundedCornerSize)
	imageContent:draw(marginLeft, marginTop)
	
	playdate.graphics.popContext()
	playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeCopy)
	
	return imageFrame
end

function createTextImage(text, marginHorizontal, marginVertical, marginRight, marginBottom)
	local marginTop = marginVertical or 0
	local marginBottom = marginBottom or marginTop
	local marginLeft = marginHorizontal or 0
	local marginRight = marginRight or marginLeft

	local textWidth, textHeight = playdate.graphics.getTextSize(text)
	local image = playdate.graphics.image.new(textWidth + marginLeft + marginRight, textHeight + marginTop + marginBottom)
	local width, height = image:getSize()
	
	playdate.graphics.pushContext(image)
	
	-- Draw Score text
	playdate.graphics.drawTextAligned(text, marginLeft, marginTop, textAlignment.left)
	playdate.graphics.popContext()
	
	return image
end

function sizedTextSprite(text, size) 
	local image = createTextImage(text):scaledImage(size)
	local sprite = playdate.graphics.sprite.new(image)
	
	sprite:setCenter(0, 0)
	return sprite
end