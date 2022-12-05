import "CoreLibs/object"


-- Libraries

local sound <const> = playdate.sound

--

sampleplayer = {}

function sampleplayer:addSample(name, filePath)
	self[name] = sound.sampleplayer.new(filePath)
end

function sampleplayer:playSample(name, callback)
	if callback then
		self[name]:setFinishCallback(callback)
	end
	
	self[name]:play()
end