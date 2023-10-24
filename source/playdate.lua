
-- Object / Generic

import "CoreLibs/object"

import "playdate/extensions/buttons"

-- File

import "playdate/extensions/file"

-- Sprites

import "CoreLibs/sprites"

playdate.sprite = playdate.graphics.sprite

function playdate.sprite.loadConfig(self, config)
	-- Not Implemented
end

function playdate.sprite.updateConfig(self, config)
	-- Not Implemented
end

import "playdate/constant/kCollisionResponse"

-- Animations

import "CoreLibs/animation"

-- Timers

import "CoreLibs/timer"
