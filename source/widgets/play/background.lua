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
local _fast_intersection <const> = geo.rect.fast_intersection

local paralaxRatio = 1 / 50
local images = table.create(5, 0)
local imageRectsX, imageRectsY, imageRectsW, imageRectsH = table.create(5, 0), table.create(5, 0), table.create(5, 0), table.create(5, 0)
local imagesCount = nil
local ratio = nil
local paralaxOffsets = nil
local maxParallax = nil
local offset = 0

class("WidgetBackground").extends(Widget)

function WidgetBackground:_init(config)
	self.theme = config.theme
	
	self:supply(Widget.deps.frame)
	self:setFrame(disp.getRect())
end

function WidgetBackground:_load()
	self:createSprite(kZIndex.background)
	
	local themeData = kThemes[self.theme]
	local themeImages = getParalaxImagesForTheme(themeData)
	local drawRects = themeData.draw
	
	-- Initialize Properties
	
	for i, image in ipairs(themeImages) do
		local width, height = image:getSize()
		assert(width == 400 and height == 240, "Only images with size 400x240 are supported for the parallax background.")
		
		-- Draw image twice
		
		local doubleImage = gfx.image.new(800, 240)
		gfx.pushContext(doubleImage)
		gfx.drawImage(image, 0, 0)
		gfx.drawImage(image, 400, 0)
		gfx.popContext()
		
		table.insert(images, doubleImage)
	end
	
	imagesCount = #images
	maxParallax = -(imagesCount * 400)
	
	-- Build draw rects for each layer, using draw rect and avoiding to redraw any opaque zones from previous ones
	
	for i=1, imagesCount do
		local x, y, w, h = table.unpack(drawRects[i])
		table.insert(imageRectsX, x)
		table.insert(imageRectsY, y)
		table.insert(imageRectsW, w)
		table.insert(imageRectsH, h)
	end
	
	-- Build a table with ratios from 0 to 1 for multiplying the offset
	
	ratio = table.create(imagesCount, 0)
	for i=imagesCount, 1, -1 do
		table.insert(ratio, i == imagesCount and 0 or 1 / i)
	end
	
	-- Build a table with parallax offsets
	
	paralaxOffsets = table.create(imagesCount, 0)
	for i=imagesCount, 1, -1 do
		table.insert(paralaxOffsets, 0)
	end
end

function WidgetBackground:_draw(frame, rect)
	if rect == nil then
		rect = frame
	end
	
	local _rectX, _rectY, _rectW, _rectH = rect:unpack()
	
	local imageOffset
	for i, image in ipairs(images) do
		local imageX = imageRectsX[i] + paralaxOffsets[i]
		local x,y,w,h
		if imageX < 0 then
			x, y, w, h = _fast_intersection(_rectX, _rectY, _rectW, _rectH, 0, imageRectsY[i], 400, imageRectsH[i])
		else
			x, y, w, h = _fast_intersection(_rectX, _rectY, _rectW, _rectH, imageX, imageRectsY[i], imageRectsW[i], imageRectsH[i])
		end
		_draw(image, x, y, _kImageUnflipped, -paralaxOffsets[i] + x, y, w, h)
	end
end

function WidgetBackground:_update()
	local previousOffset <const> = offset
	--offset -= 1 -- debug
	offset = gfx.getDrawOffset() * paralaxRatio
	offset = offset % maxParallax
	
	for i=1, imagesCount do
		paralaxOffsets[i] = (i - 1) * offset % 400 - 400
	end
	
	if offset ~= previousOffset then
		self.sprite:markDirty()
	end
end

function WidgetBackground:_unload()
	self.sprite:remove()
	
	for i=1, #images do
		table.remove(images)
		table.remove(paralaxOffsets)
		table.remove(imageRectsX)
		table.remove(imageRectsY)
		table.remove(imageRectsW)
		table.remove(imageRectsH)
	end
end