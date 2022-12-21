-- margin: { vertical = 0, horizontal = 0 }
function createTextImage(text, margin)
	if margin == nil then
		margin = {}
	end
	
	if margin.horizontal == nil then
		margin.horizontal = 0
	end
	
	if margin.vertical == nil then
		margin.vertical = 0
	end
	
	local textWidth, textHeight = gfx.getTextSize(text)
	local image = gfx.image.new(textWidth + margin.horizontal * 2, textHeight + margin.vertical * 2)
	local width, height = image:getSize()
	
	gfx.pushContext(image)
	
	-- Draw Score text
	gfx.drawTextAligned(text, margin.horizontal, margin.vertical, textAlignment.left)
	gfx.popContext()
	
	return image
end