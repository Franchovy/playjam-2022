local gfx <const> = playdate.graphics
function textPainter(config)
	local textPainter = {}
	textPainter.config = config
	
	if textPainter.config.scale == nil then
		textPainter.config.scale = 1
	end
	
	if textPainter.config.scale == 1 then
		setCurrentFont(kAssetsFonts.twinbee)
	elseif textPainter.config.scale == 1.5 then
		setCurrentFont(kAssetsFonts.twinbee15x)
	elseif textPainter.config.scale == 2 then	
		setCurrentFont(kAssetsFonts.twinbee2x)
	else
		error("Font scale is unavailable.", 2)
	end
	
	if textPainter.config.spacing == nil then
		textPainter.config.spacing = 0
	end
	
	textPainter.images = {}
	
	function textPainter:loadCharsFromString(chars)
		for i = 1, #chars do
			local char = chars:sub(i, i)
			
			local textSizeW, textSizeH = gfx.getTextSize(char)
			textPainter.images[char] = gfx.imageWithText(char, textSizeW, textSizeH)
		end
	end
	
	function textPainter:drawText(text, x, y)
		local xOffset = 0
		for i = 1, #text do
			local char = text:sub(i, i)
			
			if textPainter.images[char] == nil then
				self:loadCharsFromString(char)
			end
			
			textPainter.images[char]:draw(x + xOffset, y)
			xOffset += textPainter.images[char]:getSize() + textPainter.config.spacing
		end
	end
	
	function textPainter:drawTextAlignedRight(text, x, y)
		local xOffset = 0
		for i = #text, 1, -1 do
			local char = text:sub(i, i)
			
			if textPainter.images[char] == nil then
				self:loadCharsFromString(char)
			end
			
			xOffset -= textPainter.images[char]:getSize() + textPainter.config.spacing
			textPainter.images[char]:draw(x + xOffset, y)
		end
	end
	
	function textPainter:getSize(text)
		local textSizeW = 0
		local textSizeH = 0
		for i = 1, #text do
			local char = text:sub(i, i)
			
			if textPainter.images[char] == nil then
				self:loadCharsFromString(char)
			end
			
			local width, height = textPainter.images[char]:getSize()
			textSizeH = height
			textSizeW += width + textPainter.config.spacing
		end
		
		return textSizeW, textSizeH
	end
	
	if textPainter.config.charsPreloaded ~= nil then
		textPainter:loadCharsFromString(textPainter.config.charsPreloaded)
	end
	
	return textPainter
end