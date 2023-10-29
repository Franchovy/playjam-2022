class("Title").extends()

-- Called from main
function Title:init()
	self.images = {}
	self.painters = {}
	
	self.index = 0
	self.tick = 0
end

-- Called from main (first update)
function Title:load()
	-- Show loading animation
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.fillRect(0, 0, 400, 240)
	
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	local loadingText = playdate.graphics.imageWithText("LOADING...", 400, 240):scaledImage(2)
	loadingText:draw(40, 110)
	
	--self:loadCallback(function() 
		self.images.imagetable = playdate.graphics.imagetable.new(kAssetsImages.particles)
		self.images.wheelImageTable = playdate.graphics.imagetable.new(kAssetsImages.wheel)
		self.images.backgroundImage = playdate.graphics.image.new(kAssetsImages.background)
		self.images.backgroundImage2 = playdate.graphics.image.new(kAssetsImages.background2)
		self.images.backgroundImage3 = playdate.graphics.image.new(kAssetsImages.background3)
		self.images.backgroundImage4 = playdate.graphics.image.new(kAssetsImages.background4)
		self.images.textImage = playdate.graphics.imageWithText("WHEEL RUNNER", 400, 100):scaledImage(3)
		self.images.pressStart = playdate.graphics.imageWithText("PRESS A", 200, 60):scaledImage(2)
	--end)
	
	-- Listen to key press once loading is finished, else wait for end of animation
	
	-- self:loadFinished()
	
	-- Painter Button
	
	local painterButtonFill = Painter(function(rect, state)
		if state.tick == 0 then
			-- press a button fill
			playdate.graphics.setColor(playdate.graphics.kColorWhite)
			playdate.graphics.setDitherPattern(0.8, playdate.graphics.image.kDitherTypeDiagonalLine)
			playdate.graphics.fillRoundRect(rect.x, rect.y, rect.w, rect.h, 6)
		else
			-- press a button fill
			playdate.graphics.setColor(playdate.graphics.kColorWhite)
			playdate.graphics.setDitherPattern(0.2, playdate.graphics.image.kDitherTypeDiagonalLine)
			playdate.graphics.fillRoundRect(rect.x, rect.y, rect.w, rect.h, 6)
		end
	end)
	
	local painterButtonOutline = Painter(function(rect, state)
		if state.tick == 0 then
			-- press a button outline
			playdate.graphics.setColor(playdate.graphics.kColorBlack)
			playdate.graphics.setDitherPattern(0.2, playdate.graphics.image.kDitherTypeDiagonalLine)
			playdate.graphics.setLineWidth(3)
			playdate.graphics.drawRoundRect(rect.x, rect.y, rect.w, rect.h, 6)
		else
			-- press a button outline
			playdate.graphics.setColor(playdate.graphics.kColorBlack)
			playdate.graphics.setLineWidth(3)
			playdate.graphics.drawRoundRect(rect.x, rect.y, rect.w, rect.h, 6)
		end
	end)
	
	local painterButtonPressStart = Painter(function(rect, state)
		if state.tick == 0 then
			-- press a text
			self.images.pressStart:drawFaded(rect.x, rect.y, 0.3, playdate.graphics.image.kDitherTypeDiagonalLine)
		else
			-- press a text
			self.images.pressStart:draw(rect.x, rect.y)
		end
	end)
	
	self.painters.painterButton = Painter(function(rect, state) 
		painterButtonFill:draw({ x = 0, y = 0, w = rect.w, h = rect.h }, state)
		painterButtonOutline:draw({ x = 0, y = 0, w = rect.w, h = rect.h }, state)
		
		local imageSizePressStartW, imageSizePressStartH = self.images.pressStart:getSize()
		painterButtonPressStart:draw({x = 15, y = 5, w = imageSizePressStartW, h = imageSizePressStartH}, state)
	end)
	
	-- Painter Background
	
	local painterBackground1 = Painter(function(rect, state)
		playdate.graphics.setDitherPattern(0.4, playdate.graphics.image.kDitherTypeDiagonalLine)
		playdate.graphics.fillRect(0, 0, 400, 240)
	end)
	
	local painterBackground2 = Painter(function(rect, state)
		-- background - right hill
		self.images.backgroundImage3:drawFaded(0, -10, 0.2, playdate.graphics.image.kDitherTypeBayer8x8)
	end)
	
	local painterBackground3 = Painter(function(rect, state)
		-- background - flashing lights
		if state.tick == 0 then
			self.images.backgroundImage2:drawFaded(5, 0, 0.7, playdate.graphics.image.kDitherTypeDiagonalLine)
		else
			self.images.backgroundImage2:invertedImage():drawFaded(5, 0, 0.3, playdate.graphics.image.kDitherTypeDiagonalLine)
		end
	end)
	
	local painterBackground4 = Painter(function(rect, state)
		-- background - left hill
		self.images.backgroundImage4:drawFaded(-20, 120, 0.8, playdate.graphics.image.kDitherTypeBayer4x4)
		self.images.backgroundImage:draw(200,30)
	end)
	
	self.painters.painterBackground = Painter(function(rect, state)
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		
		local rectOffset = Rect.offset(rect, 0, -20)
		painterBackground1:draw(rectOffset)
		painterBackground2:draw(rectOffset)
		painterBackground3:draw(rectOffset, state)
		painterBackground4:draw(rectOffset)
		
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.setDitherPattern(0.1, playdate.graphics.image.kDitherTypeBayer4x4)
		playdate.graphics.fillRect(rect.x, (rect.y + rect.h) - 20, rect.w, 20)
	end)
	
	-- Painter Text
	
	local painterTitleRectangleOutline = Painter(function(rect, state)
		-- title rectangle outline
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.setDitherPattern(0.3, playdate.graphics.image.kDitherTypeDiagonalLine)
		playdate.graphics.fillRect(rect.x, rect.y, rect.w, rect.h)
	end)
	
	local painterTitleRectangleFill = Painter(function(rect, state)
		-- title rectangle fill
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.setDitherPattern(0.3, playdate.graphics.image.kDitherTypeDiagonalLine)
		playdate.graphics.fillRect(rect.x, rect.y, rect.w, rect.h)
	end)
	
	local painterTitleText = Painter(function(rect, state)
		self.images.textImage:draw(rect.x, rect.y)
	end)
	
	self.painters.painterTitle = Painter(function(rect, state)
		painterTitleRectangleOutline:draw(rect)
		painterTitleRectangleFill:draw(Rect.inset(rect, 0, 10))
		local titleTextSizeW, titleTextSizeH = self.images.textImage:getSize()
		painterTitleText:draw({x = 40, y = 15, w = titleTextSizeW, h = titleTextSizeH })
	end)
	
	local painterParticles = Painter(function(rect, state) 
		-- animated particles
		self.images.imagetable:getImage((state.index % 36) + 1):scaledImage(2):draw(rect.x, rect.y)
	end)
	
	self.painters.painterWheel = Painter(function(rect, state, globals)
		table.insert(globals, { 
			fn = function() 
				painterParticles:draw({ x = rect.x - 55, y = rect.y - 35, w = 150, h = 150}, state, { absolute = true })
			end,
			state = state
		})
	
		-- animated wheel
		self.images.wheelImageTable:getImage((-state.index % 12) + 1):scaledImage(2):draw(rect.x, rect.y)
	end)
	
	playdate.graphics.sprite.setBackgroundDrawingCallback(function()
		local w, h = playdate.display.getSize()
		
		Painter.clearGlobal()
		
		self.painters.painterBackground:draw({ x = 0, y = 0, w = w, h = h }, { tick = self.tick })
		
		self.painters.painterWheel:draw({x = 70, y = 30, w = 150, h = 150}, { index = self.index % 36 })
		
		self.painters.painterTitle:draw({x = 0, y = 130, w = 400, h = 57})
		self.painters.painterButton:draw({x = 115, y = 200, w = 160, h = 27}, { tick = self.tick })
		
		Painter.drawGlobal()
	end)
end

function Title:update()
	self.index += 2
	
	if self.index % 40 > 32 then
		self.tick = self.tick == 0 and 1 or 0
	end
	
	if playdate.buttonIsPressed(playdate.kButtonA) then
		self.tick = 0
	end
end