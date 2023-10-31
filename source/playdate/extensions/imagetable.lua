function playdate.graphics.imagetable.scaled(self, scaleX, scaleY)
	if scaleY == nil then
		scaleY = scaleX
	end
	
	local w,h = self:getSize()
	local imagetableScaled = playdate.graphics.imagetable.new(h * w, w)

	for i=1,#self do
		imagetableScaled:setImage(i, self:getImage(i):scaledImage(scaleX, scaleY))
	end
	
	return imagetableScaled
end