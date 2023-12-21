function samples(widget)
	function widget:loadSample(path, volume, key)
		if key == nil then
			key = path
		end
		self.samples[key] = playdate.sound.sampleplayer.new(path)
		
		if volume == nil then
			volume = 1
		end
		
		self.samples[key]:setVolume(volume)
	end
	
	function widget:playSample(key, finishedCallback)
		self.samples[key]:play()
		
		if finishedCallback ~= nil then
			self.samples[key]:setFinishCallback(finishedCallback)
		end
	end
	
	function widget:unloadSample(key)
		self.samples[key] = nil
	end
	
	widget.samples = {}
end

Widget.register("samples", samples)
	