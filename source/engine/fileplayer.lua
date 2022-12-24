import "CoreLibs/object"

local sound <const> = playdate.sound

class("FilePlayer").extends()

function FilePlayer:init(pathName)
	self.intro = sound.fileplayer.new(pathName.."/intro")
	self.intro:setFinishCallback(function() self:onIntroFinished() end)
	
	-- Load File
	self.intro:play(0)
	self.intro:pause()
	
	self.loop = sound.fileplayer.new(pathName.. "/loop")
	
	-- Load File
	self.loop:play(0)
	self.loop:pause()
	
	self.isPlayingIntro = true
end

function FilePlayer:play()
	if self.isPlayingIntro then
		self.intro:play()
	else
		self.loop:play(0)
	end
end

function FilePlayer:stop()
	if self.isPlayingIntro then
		self.intro:stop()
	else
		self.loop:stop()
	end
end

function FilePlayer:onIntroFinished() 
	if self.intro:getOffset() >= self.intro:getLength() then
		self.isPlayingIntro = false
		
		self.loop:play(0)
	end
end