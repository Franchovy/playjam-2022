local fonts = {}

function setCurrentFont(path)
	if fonts[path] == nil then
		fonts[path] = playdate.graphics.font.new(path)
	end
	
	playdate.graphics.setFont(fonts[path])
end

function setCurrentFontDefault(pathDefaultFont)
	if pathDefaultFont ~= nil then
		fonts["default"] = playdate.graphics.font.new(pathDefaultFont)
	end
	
	playdate.graphics.setFont(fonts["default"])
end

function getFont(path)
	if fonts[path] == nil then
		fonts[path] = playdate.graphics.font.new(path)
	end
	
	return fonts[path]
end