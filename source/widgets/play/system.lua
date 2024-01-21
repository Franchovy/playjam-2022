class("WidgetSystem").extends(Widget)

function WidgetSystem:init()
    self.menu = playdate.getSystemMenu()

    self.signals = {}
end

function WidgetSystem:_load()
    self.menu:addMenuItem("Restart level", 
    function()
        self.signals.restartLevel()
    end)

    self.menu:addMenuItem("Return menu",
    function()
        self.signals.returnToMenu()
    end)
end

function WidgetSystem:_unload()
    self.menu:removeAllMenuItems()
end