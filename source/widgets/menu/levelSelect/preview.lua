import "assets"

local gfx <const> = playdate.graphics

class("LevelSelectPreview").extends(Widget)

function LevelSelectPreview:init(config)
	self.config = config
	
	self.images = {}
	self.painters = {}
	
	--
	
	self.data = {}
end

function LevelSelectPreview:_load()
	self.images.level = gfx.image.new(self.config.imagePath)
	local createMaskImage = function()
		local w, h = self.images.level:getSize()
		local image = gfx.image.new(w, h, gfx.kColorBlack)
		gfx.pushContext(image)
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRoundRect(0, 0, w, h, 7)
		gfx.popContext()
		return image
	end
	self.images.level:setMaskImage(createMaskImage())
	local createOverlayImage = function()
		local w, h = self.images.level:getSize()
		local image = gfx.image.new(w, h)
		gfx.pushContext(image)
		gfx.setColor(gfx.kColorBlack)
		gfx.setLineWidth(3)
		gfx.drawRoundRect(0, 0, w, h, 7)
		gfx.popContext()
		return image
	end
	local overlayImage = createOverlayImage()
	local createLockedImage = function()
		local w, h = self.images.level:getSize()
		local image = gfx.image.new(w, h)
		gfx.pushContext(image)
		gfx.setColor(gfx.kColorBlack)
		gfx.fillRoundRect(0, 0, w, h, 7)
		gfx.setColor(gfx.kColorWhite)
		gfx.setDitherPattern(0.8, gfx.image.kDitherTypeScreen)
		gfx.fillRoundRect(0, 0, w, h, 7)
		setCurrentFont(kAssetsFonts.twinbee2x)
		local fontHeight = gfx.getFont():getHeight()
		gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
		gfx.drawTextAligned("LOCKED", w / 2, (h - fontHeight) / 2, kTextAlignment.center)
		gfx.popContext()
		return image
	end
	local overlayImage = createOverlayImage()
	local createLockedImage = createLockedImage()
	
	self.images.star = gfx.image.new(kAssetsImages.starMenu):scaledImage(0.5)
	
	local scoreTime
	if self.config.score ~= nil then
		scoreTime = "⌛ "..self.config.score.timeString.."/"..self.config.score.timeStringObjective
	else
		scoreTime = "-"
	end
	
	setCurrentFont(kAssetsFonts.twinbee15x)
	self.images.labelMissing = gfx.imageWithText("NO HIGHSCORE", 200, 20)
	
	local scoreStars
	if self.config.score ~= nil then
		scoreStars = self.config.score.stars
	else
		scoreStars = nil
	end
	self.data.starsCount = scoreStars
	
	self.painters.star = Painter(function(rect)
		gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
		self.images.star:draw(rect.x, rect.y)
		
		gfx.setImageDrawMode(gfx.kDrawModeCopy)
		self.images.star:drawFaded(rect.x, rect.y, 0.9, gfx.image.kDitherTypeDiagonalLine)
	end)
	
	self.painters.background = Painter(function(rect)
		gfx.setColor(gfx.kColorBlack)
		gfx.setDitherPattern(0.3, gfx.image.kDitherTypeScreen)
		gfx.setLineWidth(2)
		gfx.fillRoundRect(rect.x, rect.y, rect.w, rect.h, 8)
		
		gfx.setColor(gfx.kColorWhite)
		local fillRect = Rect.inset(rect, 2, 2)
		gfx.fillRoundRect(fillRect.x, fillRect.y - 1, fillRect.w, fillRect.h, 6)
	end)
	
	local noHighScore = Painter(function(rect)
		local labelImageW, labelImageH = self.images.labelMissing:getSize()
		self.images.labelMissing:draw(rect.x + (rect.w - labelImageW) / 2, rect.y + (rect.h - labelImageH) / 2)
	end)
	
	local layout = Painter(function(rect, state)
		local starSize = self.images.star:getSize()
		
		local starOffsetInitial
		local starOffset
		if state.starsCount > 3 then
			starOffsetInitial = rect.x + 2
			starOffset = starSize + 5
		else
			starOffsetInitial = rect.x + 15
			starOffset = starSize + 10
		end
		
		local starImageW, starImageH = self.images.star:getSize()
		local starRect = Rect.make(0, rect.y, starImageW, starImageH)
		for i=1, state.starsCount do
			self.painters.star:draw(Rect.with(starRect, {x = starOffsetInitial + (starOffset * (i - 1))}))
		end
		
		setCurrentFont(kAssetsFonts.twinbee15x)
		local fontHeight = gfx.getFont():getHeight()
		gfx.drawTextAligned(scoreTime, rect.x + rect.w / 2, rect.y + starImageH + 7, kTextAlignment.center)
	end)
	
	self.painters.contents = Painter(function(rect, state)		
		setCurrentFont(kAssetsFonts.twinbee2x)
		local fontHeight = gfx.getFont():getHeight()
		local topPadding = 8
		local margin = 6
		gfx.drawTextAligned(self.config.title, rect.x + rect.w / 2, topPadding, kTextAlignment.center)
		
		local _, levelImageSizeH = self.images.level:getSize()
		local imageX, imageY = 7, fontHeight + topPadding + margin
		
		if self.config.locked == true then
			gfx.setColor(gfx.kColorBlack)
			gfx.setDitherPattern(0.6, gfx.image.kDitherTypeScreen)
			gfx.fillRoundRect(rect.x, rect.y, rect.w, rect.h, 8)
			
			createLockedImage:draw(imageX, imageY)
		else
			self.images.level:draw(imageX, imageY)
		end
		
		overlayImage:draw(imageX, imageY)
		
		if self.config.locked ~= true then
			local insetRect = Rect.inset(rect, 5, levelImageSizeH + fontHeight + topPadding + margin * 2, 5, 7)
			if state.starsCount ~= nil then
				layout:draw(insetRect, state)
			else
				noHighScore:draw(insetRect, state)
			end
		end
	end)
end

function LevelSelectPreview:_draw(rect)
	local insetRect = self.config.locked ~= true and Rect.inset(rect, 8, 30) or Rect.inset(rect, 8, 60)
	
	self.painters.background:draw(insetRect)
	
	self.painters.contents:draw(insetRect, { starsCount = self.data.starsCount })
end

function LevelSelectPreview:_unload()
	self.painters = nil
	self.images = nil
end
