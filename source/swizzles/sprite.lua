import "CoreLibs/object"
import "CoreLibs/graphics"
import "extensions"

local graphics <const> = playdate.graphics

graphics.sprite.setImageSwizzled = graphics.sprite.setImage

function graphics.sprite:setImage(path, count)
	if type(path) ~= "string" then
		self:setImageSwizzled(path)
		return
	end
	
	local transforms = self.imageTransforms

	transforms = transforms or {}
	transforms.scale = transforms.scale or { x = 1, y = 1 }
	
	self:setImageSwizzled(
		getImage(path, count)
		:scaledImage(transforms.scale.x, transforms.scale.y)
	)
end
