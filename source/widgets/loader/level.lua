
local file <const> = playdate.file
local _convertMsTimeToString <const> = convertMsTimeToString

class("WidgetLoaderLevel").extends(Widget)

function WidgetLoaderLevel:_init()
	self.levels = nil
end

function WidgetLoaderLevel:_load()
	
	-- Load level objectives 
	
	local loadObjectivesFile = function(filePath)
		-- Default number of stars to score by, usually 3 but can be 4 for expert players.
		local starScoringType = Settings:getValue(kSettingsKeys.scoring) == "3-STAR" and 3 or 4
		
		local contents = json.decodeFile(filePath)
		local worldObjectives = { stars = 0, levels = 0 }
		local levelObjectives = table.create(0, #contents)
		
		for levelName, objectives in pairs(contents) do
			levelObjectives[levelName:upper()] = {
				all = objectives,
				time = objectives[starScoringType],
				timeString = _convertMsTimeToString(objectives[starScoringType] * 10, 1)
			}
			worldObjectives.stars += starScoringType
			worldObjectives.levels += 1
		end
		
		return worldObjectives, levelObjectives
	end
	
	-- Load High Scores from file
	
	local loadSaveDataFromFile = function(path, saveData)
		local fileData = json.decodeFile(path)
		for i, data in pairs(fileData) do
			saveData[i] = data
		end
	end
	
	-- Load levels
	
	local getScoresForWorld = function(worldName)
		
		-- High Scores
		
		if not file.exists(kFilePath.saves) then
			file.mkdir(kFilePath.saves)
		end

		local worldScore = { stars = 0, levels = 0 }
		local levelScores = {}

		local saveFilePath = kFilePath.saves.."/"..worldName..".json"
		if file.exists(saveFilePath) == true and file.isdir(saveFilePath) == false then
			local saveData = {}
			if pcall(function() loadSaveDataFromFile(saveFilePath, saveData) end) and saveData ~= nil then
				for levelTitle, saveDataLevel in pairs(saveData) do
					if saveDataLevel ~= nil 
							and saveDataLevel.stars ~= nil 
							and saveDataLevel.time ~= nil then	
								
						levelScores[levelTitle] = {
							stars = tonumber(saveDataLevel.stars),
							time = saveDataLevel.time,
							timeString = _convertMsTimeToString(saveDataLevel.time * 10, 1)
						}
						
						worldScore.stars += saveDataLevel.stars
						worldScore.levels += 1
					end
				end
			else
				print("Error: could not load json file: ".. fileName)
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
				local worldNameRaw = pathWorld:match("^[^/]+")
				local worldIndex = tonumber(worldNameRaw:sub(1, 1))
				local worldName = worldNameRaw:sub(3):upper()
				local levels = table.create(8, 0)
				local worldScore, levelScores = getScoresForWorld(worldName)
				local shouldLockLevel = shouldLockWorld
				local imagePath, worldObjectives, levelObjectives
				
				local rawFiles = file.listFiles(dirWorld)
				for _, file in pairs(rawFiles) do
					if file:match("^%d_.+.json$") ~= nil then
						local levelIndex = tonumber(file:sub(1, 1))
						local levelName = file:sub(3, #file-5):upper()
						local levelScore = levelScores[levelName]
						
						levels[levelIndex] = {
							title = levelName,
							score = levelScore,
							locked = shouldLockLevel,
							path = dirWorld..file
						}
						
						-- Set if to lock next level
						shouldLockLevel = shouldLockLevel or levelScore == nil
					elseif file:match("^preview") then
						imagePath = dirWorld..file
					elseif file:match("objectives.json") then
						worldObjectives, levelObjectives = loadObjectivesFile(dirWorld..file)
					end
				end
				
				for _, level in ipairs(levels) do
					level.objectives = levelObjectives[level.title]
				end
				
				levelsData[worldIndex] = {
					title = worldName,
					levels = levels,
					locked = shouldLockWorld,
					score = worldScore,
					path = dirWorld,
					objectives = worldObjectives,
					imagePath = imagePath
				}
				
				-- Set if to lock next world
				shouldLockWorld = shouldLockWorld or worldScore.levels == 0
			end
		end
		
		self.levels = levelsData
	end
	
	local writePlaythroughToFile = function(worldTitle, levelTitle, stars, time)
		-- Write data into high-scores file
		
		if not file.exists(kFilePath.saves) then
			file.mkdir(kFilePath.saves)
		end
		
		local filePath = kFilePath.saves.. "/".. worldTitle:lower()..".json"
		
		local saveFileRead = file.open(filePath, file.kFileRead)
		
		local shouldWriteToFile
		local existingContents
		
		if saveFileRead ~= nil then
			existingContents = json.decodeFile(saveFileRead)
			
			saveFileRead:close()
		end
		
		if existingContents ~= nil and existingContents[levelTitle] ~= nil and existingContents[levelTitle].time ~= nil then
			shouldWriteToFile = tonumber(time) < tonumber(existingContents[levelTitle].time)
		else
			shouldWriteToFile = true
		end
		
		-- Inside save file: 
		--[[ mountain.json
			{ 
				"levelName": {
					time: 185312 (ms),
					stars: 3
				}
			}
		--]]
		
		if shouldWriteToFile then
			local saveFileWrite = file.open(filePath, file.kFileWrite)
			local data = existingContents or {}
			data[levelTitle] = {
				time = time,
				stars = stars
			}
			json.encodeToFile(saveFileWrite, true, data)
			saveFileWrite:close()
		end
	end

	-- Interface functions
	
	self.onPlaythroughComplete = function(args)
		writePlaythroughToFile(
			args.worldTitle, 
			args.levelTitle, 
			args.stars, 
			args.time
		)
	end
	
	self.refresh = function(self)
		loadLevels()
	end
	
	self.getLevels = function(self)
		return self.levels
	end
	
	self.getNextLevel = function(self, level)
		local worldIndex = table.firstIndex(self.levels, function(element) return element.title == level.worldTitle end)
		local levels = self.levels[worldIndex].levels
		local currentLevelIndex = table.firstIndex(levels, function(element) return element.title == level.levelTitle end)
		local nextLevelIndex = currentLevelIndex + 1
		
		if #levels < nextLevelIndex then
			-- Return next world
			local nextWorldIndex = worldIndex + 1
			
			if self.levels[nextWorldIndex] ~= nil then
				return self.levels[nextWorldIndex].levels[1], self.levels[nextWorldIndex]
			else
				-- No worlds left!
				return nil
			end
		else
			return levels[nextLevelIndex]
		end
	end
end
