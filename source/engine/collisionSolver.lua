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

function CollisionSolver:free()
    instance = nil
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
    local addColliderToGrid = function(gridPosX, gridPosY)
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

        if not self:_findColliderInTable(gridY, collider) then -- no dupes
            table.insert(gridY, collider)
        end
    end

    local eligibleToMultigrid = collisionType == kCollisionType.static and collider:getCollider().type == kColliderType.rect

    -- add directly to grid, don't support multiple grid positions for now
    if not eligibleToMultigrid then
        local gridPosX, gridPosY = kGame.worldPosToGrid(collider.x, collider.y)
        addColliderToGrid(gridPosX, gridPosY)
    -- a rect may exist in multiple grid cells at once
    else
        local tlX, tlY, trX, trY, brX, brY, blX, blY = self:_getCornersGridCoordinates(collider)
        -- top edge
        for gridPosX=tlX, trX do
            addColliderToGrid(gridPosX, tlY)
        end
        -- right edge
        for gridPosY=trY, brY do
            addColliderToGrid(trX, gridPosY)
        end
        --bottom edge
        for gridPosX=blX, brX do
            addColliderToGrid(gridPosX, blY)
        end
        --left edge
        for gridPosY=tlY, blY do
            addColliderToGrid(tlX, gridPosY)
        end
    end
end

function CollisionSolver:_findColliderInTable(table, collider)
    for i, value in pairs(table) do
        if value == collider then
            return i
        end
    end

    return nil
end

function CollisionSolver:_removeColliderAtGridPosition(collisionType, collider)
    local gridPosX, gridPosY = kGame.worldPosToGrid(collider.x, collider.y)

    local gridContent = self.colliders[collisionType]

    local gridX = gridContent[gridPosX]
    if gridX == nil then return end
    
    local gridY = gridX[gridPosY]
    if gridY == nil then return end

    if #gridY == 1 then -- only one element, delete the whole table
        gridX[gridPosY] = nil
    else
        -- search and destroy
        local index = self:_findColliderInTable(gridY, collider)

        if index then
            table.remove(gridY, index)
        end
    end
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
    local colliderInfo = collider:getCollider()

    local x,y,w,h = 0,0,0,0
    if colliderInfo.type == kColliderType.rect then
        x,y,w,h = colliderInfo.collider[1], colliderInfo.collider[2], colliderInfo.collider[3], colliderInfo.collider[4]
    else
        x,y,w,h = collider:getBounds()
    end

    local tlX, tlY = kGame.worldPosToGrid(x, y);
    local trX, trY = kGame.worldPosToGrid(x+w, y);
    local brX, brY = kGame.worldPosToGrid(x+w, y+h);
    local blX, blY = kGame.worldPosToGrid(x, y+h);

    return tlX, tlY, trX, trY, brX, brY, blX, blY
end

function CollisionSolver:isStatic(collisionType)
    return collisionType == kCollisionType.static or collisionType == kCollisionType.triggerStatic
end

function CollisionSolver:addCollider(colliderSprite)
    local collisionType = colliderSprite:getCollisionType()

    if collisionType == kCollisionType.ignore then return end -- not added

    if collisionType == kCollisionType.static then
        assert(colliderSprite:getCollider().type == kColliderType.rect, "Static colliders only support rect collider type for now")
    end

    assert(collisionType ~= nil, "Tried to add a collider with invalid (nil) collision type")

    -- store by position on grid
    if self:isStatic(collisionType) then
        self:_addColliderToGridPosition(collisionType, colliderSprite)
    else
        table.insert(self.colliders[collisionType], colliderSprite)
    end

end

function CollisionSolver:changeCollisionType(colliderSprite, newType, oldType)

    if oldType == kCollisionType.ignore then
        -- add directly
        self:addCollider(colliderSprite)
        return
    end

    if self:isStatic(oldType) then
        self:_removeColliderAtGridPosition(oldType, colliderSprite)
    else
        -- search and destroy
        local index = self:_findColliderInTable(self.colliders[oldType], colliderSprite)

        if index then
            table.remove(self.colliders[oldType], index)
        end
    end

    self:addCollider(colliderSprite)
end

