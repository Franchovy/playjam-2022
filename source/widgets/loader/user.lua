local file <const> = playdate.file

class("WidgetLoaderUser").extends(Widget)

function WidgetLoaderUser:_init()
	self.user = "user"
end

function WidgetLoaderUser:_load()
	local filePath = kFilePath.user.."/"..self.user..".json"
	local userData
	
	local loadUserFile = function()
		if file.exists(filePath) then
			local file = file.open(filePath, file.kFileRead)
			userData = json.decodeFile(file)
		else
			userData = { coinCount = 0 }
		end
	end
	
	local writeUserFile = function()
		if file.exists(kFilePath.user) == false then
			file.mkdir(kFilePath.user)
		end
		
		local file = file.open(filePath, file.kFileWrite)
		json.encodeToFile(file, userData)
	end
	
	self.getCoinCount = function()
		loadUserFile()
		
		return userData.coinCount
	end
	
	self.onPlaythroughComplete = function(data)
		userData.coinCount += data.coins
		
		writeUserFile()
	end
end
