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
		self[name]:play(callback)
	else 
		self[name]:play()
	end
end