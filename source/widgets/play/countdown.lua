

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
countdown = true

function WidgetCountdown:init(config)
	self.config = config
	
	self.painters = {}
	self.images = {}

	self:supply(Widget.deps.timers)
	
	self:createSprite(kZIndex.overlay)
	
	self.signals = {}
end

function WidgetCountdown:_load()

	self.levelStartCountdown = function()
		countdown = true
		self:performAfterDelay(600, function()
			countdown_image = countdown_table:getImage(1)
			gfx.sprite.addDirtyRect(168, 72, 64, 96)
			screenShake(100, 2)
			print("3")
			self:performAfterDelay(600, function()
				countdown_image = countdown_table:getImage(2)
				gfx.sprite.addDirtyRect(108, 72, 184, 96)
				screenShake(100, 2)
				print("2")
				
				self:performAfterDelay(600, function()
					countdown_image = countdown_table:getImage(3)
					gfx.sprite.addDirtyRect(108, 72, 184, 96)
					screenShake(100, 2)
					print("1")
					self:performAfterDelay(600, function()
						countdown_image = countdown_table:getImage(4)
						gfx.sprite.addDirtyRect(108, 72, 184, 96)
						screenShake(100, 2)
						print("GO")
						self:performAfterDelay(300, function()
							countdown = false
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
	if countdown then
		countdown_image:drawCentered(200,120)
	end
end

function WidgetCountdown:_update()
	
end

function WidgetCountdown:_unload()
	self.sprite:remove()
	
	self.images = nil
	self.painters = nil
	
	for _, child in pairs(self.children) do child:unload() end
	self.children = nil
end