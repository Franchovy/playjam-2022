import "playdate"
import "constant/kColliderType"
import "constant/kCollisionType"
import "collisionSolver"
import "engine/colliders"

local gfx <const> = playdate.graphics

-- Base class for a gfx.sprite that overrides default sdk collision handling
class("ColliderSprite").extends(gfx.sprite)

function ColliderSprite:init()
    ColliderSprite.super.init(self)

    self._collider = nil
    self._colliderType = kColliderType.none
    self._collisionType = kCollisionType.ignore -- Defaults to ignore to preserve computation
end

-- colliderType is expected to be a kColliderType constant and collider the corresponding playdate.geometry object
function ColliderSprite:setCollider(colliderType, collider)
    assert(colliderType ~= kColliderType.none, "Passed colliderType can't be none") -- should we allow no collider ?

    self._collider = collider
    self._colliderType = colliderType
end

-- Returns a table where key "type" is a kColliderType value and "collider" is a corresponding playdate.geometry object
function ColliderSprite:getCollider()
    return {type = self._colliderType, collider = self._collider}
end

-- collisionType is expected to be a kCollisionType constant — !! kCollisionType and kColliderType are not the same
function ColliderSprite:setCollisionType(collisionType)

    local oldType = self._collisionType
    -- TODO: add failsafe if collision type is invalid
    self._collisionType = collisionType

    -- warn the solver that type has changed
    local solverInstance = CollisionSolver.instance()
    if solverInstance and self._addedToSolver then
        solverInstance:changeCollisionType(self, self._collisionType, oldType)
    end
end

function ColliderSprite:readyToCollide()
    local solverInstance = CollisionSolver.instance()
    if solverInstance then
        self._addedToSolver = true
        solverInstance:addCollider(self)
    end
end

function ColliderSprite:getCollisionType()
    return self._collisionType
end

function ColliderSprite:moveTo(x, y)
    if (self._collider) then
        local indiceTable = getIndiceTable(self._colliderType)
        self._collider[indiceTable.x] = x + self._collider[indiceTable.relativeX]
        self._collider[indiceTable.y] = y + self._collider[indiceTable.relativeY]
    end

    gfx.sprite.moveTo(self, x, y)
end

-- Returns true if a rect and a circle intersect
ColliderSprite.aabbToCircle = function(rect, circle)
    local minX, minY = rectMin(rect)
    local maxX, maxY = rectMax(rect)

    local circleX, circleY = circle[1], circle[2]

    -- Here we clamp the circle position to be in bound of the rectangle tested against
    local closestPointX = math.clamp(circleX, minX, maxX)
    local closestPointY = math.clamp(circleY, minY, maxY)

    local sqDistance = playdate.geometry.squaredDistanceToPoint(closestPointX, closestPointY, circleX, circleY)
    local overlap = sqDistance <= circle[4] -- is there an actual overlap

    local overlapInformation = overlap and {
        circle = circleNew(circleX, circleY, circle[3]),
        closestPoint = {x = closestPointX, y = closestPointY},
        sqDistance = sqDistance
    } or nil

    return overlap, overlapInformation, ColliderSprite.aabbToCircleResolution
end

-- returns by how much the circle should move to resolve the collision
ColliderSprite.aabbToCircleResolution = function(overlapInfo)
    if overlapInfo.sqDistance < 0.1 then return 0, 0 end

    local distance = math.sqrt(overlapInfo.sqDistance)
    local overlap = overlapInfo.circle[3] - distance

    local moveDirX = (overlapInfo.circle[1] - overlapInfo.closestPoint.x) / distance
    local moveDirY = (overlapInfo.circle[2] - overlapInfo.closestPoint.y) / distance

    return moveDirX * overlap, moveDirY * overlap
end

-- Convenience function for ColliderSprite:overlapsWith
ColliderSprite.circleToAabb = function(circle, rect)
    return ColliderSprite.aabbToCircle(rect, circle)
end

