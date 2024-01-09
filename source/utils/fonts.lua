local gfx <const> = playdate.graphics
local fonts = {}

function setCurrentFont(path)
	if fonts[path] == nil then
		fonts[path] = gfx.font.new(path)
	end
	
	gfx.setFont(fonts[path])
end

function setCurrentFontDefault(pathDefaultFont)
	if pathDefaultFont ~= nil then
		fonts["default"] = gfx.font.new(pathDefaultFont)
	end
	
	gfx.setFont(fonts["default"])
end

function getFont(path)
	if fonts[path] == nil then
		fonts[path] = gfx.font.new(path)
	end
	
	return fonts[path]
end