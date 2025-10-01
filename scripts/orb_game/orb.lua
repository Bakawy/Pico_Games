do
    
local x, y = 64, 128
local col = 11
local radius = 3
local targetX, targetY = 64, 64
local followSpeed = 0.8

local path = {}
local currentPathIndex = 1
local pathTimer = 0
local pathStartTime = 0

function updateOrb()
    local px, py = getPlayerPos()
    if #path > 0 then
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

        pathTimer += 1
        return
    end

    targetX, targetY = px, py - 8
    local d = dist(x, y, targetX, targetY)
    if d > 4 then
        local dir = atan2(targetX - x, targetY - y)
        x += followSpeed * (d/10) * cos(dir)
        y += followSpeed * (d/10) * sin(dir)
    end
end

function setOrbPath(newPath)
    path = newPath
    currentPathIndex = 1
    pathTimer = 0
    pathStartTime = 0
end

function drawOrb()
    circfill(x, y, radius, col)
end

end