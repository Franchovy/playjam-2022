
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
							title = levelName:upper(),
							score = levelScore,
							locked = shouldLockLevel,
							path = dirWorld..levelName..".json"
						})
						
						-- Set if to lock next level
						shouldLockLevel = shouldLockLevel or levelScore == nil
					elseif file:match("^preview") then
						imagePath = dirWorld..file
					end
				end
				
				table.insert(levelsData, {
					title = worldName:upper(),
					levels = levels,
					locked = shouldLockWorld,
					score = worldScore,
					path = dirWorld,
					imagePath = imagePath
				})
				
				-- Set if to lock next world
				shouldLockWorld = shouldLockWorld or worldScore == nil
			end
		end
		
		self.levels = levelsData
	end
	
	local writePlaythroughToFile = function(worldTitle, levelTitle, stars, time, timeObjective)
		-- Write data into high-scores file
		
		if not file.exists(kFilePath.saves) then
			file.mkdir(kFilePath.saves)
		end
		
		local filePath = kFilePath.saves.. "/".. worldTitle
		
		local saveFileRead = file.open(filePath, file.kFileRead)
		
		local shouldWriteToFile
		local existingContents
		
		if saveFileRead ~= nil then
			existingContents = json.decodeFile(saveFileRead)
			
			saveFileRead:close()
		end
		
		if existingContents ~= nil and existingContents[levelTitle] ~= nil and existingContents[levelTitle].time ~= nil then
			shouldWriteToFile = time < existingContents[levelTitle].time
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
	
	
	-- High Scores
	
	local loadSaveDataFromFile = function(path, saveData)
		local fileData = json.decodeFile(path)
		for i, data in ipairs(fileData) do
			saveData[i] = data
		end
	end
	
	-- Interface functions
	
	self.onPlaythroughComplete = function(args)
		writePlaythroughToFile(
			args.worldTitle, 
			args.levelTitle, 
			args.stars, 
			args.time,
			args.timeObjective
		)
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
	