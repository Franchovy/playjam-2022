function getColorDrawModeFill(color)
	if color == playdate.graphics.kColorWhite then
		return playdate.graphics.kDrawModeFillWhite
	elseif color == playdate.graphics.kColorBlack then
		return playdate.graphics.kDrawModeFillBlack
	end
end