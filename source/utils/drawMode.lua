local gfx <const> = playdate.graphics
function getColorDrawModeFill(color)
	if color == gfx.kColorWhite then
		return gfx.kDrawModeFillWhite
	elseif color == gfx.kColorBlack then
		return gfx.kDrawModeFillBlack
	end
end