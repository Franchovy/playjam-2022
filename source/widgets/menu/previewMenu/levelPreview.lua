import "assets"

local gfx <const> = playdate.graphics

class("WidgetMenuLevelPreview").extends(Widget)

function WidgetMenuLevelPreview:_init(config)
	self.images = {}
	self.painters = {}
	
	--
	
	self.data = {}
end

function WidgetMenuLevelPreview:_load()
	self.images.level = gfx.image.new(self.config.imagePath)
	self.images.star = gfx.image.new(kAssetsImages.starMenu):scaledImage(0.5)
	
	self.painters.locked = Painter.commonPainters.lockedCover()
	self.painters.image = Painter.commonPainters.roundedCornerImage(self.images.level)
	self.painters.background = Painter.commonPainters.whiteBackgroundFrame()
	
	local painterStar = Painter(function(rect)
		gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
		self.images.star:draw(rect.x, rect.y)
		
		gfx.setImageDrawMode(gfx.kDrawModeCopy)
		self.images.star:drawFaded(rect.x, rect.y, 0.9, gfx.image.kDitherTypeDiagonalLine)
	end)
	
	local painterObjectives
	
	if self.config.type == "level" then
		if self.config.score ~= nil then
			local scoreTime = "⌛"..self.config.score.timeString.."/"..self.config.objectives.timeString
			local starsCount = self.config.score.stars
			
			-- TODO: Display objective time
			--scoreTime = "⌛"..self.config.score.timeString.."/"..self.config.score.timeStringObjective
			
			painterObjectives = Painter(function(rect, state)
				local starImageW, starImageH = self.images.star:getSize()
				
				local starOffsetInitial, starOffset
				if starsCount > 3 then
					starOffsetInitial = rect.x + 2
					starOffset = starImageW + 5
				else
					starOffsetInitial = rect.x + 15
					starOffset = starImageW + 10
				end
				
				for i=1, starsCount do
					painterStar:draw(Rect.make(starOffsetInitial + (starOffset * (i - 1)), rect.y, starImageW, starImageH))
				end
				
				setCurrentFont(kAssetsFonts.twinbee15x)
				gfx.setFontTracking(4)
				
				local fontHeight = gfx.getFont():getHeight()
				gfx.drawTextAligned(scoreTime, rect.x + rect.w / 2, rect.y + starImageH + 7, kTextAlignment.center)
				gfx.setFontTracking(0)
			end)
		end
	end
	
	self.painters.contents = Painter(function(rect, state)		
		setCurrentFont(kAssetsFonts.twinbee2x)
		local fontHeight = gfx.getFont():getHeight()
		local topPadding = 8
		
		local margin = self.config.type == "world" and 12 or 6
		gfx.drawTextAligned(self.config.title, rect.x + rect.w / 2, topPadding, kTextAlignment.center)
		
		local imageW, imageH = self.images.level:getSize()
		local imageX, imageY = 7, fontHeight + topPadding + margin
		
		if self.config.locked == true then
			gfx.setColor(gfx.kColorBlack)
			gfx.setDitherPattern(0.6, gfx.image.kDitherTypeScreen)
			gfx.fillRoundRect(rect.x, rect.y, rect.w, rect.h, 8)
			
			self.painters.locked:draw(Rect.make(imageX, imageY, imageW, imageH))
		else
			self.painters.image:draw(Rect.make(imageX, imageY, imageW, imageH))
		end
		
		if self.config.locked ~= true then
			local bottomPadding = self.config.type == "world" and 25 or 7
			local insetRect = Rect.inset(rect, 5, imageH + fontHeight + topPadding + margin * 2, 5, bottomPadding)
			
			if self.config.type == "world" then
				local starsCount = "⭐️"..tostring(self.config.score.stars).."/"..tostring(self.config.objectives.stars)
				local starImageW, starImageH = self.images.star:getSize()
				
				setCurrentFont(kAssetsFonts.twinbee2x)
				gfx.setFontTracking(6)
				
				local fontHeight = gfx.getFont():getHeight()
				gfx.drawTextAligned((starsCount), insetRect.x + insetRect.w / 2, insetRect.y + insetRect.h / 2, kTextAlignment.center)
				gfx.setFontTracking(0)
			elseif self.config.score ~= nil then
				painterObjectives:draw(insetRect, starsCount)
			else
				setCurrentFont(kAssetsFonts.twinbee15x)
				gfx.drawTextAligned("NO HIGHSCORE", insetRect.x + insetRect.w / 2, insetRect.y + insetRect.h / 2 - 5, kTextAlignment.center)
			end
		end
	end)
end

function WidgetMenuLevelPreview:_draw(rect)
	local insetRect
	
	if self.config.locked == true then
		insetRect = Rect.inset(rect, 8, 60)
	elseif self.config.type == "world" then 
		insetRect = Rect.inset(rect, 8, 40)
	else
		insetRect = Rect.inset(rect, 8, 30)
	end
	
	self.painters.background:draw(insetRect)
	self.painters.contents:draw(insetRect)
end

function WidgetMenuLevelPreview:_unload()
	self.painters = nil
	self.images = nil
end
