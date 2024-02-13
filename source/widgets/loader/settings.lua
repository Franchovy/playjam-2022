
class("WidgetLoaderSettings").extends(Widget)

function WidgetLoaderSettings:_load()
	if Settings:existsSettingsFile() then
		Settings:readFromFile()
	end
	Settings:setDefaultValues()
end
