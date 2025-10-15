do
x, y = 0, 0
shieldDist = 16
maxVel = 3
xVel, yVel = 0
frict = 0.25
sizeRadius = 4
shieldRadius = 6
maxHP = 3
hp = maxHP

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

    x = mid(-bounds, x, bounds)
    y = mid(-bounds, y, bounds)
end

function getPlayerPos()
    return x, y, sizeRadius
end

function getShieldPos()
    local cx, cy = getCursorPos()
    local angle = atan2(cx - x, cy - y)
    return x + shieldDist * cos(angle), y + shieldDist * sin(angle), shieldRadius
end

function updatePlayer()
    applyInputs()
end

function hurtPlayer()
    hp -= 1
    if (hp <= 0) stop()
end

function drawPlayer()
    circfill(x, y, sizeRadius, 5)

    local sx, sy = getShieldPos()
    circfill(sx, sy, shieldRadius, 6)
end

function drawHUD()
    local x = 119
    local cx, cy = getCamera()
    for i=1,maxHP do
        local midCol = 8
        if (hp < i) midCol = 5
        sprPal(2, cx + x - 64, cy - 63, {[1]=0,[8]=midCol})
        x -= 9
    end
end

end