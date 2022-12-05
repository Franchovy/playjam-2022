import "engine"

class("Score").extends(Sprite)

function Score.new(scoreText)
	return Score(scoreText)
end

function Score:init(scoreText)
	local boldScoreText = "*"..scoreText.."*"
	local image = gfx.image.new(gfx.getTextSize(boldScoreText))
	Score.super.init(self, image)
	
	-- Set Properties
	
	self.scoreText = boldScoreText
	
	-- Configure display
	
	self:setIgnoresDrawOffset(true)
	self:drawScore()
	self:moveTo(42, 28)
end

function Score:drawScore()
	local image = gfx.image.new(gfx.getTextSize(self.scoreText))	
	
	gfx.pushContext(image)
	gfx.drawTextAligned(self.scoreText, 0, 0, textAlignment.left)
	gfx.popContext()
	
	self:setImage(image)
end
	
function Score:setScoreText(scoreText) 
	self.scoreText = "*"..scoreText.."*"
	self:drawScore()
end
	
	