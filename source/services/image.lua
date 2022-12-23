import "engine"

function autoScaledImage(image)
	local imageWidth, imageHeight = image:getSize()
	return image:scaledImage(400 / imageWidth, 240 / imageHeight)
end

function fadedImage(image, opacity)
	return image:fadedImage(opacity, playdate.graphics.image.kDitherTypeFloydSteinberg)
end

function formattedImage(image, opacity)
	return fadedImage(
		autoScaledImage(image),
		0.7
	)	
end