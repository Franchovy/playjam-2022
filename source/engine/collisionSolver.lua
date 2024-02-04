import "engine/debugCanvas"

class("CollisionSolver").extends()

local gfx <const> = playdate.graphics

local instance = nil
function CollisionSolver:init()
    assert(instance == nil, "A CollisionSolver instance already exists. Only one CollisionSolver instance may exist")
    instance = self

    self.colliders = {}

    -- Colliders will be stored by collision type
    self.collisionTypesList = {}
    for _, colTypeIdx in pairs(kCollisionType) do
        self.colliders[colTypeIdx] = {}
        table.insert(self.collisionTypesList, colTypeIdx)
    end

end

function CollisionSolver.instance()
    -- we'd usually check if the instance exists but we are not doing that here 🚫
    return instance
end

function dump(o)

    if type(o) == 'table' then
        if o.className ~= nil then
            return o.className
        end

        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

function CollisionSolver:_addColliderToGridPosition(collisionType, collider)
    local gridPosX, gridPosY = kGame.worldPosToGrid(collider.x, collider.y)

    -- grid is represented as a dynamic 2D array, meaning only the required pair of coordinates are added
    local gridContent = self.colliders[collisionType]

    local gridX = gridContent[gridPosX]
    if gridX == nil then
        gridContent[gridPosX] = {}
        gridX = gridContent[gridPosX]
    end

    local gridY = gridX[gridPosY]
    if gridY == nil then
        gridX[gridPosY] = {}
        gridY = gridX[gridPosY]
    end

    table.insert(gridY, collider)
end

function CollisionSolver:_getCollidersAtGridPosition(collisionType, gridPosX, gridPosY)
    local gridContent = self.colliders[collisionType]
    
    local gridX = gridContent[gridPosX]
    if gridX == nil then return nil end
    
    local gridY = gridX[gridPosY]
    if gridY == nil then return nil end

    -- this the array that contains colliders
    return gridY
end

function CollisionSolver:_getCornersGridCoordinates(collider)
    -- this function makes a huge assumption: the collider hitbox has the size of the image
    -- this is unaccurate and may lead to issues in the future
    local x,y,w,h = collider:getBounds()

    local tlX, tlY = kGame.worldPosToGrid(x, y);
    local trX, trY = kGame.worldPosToGrid(x+w, y);
    local brX, brY = kGame.worldPosToGrid(x+w, y+h);
    local blX, blY = kGame.worldPosToGrid(x, y+h);

    return tlX, tlY, trX, trY, brX, brY, blX, blY
end

function CollisionSolver:addCollider(colliderSprite)
    local collisionType = colliderSprite:getCollisionType()

    if collisionType == kCollisionType.ignore then return end -- not added

    -- store by position on grid
    if collisionType == kCollisionType.static then
        self:_addColliderToGridPosition(kCollisionType.static, colliderSprite)
    else
        table.insert(self.colliders[collisionType], colliderSprite)
    end

end

-- removes nil colliders from the collider list
function CollisionSolver:cleanUpColliderList()
    for _, colliderList in pairs(self.colliders) do
        local deleteIndices = {}

        for pos, col in pairs(colliderList) do
            if col == nil then
                table.insert(deleteIndices, pos)
            end
        end

        for _, pos in pairs(deleteIndices) do
            table.remove(colliderList, pos)
        end
    end
end

local overlapTruthTable = {
    [kCollisionType.dynamic | kCollisionType.dynamic] = true,
    [kCollisionType.dynamic | kCollisionType.static] = true,
    [kCollisionType.dynamic | kCollisionType.trigger] = true,
    [kCollisionType.static | kCollisionType.trigger] = false,
    [kCollisionType.static | kCollisionType.static] = false,
    [kCollisionType.trigger | kCollisionType.trigger] = true,
}

-- given two collision types, returns true if we should check overlap between both colliders
function CollisionSolver:shouldCheckOverlap(firstCollisionType, secondCollisionType)
    local mask = firstCollisionType | secondCollisionType

    return overlapTruthTable[mask]
end

-- this function is internal to checkCollisions below
-- but declared outside for memory allocation optimization
local _performCollisionCheck = function(colliderA, colliderB)
    if colliderA:overlapsWith(colliderB) then
        colliderA:collisionWith(colliderB)
        colliderB:collisionWith(colliderA)
        return true
    end
    return false
end

