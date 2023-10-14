import "engine"

class("Score").extends(playdate.sprite)

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
	
	self:setCenter(0, 0)
	self:setIgnoresDrawOffset(true)
	self:drawScore()
	self:moveTo(6, 6)
end

function Score:drawScore()
	local textWidth, textHeight = gfx.getTextSize(self.scoreText)
	local horizontalMargin = 8
	local verticalMargin = 4
	local image = gfx.image.new(textWidth + horizontalMargin * 2, textHeight + verticalMargin * 2)
	local width, height = image:getSize()
	
	gfx.pushContext(image)
	-- Draw outer and background rectangle
	gfx.setColor(colors.white)
	gfx.fillRoundRect(0, 0, width, height, 8)
	gfx.setColor(colors.black)
	gfx.setLineWidth(2)
	gfx.drawRoundRect(0, 0, width, height, 8)
	-- Draw Score text
	--gfx.drawTextAligned(self.scoreText, horizontalMargin, verticalMargin, textAlignment.left)
	gfx.popContext()
	
	self:setImage(image)
end
	
function Score:setScoreText(scoreText) 
	self.scoreText = "*"..scoreText.."*"
	self:drawScore()
end
	
	