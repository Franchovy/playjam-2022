
local file <const> = playdate.file

class("WidgetLoaderLevel").extends(Widget)

function WidgetLoaderLevel:init()
	WidgetLoaderLevel.super.init(self)
	
	self.data = {
		highscores = {}
	}
end

function WidgetLoaderLevel:_load()
	
	-- Load levels
	
	local getScoresForWorld = function(worldName)
		
		-- High Scores
		
		if not file.exists(kFilePath.saves) then
			file.mkdir(kFilePath.saves)
		end

		local worldScore = nil
		local levelScores = {}

		local saveFilePath = kFilePath.saves.."/"..worldName..".json"
		if file.exists(saveFilePath) == true and file.isdir(saveFilePath) then
			local levelFiles = file.listFiles(saveFilePath)
			for _, fileName in pairs(levelFiles) do
				local levelTitle = saveFile:sub(1, #fileName - 5)
				local saveData = {}
				if fileName:match("^.+.json$") and table.contains(self.levels, levelTitle) then
					if pcall(function() loadSaveDataFromFile(kFilePath.saves.. "/".. fileName, saveData) end) then
						if saveData ~= nil 
								and saveData.stars ~= nil 
								and saveData.time ~= nil then	
									
							levelScores[levelTitle] = {
								stars = saveData.stars,
								time = saveData.time
							}
							
							if worldScore == nil then
								worldScore = 0
							end
							
							worldScore += saveData.stars
						end
					else
						print("Error: could not load json file: ".. fileName)
					end
				end
			end
		end
		
		return worldScore, levelScores
	end
	
	local loadLevels = function()
		local pathsWorlds = file.listFiles(kFilePath.levels)
		local levelsData = table.create(3, 0)
		
		local shouldLockWorld = false
		
		for i, pathWorld in ipairs(pathsWorlds) do
			local dirWorld = kFilePath.levels.."/"..pathWorld
			if file.isdir(dirWorld) then
				local worldName = pathWorld:match("^[^/]+")
				local levels = table.create(8, 0)
				local worldScore, levelScores = getScoresForWorld(worldName)
				local imagePath = nil
				local shouldLockLevel = shouldLockWorld
				
				local rawFiles = file.listFiles(dirWorld)
				for _, file in pairs(rawFiles) do
					if file:match("^.+.json$") ~= nil then
						local levelName = file:sub(1, #file-5)
						local levelScore = levelScores[levelName]
						
						table.insert(levels, {
							title = levelName,
							score = levelScore,
							locked = shouldLockLevel
						})
						
						-- Set if to lock next level
						shouldLockLevel = shouldLockLevel and levelScore ~= nil
					elseif file:match("^preview") then
						imagePath = dirWorld..file
					end
				end
				
				table.insert(levelsData, {
					title = worldName,
					levels = levels,
					locked = shouldLockWorld,
					score = worldScore,
					imagePath = imagePath
				})
				
				-- Set if to lock next world
				shouldLockWorld = shouldLockWorld and worldScore ~= nil
			end
		end
		
		self.levels = levelsData
	end
	
	local writePlaythroughToFile = function(data, levelTitle)
		-- Write data into high-scores file
		
		if not file.exists(kFilePath.saves) then
			file.mkdir(kFilePath.saves)
		end
		
		local filePath = kFilePath.saves.. "/".. levelTitle
		
		local saveFileRead = file.open(filePath, file.kFileRead)
		
		local shouldWriteToFile
		local existingContents
		
		if saveFileRead ~= nil then
			existingContents = json.decodeFile(saveFileRead)
		end
		
		if saveFileRead == nil or (existingContents == nil) then	
			shouldWriteToFile = true
		else
			function scoreCalculation(coinCount, time, timeObjective)
				function timeStringToNumber(timeString)
					if timeString:find(":")  then
						local minutes, seconds = timeString:match("(%d+):(%d+)")
						return tonumber(minutes) * 60 + tonumber(seconds)
					else
						return tonumber(timeString)
					end
				end
				
				return coinCount + (timeStringToNumber(timeObjective) - timeStringToNumber(time)) * 50
			end
			
			local previousScore = scoreCalculation(existingContents.coinCount, existingContents.timeString, existingContents.timeStringObjective)
			local currentScore = scoreCalculation(data.coinCount, data.timeString, data.timeStringObjective)
			
			shouldWriteToFile = previousScore < currentScore
		end
		
		if saveFileRead ~= nil then
			saveFileRead:close()
		end
		
		if shouldWriteToFile then
			local saveFileWrite = file.open(filePath, file.kFileWrite)
			json.encodeToFile(saveFileWrite, true, data)
			saveFileWrite:close()
		end
	end
	
	
	-- High Scores
	
	local loadSaveDataFromFile = function(path, saveData)
		local fileData = json.decodeFile(path)
		for i, data in ipairs(fileData) do
			saveData[i] = data
		end
	end
	
	-- Interface functions
	
	self.onPlaythroughComplete = function(self, data, levelTitle)
		writePlaythroughToFile(data, levelTitle)
	end
	
	self.refresh = function(self)
		loadLevels()
	end
	
	self.getLevels = function(self)
		return self.levels, {}, {}
	end
end

function WidgetLoaderLevel:_unload()
	
end
	