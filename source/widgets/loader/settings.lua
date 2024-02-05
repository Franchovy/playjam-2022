
class("WidgetLoaderSettings").extends(Widget)

function WidgetLoaderSettings:init()
	WidgetLoaderSettings.super.init(self)
	
end

function WidgetLoaderSettings:_load()
	if Settings:existsSettingsFile() then
		Settings:readFromFile()
	else 
		Settings:setDefaultValues()
	end
end

function WidgetLoaderSettings:_unload()
	
end
	