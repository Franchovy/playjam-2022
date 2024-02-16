

local gfx <const> = playdate.graphics
local timer <const> = playdate.timer
local disp <const> = playdate.display
local geo <const> = playdate.geometry

import "widgets/common/entriesMenu"

local gfx <const> = playdate.graphics
local timer <const> = playdate.timer

class("WidgetCountdown").extends(Widget)

countdown_table = gfx.imagetable.new('assets/images/sprites/countdown.gif')
countdown_image = countdown_table:getImage(1)

function WidgetCountdown:_init()
	self:supply(Widget.deps.frame)
	self:supply(Widget.deps.timers)
	
	self:setFrame(disp.getRect())
	
	self.painters = {}
	self.images = {}
	
	self:createSprite(kZIndex.overlay)
	
	self.signals = {}
end

function WidgetCountdown:_load()

	self.levelStartCountdown = function()
		self:setVisible(true)
		self:performAfterDelay(600, function()
			countdown_image = countdown_table:getImage(1)
			gfx.sprite.addDirtyRect(168, 72, 64, 96)
			screenShake(100, 2)
			
			self:performAfterDelay(600, function()
				countdown_image = countdown_table:getImage(2)
				gfx.sprite.addDirtyRect(108, 72, 184, 96)
				screenShake(100, 2)
				
				self:performAfterDelay(600, function()
					countdown_image = countdown_table:getImage(3)
					gfx.sprite.addDirtyRect(108, 72, 184, 96)
					screenShake(100, 2)
					
					self:performAfterDelay(600, function()
						countdown_image = countdown_table:getImage(4)
						gfx.sprite.addDirtyRect(108, 72, 184, 96)
						screenShake(100, 2)
						
						self:performAfterDelay(500, function()
							self:setVisible(false)
							gfx.sprite.addDirtyRect(108, 72, 184, 96)
							countdown_image = countdown_table:getImage(5)
						end)
						
						self.signals.finished()
					end)
				end)
			end)
		end)
	end

	self.levelStartCountdown()
end

function WidgetCountdown:_draw(rect)
	countdown_image:drawCentered(200,120)
end

function WidgetCountdown:_update()
	
end

function WidgetCountdown:_unload()
	self.images = nil
	self.painters = nil
	
	for _, child in pairs(self.children) do child:unload() end
	self.children = nil
end