local overlapTruthTable = {
    [kCollisionType.dynamic | kCollisionType.dynamic] = true,
    [kCollisionType.dynamic | kCollisionType.static] = true,
    [kCollisionType.dynamic | kCollisionType.triggerStatic] = true,
    [kCollisionType.dynamic | kCollisionType.triggerDynamic] = true,
    [kCollisionType.static | kCollisionType.triggerStatic] = false,
    [kCollisionType.static | kCollisionType.triggerDynamic] = false,
    [kCollisionType.static | kCollisionType.static] = false,
    [kCollisionType.triggerStatic | kCollisionType.triggerDynamic] = true,
    [kCollisionType.triggerStatic | kCollisionType.triggerStatic] = false,
}

-- only relevant keys are the ones that are true above
local resolutionTruthTable = {
    [kCollisionType.dynamic | kCollisionType.dynamic] = true,
    [kCollisionType.dynamic | kCollisionType.static] = true,
    [kCollisionType.dynamic | kCollisionType.triggerDynamic] = false,
    [kCollisionType.dynamic | kCollisionType.triggerStatic] = false,
}

-- given two collision types, returns true if we should check overlap between both colliders
function CollisionSolver:shouldCheckOverlap(firstCollisionType, secondCollisionType)
    local mask = firstCollisionType | secondCollisionType

    return overlapTruthTable[mask]
end

function CollisionSolver:shouldResolveCollisions(firstCollisionType, secondCollisionType)
    local mask = firstCollisionType | secondCollisionType
    local shouldResolve = resolutionTruthTable[mask]

    -- defaults to true if nok ey
    if shouldResolve == nil then return true end

    return shouldResolve
end

-- given a calculated resolution movement amount, determines how collider A and collider B should move and by what amount
function CollisionSolver:_determineResolutionMvt(collisionTypeA, collisionTypeB, resolutionAmtX, resolutionAmtY)
    -- both colliders are dynamic, split the resolution amount between the two
    if collisionTypeA == kCollisionType.dynamic and collisionTypeB == kCollisionType.dynamic then
        local halfResolutionX = resolutionAmtX / 2
        local halfResolutionY = resolutionAmtY / 2
        return -halfResolutionX, -halfResolutionY, halfResolutionX, halfResolutionY
    end

    -- resolution amount is calculated for collider B so we need to invert it if A is the one supposed to move
    if collisionTypeA == kCollisionType.dynamic then
        return -resolutionAmtX, -resolutionAmtY, 0, 0
    end

    -- preserve resolution amt as is
    if collisionTypeB == kCollisionType.dynamic then
        return 0, 0, resolutionAmtX, resolutionAmtY
    end

    -- no dynamic colliders
    return 0, 0, 0, 0
 end

function CollisionSolver:_checkAndResolve(colliderA, colliderB)
    local overlaps, overlapInfo, resolutionFunction = colliderA:overlapsWith(colliderB)
    
    if overlaps then

        local collisionTypeA = colliderA:getCollisionType()
        local collisionTypeB = colliderB:getCollisionType()

        if self:shouldResolveCollisions(collisionTypeA, collisionTypeB) then
            local resolutionX, resolutionY = resolutionFunction(overlapInfo)

            -- calculate the actual resolution amount depending on collision types
            local resolutionAX, resolutionAY, resolutionBX, resolutionBY = self:_determineResolutionMvt(
                collisionTypeA,
                collisionTypeB,
                resolutionX, resolutionY
            )

            if collisionTypeA == kCollisionType.dynamic then
                colliderA:moveTo(colliderA.x + resolutionAX, colliderA.y + resolutionAY)
            end
            if collisionTypeB == kCollisionType.dynamic then
                colliderB:moveTo(colliderB.x + resolutionBX, colliderB.y + resolutionBY)
            end
    
            colliderA:collisionWith(colliderB, resolutionAX, resolutionAY)
            colliderB:collisionWith(colliderA, resolutionBX, resolutionBY)
        end

        colliderA:collisionWith(colliderB, 0, 0)
        colliderB:collisionWith(colliderA, 0, 0)
    end
end

