import "engine"

class('GameScene').extends(gfx.sprite)

GameScene.type = sceneTypes.gameScene

function GameScene:init()
	local backgroundImage = gfx.image.new("images/background")
	gfx.sprite.setBackgroundDrawingCallback(function()
		backgroundImage:draw(0, 0)
	end)

	self:add()
end