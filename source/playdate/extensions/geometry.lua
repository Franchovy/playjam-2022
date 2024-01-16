local _type = type

function playdate.geometry.rect:set(rectOrX, y, w, h)
	if _type(rectOrX) == "userdata" then
		self.x = rectOrX.x
		self.y = rectOrX.y
		self.w = rectOrX.w
		self.h = rectOrX.h
	else
		self.x = rectOrX
		self.y = y
		self.w = w
		self.h = h
	end
end

function playdate.geometry.rect:toLegacyRect()
	return Rect.make(self.x, self.y, self.w, self.h)
end