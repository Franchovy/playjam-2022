import "engine"

PATHS = {}
PATHS.levels = "levels"

function createLevelPathIfNeeded() 
	if not playdate.file.isdir(PATHS.levels) then
		playdate.file.mkdir(PATHS.levels)
	end
end

function getLevelFiles()
	if playdate.file.exists(PATHS.levels) and playdate.file.isdir(PATHS.levels) then
		return playdate.file.listFiles(PATHS.levels)
	end
	
	return {}
end

function importLevel(fileName)
	if fileName == nil then
		return
	end
	
	local path = PATHS.levels.."/"..fileName
	local levelData = json.decodeFile(path)
	
	return levelData
end