-- runs a collision check with every possible pairs of two lists or a single list
function CollisionSolver:checkCollisions(colliders, otherColliders)
    if otherColliders == nil then -- check against self
        for i, collider in pairs(colliders) do
            for j=i+1, #colliders do
                local otherCollider = colliders[j]
                _performCollisionCheck(collider, otherCollider) 
            end
        end
    else -- check against other group
        for _, collider in pairs(colliders) do
            for _, otherCollider in pairs(otherColliders) do
                _performCollisionCheck(collider, otherCollider)
            end
        end
    end
end

-- this function is internal to checkCollisionsOnGrid below
-- but declared outside for memory allocation optimization
local _performCollisionCheckGrid = function(collider, gridColliders)
    if gridColliders == nil then return end

    for _, gridCollider in pairs(gridColliders) do
        if collider:overlapsWith(gridCollider) then
            collider:collisionWith(gridCollider)
            gridCollider:collisionWith(collider)
            return true
        end
    end

    return false
end

-- Runs a collision check against colliders positioned on a grid, much faster than checkCollisions
-- but maintaining a grid on moving objects is expensive
function CollisionSolver:checkCollisionsOnGrid(colliders, collisionTypeForGrid)
    for _, collider in pairs(colliders) do
        local tlX, tlY, trX, trY, brX, brY, blX, blY = self:_getCornersGridCoordinates(collider)

        -- check along the bottom range first 
        for i=blX,brX do
            local gridColliders = self:_getCollidersAtGridPosition(collisionTypeForGrid, i, blY)
            _performCollisionCheckGrid(collider, gridColliders)
            -- we do the check a second time with y offset by one just to have a larger sample
            gridColliders = self:_getCollidersAtGridPosition(collisionTypeForGrid, i, blY+1)
            _performCollisionCheckGrid(collider, gridColliders)
        end
        
        -- do the same thing but along the right range
        for i=trY,brY do
            local gridColliders = self:_getCollidersAtGridPosition(collisionTypeForGrid, trX, i)
            _performCollisionCheckGrid(collider, gridColliders)
            -- we do the check a second time with y offset by one just to have a larger sample
            gridColliders = self:_getCollidersAtGridPosition(collisionTypeForGrid, trX+1, i)
            _performCollisionCheckGrid(collider, gridColliders)
        end

        -- top range
        for i=tlX,trX do
            local gridColliders = self:_getCollidersAtGridPosition(collisionTypeForGrid, i, tlY)
            _performCollisionCheckGrid(collider, gridColliders)
            -- we do the check a second time with y offset by one just to have a larger sample
            gridColliders = self:_getCollidersAtGridPosition(collisionTypeForGrid, i, tlY-1)
            _performCollisionCheckGrid(collider, gridColliders)
        end
        
        -- left range
        for i=tlY,blY do
            local gridColliders = self:_getCollidersAtGridPosition(collisionTypeForGrid, tlX, i)
            _performCollisionCheckGrid(collider, gridColliders)
            -- we do the check a second time with y offset by one just to have a larger sample
            gridColliders = self:_getCollidersAtGridPosition(collisionTypeForGrid, tlX-1, i)
            _performCollisionCheckGrid(collider, gridColliders)
        end
    end
end

function CollisionSolver:update()
    --self:cleanUpColliderList() --commented out because it's expensive to run and hard to define a good algorithm
    -- instead colliders are expected to switch to "kCollisionType.ignore" when they want to be removed from collision

    for i=1, #self.collisionTypesList do
        for j=i, #self.collisionTypesList do --j = i is on purpose, we want to check if two colliders of the same type can collide (e.g dynamic vs dynamic)
            local collisionTypeA = self.collisionTypesList[i]
            local collisionTypeB = self.collisionTypesList[j]

            if not self:shouldCheckOverlap(collisionTypeA, collisionTypeB) then
                goto continue
            end

            if j == i then
                self:checkCollisions(self.colliders[collisionTypeA]) -- same collider type, pass the colliders list directly
            else
                
                -- its not super scalable nor clean to enforce checking static collision type 
                -- but unless we add some flag to tell which collision type should be checked in grid mode and which shouldn't we have to do it that way
                -- 😴
                if collisionTypeB == kCollisionType.static or collisionTypeA == kCollisionType.static then
                    
                    -- i was tired ...
                    local theOneThatIsntStatic = collisionTypeA == kCollisionType.static and collisionTypeB or collisionTypeA
                    self:checkCollisionsOnGrid(self.colliders[theOneThatIsntStatic], kCollisionType.static)
                
                else
                    self:checkCollisions(self.colliders[collisionTypeA], self.colliders[collisionTypeB])
                end
            end

            ::continue::
        end
    end
end