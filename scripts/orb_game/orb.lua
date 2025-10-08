do
    
local x, y = 64, 128

local col = 11
local dmgCol = 9
local endCol = 13

local radius = 3
local normRadius = 3
local targetX, targetY = 64, 64
local followSpeed = 0.8

local path = {}
local pathRadius = radius
local currentPathIndex = 1
local pathTimer = 0
local pathStartTime = 0

local damaging = false
local knockback = {mag=1, dir=0.15}
local hitStun = 0

function getOrbPos()
    return x, y, radius
end

function getOrbDamage()
    local m = knockback.mag
    local d = knockback.dir

    local facing = getPlayerState().facing
    if not facing then
        d = mirrorY(d)
    end

    return damaging, {mag=m, dir=d}, hitStun
end

function updateOrb()
    local playerState = getPlayerState()
    local px, py = playerState.x, playerState.y
    if #path > 0 then
        damaging = true
        local currentPoint = path[currentPathIndex]
        local nextPoint = path[currentPathIndex + 1]
        if pathTimer > currentPoint.len + pathStartTime then
            pathStartTime = pathTimer
            currentPathIndex += 1
            currentPoint = path[currentPathIndex]
            nextPoint = path[currentPathIndex + 1]
            if currentPathIndex == #path then
                path = {}
                x = currentPoint.x + px
                y = currentPoint.y + py
                return
            end
        end
        local progress = (pathTimer - pathStartTime) / currentPoint.len
        x = ease(currentPoint.x, nextPoint.x, progress, linear) + px
        y = ease(currentPoint.y, nextPoint.y, progress, linear) + py

        radius = pathRadius
        if currentPathIndex == #path - 1 then
            radius = ease(pathRadius, normRadius, progress, linear)
        end

        pathTimer += 1
        return
    end

    damaging = false
    targetX, targetY = px, py - 8
    local d = dist(x, y, targetX, targetY)
    if d > 4 then
        local dir = atan2(targetX - x, targetY - y)
        x += followSpeed * (d/10) * cos(dir)
        y += followSpeed * (d/10) * sin(dir)
    end
end

function setOrbPath(newPath, size)
    path = clone(newPath)
    pathRadius = size or radius
    local facing = getPlayerState().facing
    if not facing then
        for p in all(path) do
            p.x = -p.x
        end
    end

    currentPathIndex = 1
    pathTimer = 0
    pathStartTime = 0
end

function setOrbKB(kb)
    knockback = clone(kb)
end

function setOrbHS(frames)
    hitStun = frames  
end

function drawOrb()
    local drawCol = col
    local playerState = getPlayerState()

    if (playerState.noInput > 0) drawCol = endCol
    if (damaging) drawCol = dmgCol
    circfill(x, y, radius, drawCol)
end

end