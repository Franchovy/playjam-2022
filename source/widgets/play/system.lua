class("WidgetSystem").extends(Widget)

local menu <const> = playdate.getSystemMenu()

function WidgetSystem:_init()
    self.signals = {}
end

function WidgetSystem:_load()
    menu:addMenuItem("restart level", function()
        self.signals.restartLevel()
    end)

    menu:addMenuItem("main menu", function()
        self.signals.returnToMenu()
    end)
    
    --DEBUG: Garbage Collect
    --[[ 
    menu:addMenuItem("garage collect", function()
        collectgarbage()
    end)
    --]]
end

function WidgetSystem:_unload()
    menu:removeAllMenuItems()
end