-- Returns true if a circle and a circle intersect
ColliderSprite.circleToCircle = function(a, b)
    local radiiSum = a[3] + b[3]
    local overlap = playdate.geometry.squaredDistanceToPoint(a.x, a.y, b.x, b.y) <= radiiSum * radiiSum
    
    local overlapInfo = {}
    if overlap then
        overlapInfo = {a = circleNew(a[1], a[2], a[3]), b = circleNew(b[1], b[2], b[3])}
    end

    return overlap, overlapInfo, ColliderSprite.circleToCircleResolution
end

-- Returns the smallest amount by how much b should move to resolve the collision, asssumes both circle are overlapping
ColliderSprite.circleToCircleResolution = function(overlapInfo)
    local a = overlapInfo.a
    local b = overlapInfo.b

    local radiiSum = a[3] + b[3]
    local bToA_x = b[1] - a[1]    -- naming convention broken for readability
    local bToA_y = b[2] - a[2] 

    local bToALength = math.sqrt(bToA_x * bToA_x + bToA_y * bToA_y)

    local moveDirX = bToA_x / bToALength
    local moveDirY = bToA_y / bToALength

    return a[1] + moveDirX * radiiSum, a[2] + moveDirY * radiiSum
end

-- Returns true if a rect and a rect intersect
ColliderSprite.aabbToAabb = function(a, b)
    local x,y,w,h = playdate.geometry.rect.fast_intersection(
        a[1], a[2], a[3], a[4],
        b[1], b[2], b[3], b[4])

    local overlap = x == 0 and y == 0 and w == 0 and h == 0

    local overlapInfo = nil

    if overlap then
        local aMinX, aMinY = rectMin(a)
        local bMinX, bMinY = rectMin(b)
        local aMaxX, aMaxY = rectMax(a)
        local bMaxX, bMaxY = rectMax(b)

        overlapInfo = {
            aMin = {x = aMinX, y = aMinY},
            bMin = {x = bMinX, y = bMinY},
            aMax = {x = aMaxX, y = aMaxY},
            bMax = {x = bMaxX, y = bMaxY}
        }
    end

    return overlap, overlapInfo, ColliderSprite.calculateAabbToAabbResolution
end

-- Returns the smallest amount by how much b should move to resolve the collision, assumes both rectangles are overlapping
ColliderSprite.calculateAabbToAabbResolution = function(overlapInfo)
    local aMin, aMax = overlapInfo.aMin, overlapInfo.aMax
    local bMin, bMax = overlapInfo.bMin, overlapInfo.bMax

    local moveLeft = aMin.x - bMax.x
    local moveRight = aMax.x - bMin.x
    local xMove = math.abs(moveLeft) < math.abs(moveRight) and moveLeft or moveRight

    local moveUp = aMin.y - bMax.y
    local moveDown = aMax.y - bMin.y
    local yMove = math.abs(moveUp) < math.abs(moveDown) and moveUp or moveDown

    if math.abs(xMove) < math.abs(yMove) then
        return xMove, 0
    else
        return 0, yMove
    end
end

-- Returns true if two ColliderSprites overlap regardless of collision masks, collision enabled or collision types
function ColliderSprite:overlapsWith(other)
    -- Maps each pair of collider type to a collision checking function 
    -- The keys are set up that way so we know which collider types are the first and second parameters of the function
    local collisionFunctions = {
        [kColliderType.rect * 10 + kColliderType.rect]      = ColliderSprite.aabbToAabb,
        [kColliderType.rect * 10 + kColliderType.circle]    = ColliderSprite.aabbToCircle,
        [kColliderType.circle * 10 + kColliderType.circle]  = ColliderSprite.circleToCircle,
        [kColliderType.circle * 10 + kColliderType.rect]    = ColliderSprite.circleToAabb
    }

    return collisionFunctions[self._colliderType * 10 + other._colliderType](self._collider, other._collider)
end

function ColliderSprite:collisionWith(other, resolutionX, resolutionY)
    -- Function called by the collisionsolver when a collision is detected. Children should implement
end