-- runs a collision check with every possible pairs of two lists or a single list
function CollisionSolver:checkCollisions(colliders, otherColliders)
    if otherColliders == nil then -- check against self
        for i, collider in pairs(colliders) do
            for j=i+1, #colliders do
                local otherCollider = colliders[j]
                self:_checkAndResolve(collider, otherCollider) 
            end
        end
    else -- check against other group
        for _, collider in pairs(colliders) do
            for _, otherCollider in pairs(otherColliders) do
                self:_checkAndResolve(collider, otherCollider)
            end
        end
    end
end

function CollisionSolver:_checkAndResolveGrid(collider, gridColliders, testedColliders)
    if gridColliders == nil then return end

    for _, gridCollider in pairs(gridColliders) do
        -- flag as tested or pass
        if testedColliders[gridCollider] then goto continue
        else testedColliders[gridCollider] = true end

        local overlaps, overlapInfo, resolutionFunction = gridCollider:overlapsWith(collider)

        if overlaps then
            local gridCollisionType = gridCollider:getCollisionType()
            local colliderCollisionType = collider:getCollisionType()

            if self:shouldResolveCollisions(gridCollisionType, colliderCollisionType) then
                local resolutionX, resolutionY = resolutionFunction(overlapInfo)
                

                -- calculate the actual resolution amount depending on collision types
                local resolutionAX, resolutionAY, resolutionBX, resolutionBY = self:_determineResolutionMvt(
                    gridCollisionType,
                    colliderCollisionType,
                    resolutionX, resolutionY
                )

                if gridCollisionType == kCollisionType.dynamic then
                    gridCollider:moveTo(gridCollider.x + resolutionAX, gridCollider.y + resolutionAY)
                end

                if colliderCollisionType == kCollisionType.dynamic then
                    collider:moveTo(collider.x + resolutionBX, collider.y + resolutionBY)
                end

                gridCollider:collisionWith(collider, resolutionAX, resolutionAY)
                collider:collisionWith(gridCollider, resolutionBX, resolutionBY)
            end
            
            gridCollider:collisionWith(collider,0,0)
            collider:collisionWith(gridCollider,0,0)
        end

        ::continue::
    end
end

-- Runs a collision check against colliders positioned on a grid, much faster than checkCollisions
-- but maintaining a grid on moving objects is expensive
function CollisionSolver:checkCollisionsOnGrid(colliders, collisionTypeForGrid)
    for _, collider in pairs(colliders) do
        local tlX, tlY, trX, trY, brX, brY, blX, blY = self:_getCornersGridCoordinates(collider)

        local gridColliders = {}
        local testedColliders = {}
        -- check along the bottom range first 
        for i=blX,brX do
            gridColliders = self:_getCollidersAtGridPosition(collisionTypeForGrid, i, blY)
            self:_checkAndResolveGrid(collider, gridColliders, testedColliders)
        end
        
        -- do the same thing but along the right range
        for i=trY,brY do
            gridColliders = self:_getCollidersAtGridPosition(collisionTypeForGrid, trX, i)
            self:_checkAndResolveGrid(collider, gridColliders, testedColliders)
        end

        -- top range
        for i=tlX,trX do
            gridColliders = self:_getCollidersAtGridPosition(collisionTypeForGrid, i, tlY)
            self:_checkAndResolveGrid(collider, gridColliders, testedColliders)
        end
        
        -- left range
        for i=tlY,blY do
            gridColliders = self:_getCollidersAtGridPosition(collisionTypeForGrid, tlX, i)
            self:_checkAndResolveGrid(collider, gridColliders, testedColliders)
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
                
                if self:isStatic(collisionTypeB) or self:isStatic(collisionTypeA) then
                    
                    -- i was tired ...
                    local theOneThatIsntStatic = self:isStatic(collisionTypeA) and collisionTypeB or collisionTypeA
                    local theOneThatIsStatic = theOneThatIsntStatic == collisionTypeA and collisionTypeB or collisionTypeA
                    self:checkCollisionsOnGrid(self.colliders[theOneThatIsntStatic], theOneThatIsStatic)
                
                else
                    self:checkCollisions(self.colliders[collisionTypeA], self.colliders[collisionTypeB])
                end
            end

            ::continue::
        end
    end
end