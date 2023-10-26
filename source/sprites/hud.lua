import "playdate"
import "assets"
import "utils/text"


class("Hud").extends(playdate.graphics.sprite)

function Hud:init()
	Hud.super.init(self)
	
	self:setSize(250, 80)
	self:setCenter(0, 0)
	self:setAlwaysRedraw(true)
	self:setIgnoresDrawOffset(true)
	
	self.coinImage = playdate.graphics.image.new(kAssetsImages.coin)
	
	self.timerValueString = "0.0"
	self.coinCountValue = 0
end

function Hud:updateCoinCount(value)
	self.coinCountValue = value
end

function Hud:updateTimer(timerValueMs)
	local decimal = math.floor(timerValueMs / 10)
	local seconds = math.floor(decimal / 100)
	
	if decimal < 10 then
		decimal = "0"..decimal
	end
	
	if seconds < 59 then
		
		self.timerValueString = string.sub(seconds, -2, -1).."."..string.sub(decimal, -2, -1)
	else 
		local minutes = math.floor(seconds / 60)
		
		self.timerValueString = minutes..":"..seconds.."."..decimal
	end
end

function Hud:draw()
	local coinCountImage = createTextImage(self.coinCountValue, 4, 4):scaledImage(2)
	local coinCountImageWidth, _ = coinCountImage:getSize()
	local coinImageWidth, _ = self.coinImage:getSize()
	local timerImage = createTextImage(self.timerValueString, 10, 4, 6):scaledImage(2)
	local timerImageWidth, _ = timerImage:getSize()
	
	local width = coinCountImageWidth + coinImageWidth + timerImageWidth
	local height = 32
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.setLineWidth(2)
	playdate.graphics.drawRoundRect(0, 0, width, height, 6)
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	playdate.graphics.setDitherPattern(0.25, playdate.graphics.image.kDitherTypeDiagonalLine)
	playdate.graphics.setLineWidth(1)
	playdate.graphics.fillRoundRect(2, 2, width - 4, height - 4, 6)
	
	coinCountImage:draw(0, 0)
	self.coinImage:draw(coinCountImageWidth, 4)
	timerImage:draw(coinCountImageWidth + coinImageWidth, 0)
	
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.setDitherPattern(1.0)
end