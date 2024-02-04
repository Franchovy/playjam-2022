class("DebugCanvas").extends()

local instance = nil
function DebugCanvas:init()
    instance = self
    self.persistentDrawingCallbacks = {}
    self.drawingCallbacks = {}
end

function DebugCanvas.instance()
    return instance
end

function DebugCanvas:addDrawCall(call)
    table.insert(self.drawingCallbacks, call)
end
function DebugCanvas:addPersistentDrawCall(call)
    table.insert(self.persistentDrawingCallbacks, call)
end

function DebugCanvas:draw()

    for _, call in pairs(self.persistentDrawingCallbacks) do
        call()
    end
    for _, call in pairs(self.drawingCallbacks) do
        call()
    end

    self.drawingCallbacks = {}
end