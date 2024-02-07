local file <const> = playdate.file

class("WidgetLoaderUser").extends(Widget)

function WidgetLoaderUser:init()
	self.user = "user"
end

function WidgetLoaderUser:_load()
	local filePath = kFilePath.user.."/"..self.user..".json"
	local userData
	
	local loadUserFile = function()
		userData = json.decodeFile(filePath) or { coinCount = 0 }
	end
	
	local writeUserFile = function()
		json.encodeToFile(filePath, userData)
	end
	
	self.getCoinCount = function()
		loadUserFile()
		
		return userData.coinCount
	end
	
	self.onPlaythroughComplete = function(data)
		userData.coinCount += data.coins
	end
end
