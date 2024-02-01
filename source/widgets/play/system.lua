class("WidgetSystem").extends(Widget)

local menu <const> = playdate.getSystemMenu()

function WidgetSystem:init()
    self.signals = {}
end

function WidgetSystem:_load()
    menu:addMenuItem("restart level", function()
        self.signals.restartLevel()
    end)

    menu:addMenuItem("main menu", function()
        self.signals.returnToMenu()
    end)
end

function WidgetSystem:_unload()
    menu:removeAllMenuItems()
end