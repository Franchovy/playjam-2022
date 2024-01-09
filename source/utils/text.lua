import "engine"

local gfx <const> = playdate.graphics

function createRoundedRectFrame(imageContent, roundedCornerSize, marginHorizontal, marginVertical, marginRight, marginBottom)
	local marginTop = marginVertical or 0
	local marginBottom = marginBottom or marginTop
	local marginLeft = marginHorizontal or 0
	local marginRight = marginRight or marginLeft
	
	local contentWidth, contentHeight = imageContent:getSize()
	local imageFrame = gfx.image.new(contentWidth + marginLeft + marginRight, contentHeight + marginTop + marginBottom)
	
	gfx.pushContext(imageFrame)
	
	gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
	gfx.fillRoundRect(0, 0, contentWidth + marginLeft + marginRight, contentHeight + marginTop + marginBottom, roundedCornerSize)
	
	--gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
	--gfx.drawRoundRect(0, 0, contentWidth + marginLeft + marginRight, contentHeight + marginTop + marginBottom, roundedCornerSize)
	imageContent:draw(marginLeft, marginTop)
	
	gfx.popContext()
	gfx.setImageDrawMode(gfx.kDrawModeCopy)
	
	return imageFrame
end

function createTextImage(text, marginHorizontal, marginVertical, marginRight, marginBottom)
	local marginTop = marginVertical or 0
	local marginBottom = marginBottom or marginTop
	local marginLeft = marginHorizontal or 0
	local marginRight = marginRight or marginLeft

	local textWidth, textHeight = gfx.getTextSize(text)
	local image = gfx.image.new(textWidth + marginLeft + marginRight, textHeight + marginTop + marginBottom)
	local width, height = image:getSize()
	
	gfx.pushContext(image)
	
	-- Draw Score text
	gfx.drawTextAligned(text, marginLeft, marginTop, textAlignment.left)
	gfx.popContext()
	
	return image
end

function sizedTextSprite(text, size) 
	local image = createTextImage(text):scaledImage(size)
	local sprite = gfx.sprite.new(image)
	
	sprite:setCenter(0, 0)
	return sprite
end