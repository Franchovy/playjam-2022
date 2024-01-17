import "settings"

local sound <const> = playdate.sound

class("FilePlayer").extends()

FilePlayer._fileplayers = table.create(0, 4)
FilePlayer.config = {
	volume = 1.0
}
setmetatable(FilePlayer._fileplayers, table.weakValuesMetatable)

function FilePlayer:init(loopPath, introPath)
	if introPath ~= nil then
		self.intro = sound.fileplayer.new(introPath)
		self.intro:setFinishCallback(function() self:onIntroFinished() end)
		
		-- Load File
		self.intro:play(0)
		self.intro:pause()
		
		self.intro:setVolume(FilePlayer.config.volume)
	end
	
	self.loop = sound.fileplayer.new(loopPath)
	
	-- Load File
	self.loop:play(0)
	self.loop:pause()
	
	self.isPlayingIntro = self.intro ~= nil
	
	self.loop:setVolume(FilePlayer.config.volume)
	
	table.insert(FilePlayer._fileplayers, self)
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
	
	self.isPlayingIntro = self.intro ~= nil
end

function FilePlayer:onIntroFinished() 
	if self.intro:getOffset() >= self.intro:getLength() then
		self.isPlayingIntro = false
		
		self.loop:play(0)
	end
end

Settings:addCallback(kSettingsKeys.musicVolume, function(value)
	FilePlayer.config.volume = value
	
	for _, player in pairs(FilePlayer._fileplayers) do
		if player.intro ~= nil then
			player.intro:setVolume(value)
		end
		
		if player.loop ~= nil then
			player.loop:setVolume(value)
		end
	end
end)