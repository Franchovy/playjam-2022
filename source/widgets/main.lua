import "common/loading"
import "constant"
import "engine"
import "menu"
import "play"
import "utils/level"

class("WidgetMain").extends(Widget)

function WidgetMain:init()	
	self:supply(Widget.kDeps.children)
	self:supply(Widget.kDeps.state)
	
	self.kStates = { menu = 1, play = 2 }
	self.state = self.kStates.menu
	
	self:createSprite()
	self.sprite:setZIndex(1)
	self.sprite:add()
	
	self.data = {}
	
	self.data.highscores = {}
end

function WidgetMain:_load()
	self.onPlaythroughComplete = function(data)
		-- TODO: if stats enabled, write (append) playthrough data into an existing or new file
		
		-- Write data into high-scores file
		
		if not playdate.file.exists(kFilePath.saves) then
			playdate.file.mkdir(kFilePath.saves)
		end
		
		local filePath = kFilePath.saves.. "/".. self.level.title
		
		local saveFileRead = playdate.file.open(filePath, playdate.file.kFileRead)
		
		local shouldWriteToFile
		local existingContents
		
		if saveFileRead ~= nil then
			existingContents = json.decodeFile(saveFileRead)
		end
		
		if saveFileRead == nil or (existingContents == nil) then	
			shouldWriteToFile = true
		else
			function scoreCalculation(coinCount, time, timeObjective)
				return coinCount + (timeObjective - time) * 50
			end
			local previousScore = scoreCalculation(existingContents.coinCount, tonumber(existingContents.timeString), tonumber(existingContents.timeStringObjective))
			local currentScore = scoreCalculation(data.coinCount, tonumber(data.timeString), tonumber(data.timeStringObjective))
			
			shouldWriteToFile = previousScore < currentScore
		end
		
		if saveFileRead ~= nil then
			saveFileRead:close()
		end
		
		if shouldWriteToFile then
			local saveFileWrite = playdate.file.open(filePath, playdate.file.kFileWrite)
			json.encodeToFile(saveFileWrite, true, data)
			saveFileWrite:close()
		end
		
		self.loadHighscores()
	end
	
	self.onReturnToMenu = function()
		self:setState(self.kStates.menu)
	end
	
	self.onMenuPressedPlay = function(level)
		self.level = level
		self:setState(self.kStates.play)
	end
	
	self.getNextLevelConfig = function()
		for _, v in pairs(kLevels) do
			if v.levelFileName == self.level.path then
				self.level = nil
			elseif self.level == nil then
				self.level = v
			end
		end
		
		if self.level ~= nil then
			return loadLevelFromFile(self.level.path)
		end
	end
	
	-- High Scores
	
	self.loadHighscores = function()
		if not playdate.file.exists(kFilePath.saves) then
			playdate.file.mkdir(kFilePath.saves)
		end
		
		local data = {}
		local saveFiles = playdate.file.listFiles(kFilePath.saves)
		for _, fileName in pairs(saveFiles) do
			local path = kFilePath.saves.. "/".. fileName
			local saveFile = playdate.file.open(path, playdate.file.kFileRead)
			
			if saveFile ~= nil then
				data[fileName] = json.decodeFile(saveFile)
			end
		end
		
		return data
	end
	
	self.data.highscores = self.loadHighscores()
	
	--
	
	self.children.menu = Widget.new(WidgetMenu, { levels = kLevels, scores = self.data.highscores })
	self.children.menu:load()
	
	self.children.menu.signals.play = self.onMenuPressedPlay
	
	self.children.loading = Widget.new(WidgetLoading)
	self.children.loading:load()
	self.children.loading:setVisible(false)
end

function WidgetMain:_draw(rect)
	if self.state == self.kStates.menu and (self.children.menu ~= nil) then
		self.children.menu:draw(rect)
	end
	
	if self.state == self.kStates.play and (self.children.play ~= nil) then
		self.children.play:draw(rect)
	end
	
	self.children.loading:draw(rect)
end

function WidgetMain:_update()
	
end

function WidgetMain:_input()
	
end

function WidgetMain:changeState(stateFrom, stateTo)
	if stateFrom == self.kStates.menu and (stateTo == self.kStates.play) then
		self.children.menu:setVisible(false)
		self.children.loading:setVisible(true)
		
		playdate.timer.performAfterDelay(10, function()
			local levelConfig = loadLevelFromFile(self.level.path)
			
			if self.children.play == nil then
				self.children.menu:unload()
				self.children.menu = nil
				
				collectgarbage("collect")
				
				self.children.play = Widget.new(WidgetPlay, levelConfig)
				self.children.play:load()
				
				self.children.play.signals.saveLevelScore = self.onPlaythroughComplete
				self.children.play.signals.returnToMenu = self.onReturnToMenu
				self.children.play.signals.getNextLevelConfig = self.getNextLevelConfig
				
				self.children.loading:setVisible(false)
			end
		end)
	elseif stateFrom == self.kStates.play and (stateTo == self.kStates.menu) then
		self.children.loading:setVisible(true)
		self.children.play:setVisible(false)
		
		playdate.timer.performAfterDelay(10, function()
			self.children.play:unload()
			self.children.play = nil 
			
			collectgarbage("collect")
			
			self.children.menu = Widget.new(WidgetMenu, { levels = kLevels })
			self.children.menu:load()
			
			self.children.menu.signals.play = self.onMenuPressedPlay
			
			self.children.loading:setVisible(false)
		end)
	end
end