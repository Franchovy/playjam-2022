-- this convoluted trickery allows us to store collider data in an array
-- that way it's much faster to retrieve data than standard key interrogation

-- the following indice tables allow for a somewhat clear api of what type of data we are retrieving
-- tho this is only for non speed-critical parts, it's better to retrieve directly with an index for 
-- functions that need to be fast

local circleIndiceTable = {
    x = 1,
    y = 2,
    radius = 3,
    sqRadius = 4,
    relativeX = 5,
    relativeY = 6
}

local rectIndiceTable = {
    x = 1,
    y = 2,
    width = 3,
    height = 4,
    relativeX = 5,
    relativeY = 6
}

local typeToIndiceTable = {
    [kColliderType.circle] = circleIndiceTable,
    [kColliderType.rect] = rectIndiceTable,
}

function getIndiceTable(colliderType)
    return typeToIndiceTable[colliderType]
end

function circleNew(x, y, radius)
    return {
        x,
        y,
        radius,
        radius*radius,
        x,
        y
    }
end

function rectNew(x,y,w,h)
    return {
        x,
        y,
        w,
        h,
        x,
        y
    }
end

function rectMin(r)
    return r[1], r[2]
end

function rectMax(r)
    return r[1] + r[3], r[2] + r[4]
end