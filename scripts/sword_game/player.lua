local x, y = 64, 64
local cursorAngle = 0
local lastCursorAngle = 0

local cursorUnwrap = 0
local weaponUnwrap = 0
local lastWeaponUnwrap = 0

local weaponTurnSpeed = 0.03
local weaponVelocity = 0
local swingDistance = 0
local weaponSize = 24
local sprite = 32

local spriteColorTable = {
    [32] = 0,
    [33] = 9,
    [34] = 4,
    [35] = 0,
    [36] = 8,
}

local minSwingDistance = 0.15

function isSwing()
    return abs(weaponVelocity) >= weaponTurnSpeed/2 and abs(swingDistance) > minSwingDistance
end

function getHitbox()
    local r = weaponSize / 3
    local weaponAngle = weaponUnwrap % 1
    return {
        x = x + cos(weaponAngle) * (weaponSize - r) * 1.5,
        y = y + sin(weaponAngle) * (weaponSize - r) * 1.5,
        r = r,
    }
end

local function applyInputs()
    local speed = 0.75 * deltaTime
    if ttn(L) then x -= speed end
    if ttn(R) then x += speed end
    if ttn(U) then y -= speed end
    if ttn(D) then y += speed end
    if ttn(X) then weaponSize = (weaponSize + 1) % 100 end
    if ttnp(O) then sprite = max(32, (sprite + 1) % 37) end
end

local function shortest_diff(a, b)
    return ((b - a + 0.5) % 1) - 0.5
end

local function updateWeaponDirectional()

    local diff = cursorUnwrap - weaponUnwrap
    if flr(diff * 50) % 50 == 0 then
        weaponUnwrap = cursorUnwrap
        swingDistance = 0
    end
    if abs(diff) <= weaponTurnSpeed then
        weaponUnwrap = cursorUnwrap
        swingDistance = 0
    else
        local step = mid(-weaponTurnSpeed, diff, weaponTurnSpeed)
        weaponUnwrap += step * deltaTime
        if (abs(weaponVelocity) >= weaponTurnSpeed/2) swingDistance += step * deltaTime
    end

    weaponVelocity = weaponUnwrap - lastWeaponUnwrap
    lastWeaponUnwrap = weaponUnwrap

end



function updatePlayer()
    local cx, cy = getCursorPos()
    applyInputs()

    lastCursorAngle = cursorAngle
    cursorAngle = atan2(cx - x, cy - y) % 1

    local d = shortest_diff(lastCursorAngle, cursorAngle)
    cursorUnwrap += d

    if frame == 0 then
        weaponUnwrap = cursorUnwrap
    end

    updateWeaponDirectional()
end

function drawPlayer()
    local length = weaponSize
    local weaponAngle = weaponUnwrap % 1
    local swing = isSwing()
    --linefill(x, y, x + length * cos(weaponAngle), y + length * sin(weaponAngle), weaponSize/4, 3)
    local r = weaponSize / 3
    local hitbox = getHitbox()
    circfill(hitbox.x, hitbox.y, hitbox.r, (swing and 8 or 3))
    local sd = abs(swingDistance)
    if swing then
        local width = weaponSize/12
        local l = length * 1.25
        da = weaponAngle - mid(0, (sd - minSwingDistance)/(minSwingDistance), 1) * 0.1 * sgn(weaponVelocity)--(weaponVelocity * 5 * 0.02/weaponTurnSpeed)
        linefill(x + l * cos(da), y + l * sin(da), x + l * cos(weaponAngle), y + l * sin(weaponAngle), width, spriteColorTable[sprite])
    end
    local sx, sy = (sprite % 16) * 8, flr(sprite / 16) * 8
    rspr(sx, sy + 8, 8, 8, weaponAngle - 0.25, x + 0.25 * weaponSize * cos(weaponAngle), y + 0.25 * weaponSize * sin(weaponAngle), weaponSize, (24/24) * weaponSize)
    rspr(sx, sy, 8, 8, weaponAngle - 0.25, x + 0.96 * weaponSize * cos(weaponAngle), y + 0.96 * weaponSize * sin(weaponAngle), weaponSize, (24/24) * weaponSize)
    circfill(x, y, 3, 11)
end