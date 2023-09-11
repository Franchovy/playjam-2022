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

function exportLevel(name, gameObjects) 
	if gameObjects == nil then
		return
	end
	
	createLevelPathIfNeeded()
	
	local exportData = {}
	for _, gameObject in pairs(gameObjects) do
		local itemPositionX, itemPositionY = getGridPosition(gameObject:getPosition())
		local itemData = {}
		itemData["x"] = itemPositionX
		itemData["y"] = itemPositionY
		table.insert(exportData, itemData)
	end
	
	local path = PATHS.levels.. "/".. name
	
	print("Exporting to file: ".. path.. "...")
	
	if playdate.file.exists(path) then
		print("File already exists! Overwriting...")
	end
	
	json.encodeToFile(path, exportData)
	
	print("Exported to file.")
end
