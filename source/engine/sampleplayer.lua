import "CoreLibs/object"


-- Libraries

local sound <const> = playdate.sound

--

sampleplayer = {}

function sampleplayer:addSample(name, filePath, volume)
	self[name] = sound.sampleplayer.new(filePath)
	
	if volume ~= nil then
		self[name]:setVolume(volume)
	end
end

function sampleplayer:playSample(name, callback)
	if AppConfig.sfx.disabled then
		return 
	end
	
	if callback then
		self[name]:setFinishCallback(callback)
	end
	
	self[name]:play()
end