import "CoreLibs/object"
import "CoreLibs/sprites"

local gfx <const> = playdate.graphics

class("Sprite").extends(gfx.sprite)

-- ===============
-- ---------------
-- Overrides

function Sprite:init(image)
	Sprite.super.init(self, image)
	
	self.type = "unset"
	self.isAdded = false
end

-- Global sprite update function
function Sprite.update()
	Sprite.super.update()
end

----------------------
-- Add/Remove override

function Sprite:add() 
	Sprite.super.add(self)
	self.isAdded = true
end

function Sprite:remove()
	Sprite.super.remove(self)
	self.isAdded = false
end

-----------------------
-- Sprite Config

function Sprite:loadConfig(config)
	
end

function Sprite:updateConfig(config)
	
end