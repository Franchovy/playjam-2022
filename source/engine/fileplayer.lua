import "settings"

class("FilePlayer").extends()

FilePlayer._fileplayers = table.weakValuesTable()

function FilePlayer:init(loopPath, introPath)
	if introPath ~= nil then
		self.intro = playdate.sound.fileplayer.new(introPath)
		self.intro:setFinishCallback(function() self:onIntroFinished() end)
		
		-- Load File
		self.intro:play(0)
		self.intro:pause()
	end
	
	self.loop = playdate.sound.fileplayer.new(loopPath)
	
	-- Load File
	self.loop:play(0)
	self.loop:pause()
	
	self.isPlayingIntro = self.intro ~= nil
	
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
	for _, player in pairs(FilePlayer._fileplayers) do
		if player.intro ~= nil then
			player.intro:setVolume(value)
		end
		
		if player.loop ~= nil then
			player.loop:setVolume(value)
		end
	end
end)