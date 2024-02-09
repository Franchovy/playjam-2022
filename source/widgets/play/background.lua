local gfx <const> = playdate.graphics
local disp <const> = playdate.display
local geo <const> = playdate.geometry

local _insert <const> = table.insert
local _new <const> = geo.rect.new
local _create <const> = table.create
local _getSize <const> = gfx.image.getSize
local _draw <const> = gfx.image.draw
local _floor <const> = math.floor
local _tSet <const> = geo.rect.tSet
local _intersection <const> = geo.rect.intersection
local _tOffset <const> = geo.rect.tOffset
local _kImageUnflipped <const> = gfx.kImageUnflipped

class("WidgetBackground").extends(Widget)

function WidgetBackground:_init(config)
	self.theme = config.theme
	
	self:supply(Widget.deps.frame)
	self:setFrame(disp.getRect())
	
	self:createSprite(kZIndex.background)
end

function WidgetBackground:_load()
	local images = getParalaxImagesForTheme(kThemes[self.theme])
	
	-- Assign background Image (to draw on)
	self.backgroundImage = images.background
	
	-- Initialize Properties
	
	self.images = images.images
	
	self.paralaxRatios = {}
	self.imageOffsets = {}
	self.rectsImagesRight = _create(#self.images, 0)
	self.rectsImagesLeft = _create(#self.images, 0)
	
	for i, image in ipairs(self.images) do
		_insert(self.paralaxRatios, i / 50)
		_insert(self.imageOffsets, 0)
		
		local imageWidth, imageHeight = _getSize(image)
		_insert(self.rectsImagesRight, _new(0, 0, imageWidth, imageHeight))
		_insert(self.rectsImagesLeft, _new(-400, 0, imageWidth, imageHeight))
	end
end

function WidgetBackground:_draw(frame, rect)
	local _frameX = frame.x
	local _frameY = frame.y
	local _frameW = frame.w
	local _frameH = frame.h
	
	if rect == nil then
		rect = frame
	end
	
	local _rectX = rect.x
	local _rectY = rect.y
	local _rectW = rect.w
	local _rectH = rect.h
	
	self.backgroundImage:draw(_frameX + _rectX, _frameY + _rectY, _kImageUnflipped, rect)
	
	local _imageOffsets = self.imageOffsets
	local _rectsImagesRight = self.rectsImagesRight
	local _rectsImagesLeft = self.rectsImagesLeft
	
	for i, image in ipairs(self.images) do
		local imageOffset = _floor(_imageOffsets[i])
		local imageRightRect = _tSet(_rectsImagesRight[i], imageOffset)
		local imageLeftRect = _tSet(_rectsImagesLeft[i], imageOffset - 400)
		
		-- Draw 2 copies of the image, one before and one after
		local imageRightSourceRect = _tOffset(_intersection(imageRightRect, rect), -imageOffset, 0)
		_draw(image, _frameX + imageOffset + _rectX, _frameY + _rectY, _kImageUnflipped, imageRightSourceRect)
		
		local imageLeftSourceRect = _tOffset(_intersection(imageLeftRect, rect), _rectsImagesLeft[i].w - imageOffset, 0)
		_draw(image, _frameX + _rectX, _frameY + _rectY, _kImageUnflipped, imageLeftSourceRect)
	end
	
end

function WidgetBackground:_update()
	local previousOffset <const> = self.drawOffset
	self.drawOffset = gfx.getDrawOffset()
	
	for i, image in pairs(self.images) do
		local originalOffset = self.drawOffset * self.paralaxRatios[i]
		self.imageOffsets[i] = originalOffset % 400
	end
	
	if self.drawOffset ~= previousOffset then
		self.sprite:markDirty()
	end
end

function WidgetBackground:_unload()
	self.sprite:remove()
end