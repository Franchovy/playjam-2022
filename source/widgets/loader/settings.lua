
class("WidgetLoaderSettings").extends(Widget)

function WidgetLoaderSettings:_load()
	if Settings:existsSettingsFile() then
		Settings:readFromFile()
	else 
		Settings:setDefaultValues()
	end
end
