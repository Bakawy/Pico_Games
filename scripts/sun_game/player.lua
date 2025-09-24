do

local x, y = 64, 64 
local xVel, yVel = 0, 0
local maxVel = 3
local frict = 0.15
local shieldDist = 20
local shieldRadius = 6
local sizeRadius = 4

local function applyInputs()
    local accel = 0.5
    if ttn(L) then xVel -= accel end
    if ttn(R) then xVel += accel end
    if ttn(U) then yVel -= accel end
    if ttn(D) then yVel += accel end

    xVel = mid(-maxVel, xVel, maxVel)
    yVel = mid(-maxVel, yVel, maxVel)
    x += xVel
    y += yVel
    xVel = abs(xVel) < frict and 0 or xVel - sgn(xVel)*frict
    yVel = abs(yVel) < frict and 0 or yVel - sgn(yVel)*frict

    x = mid(0, x, 128)
    y = mid(0, y, 128)
end

function getPlayerPos()
    return x, y, sizeRadius
end

function updatePlayer()
    applyInputs()
    print(xVel.." "..yVel, 64, 64, 0)
end

function drawPlayer()
    circfill(x, y, sizeRadius, 5)

    local cx, cy = getCursorPos()
    local angle = atan2(cx - x, cy - y)
    circfill(x + shieldDist * cos(angle), y + shieldDist * sin(angle), shieldRadius, 6)
end

end