do

local x, y = 64, 64
local sizeRadius = 4
local cursorAngle = 0
local lastCursorAngle = 0
local push = {mag=0, dir=0}
local invincible = 0

local cursorUnwrap = 0
local weaponUnwrap = 0
local lastWeaponUnwrap = 0

local weaponTurnSpeed = 0.03
local weaponVelocity = 0
local swingDistance = 0
local weaponSize = 16
local sprite = 32
local maxSprite = 37

local minTurnSpeed = 0.01
local minSwingDistance = 0.15

local clickCD = 0
local maxClickCD = 0


local spriteData = {
    [32] = {
        color = 0,
    },
    [33] = {
        color = 6,
        wts = 0.02,
        mccd = 30,
        hitboxes = {},
        onClick = function()
            Projectile:new({
                x=x, 
                y=y, 
                dir=weaponUnwrap % 1, 
                speed=2, 
                range=64,
                onEnemy = function(_ENV, e)
                    dead = true
                    e.stun = 60
                    e.push = {mag=4, dir=dir}
                end,
            }, projectiles)
        end,
        hitboxes = {
            {
                size = 0.5,
                length = 0.9,
                offset = 0
            },
        },
    },
    [34] = {
        color = 9,
    },
    [35] = {
        color = 4,
        hitboxes = {
            {
                size = 1.1,
                length = 1,
                offset = 0
            },
            {
                size = 1.1,
                length = 0.5,
                offset = 0
            },
        },
        wts = 0.02
    },
    [36] = {
        color = 0,
        mccd = 30,
        onClick = function()
            sprite = 44
            setWeaponStats()
        end,
    },
    [37] = {
        color = 8,
        hitboxes = {
            {
                size = 1,
                length = 1,
                offset = 0
            },
        },
        onClick = function() 
            x = 64
        end,
    },
    [44] = {
        color = 7,
        mccd = 30,
        wts = 0.06,
        onClick = function()
            sprite = 36
            setWeaponStats()
        end,
        hitboxes = {
            {
                size = 0.5,
                length = 1.2,
                offset = 0
            },
        },
    }
}

function playerHit(dir)
    if (invincible > 0) return
    push = {mag=5, dir=dir}
    invincible = 10
end

function isSwing()
    return abs(weaponVelocity) >= minTurnSpeed and abs(swingDistance) > minSwingDistance and push.mag <= 0
end

function getHitbox()
    local hitboxes = spriteData[sprite].hitboxes or {
        {
            size = 1,
            length = 1,
            offset = 0,
        }
    }
    local outputHitboxes = {}
    local weaponAngle = weaponUnwrap % 1
    for hitbox in all(hitboxes) do
        add(outputHitboxes, {
            x = x + cos(weaponAngle + hitbox.offset) * weaponSize * hitbox.length,
            y = y + sin(weaponAngle + hitbox.offset) * weaponSize * hitbox.length,
            r = weaponSize * hitbox.size/2,
        })
    end
    return outputHitboxes, weaponVelocity
end


function getPlayerPos()
    return x, y, sizeRadius
end

function setWeaponStats()
    weaponTurnSpeed = spriteData[sprite].wts or 0.03
    maxClickCD = spriteData[sprite].mccd or 0
end

setWeaponStats()

local function applyInputs()
    local speed = 0.75 * deltaTime
    if ttn(L) then x -= speed end
    if ttn(R) then x += speed end
    if ttn(U) then y -= speed end
    if ttn(D) then y += speed end
    if ttn(X) then 
        if clickCD <= 0 then
            if (spriteData[sprite]["onClick"]) spriteData[sprite]["onClick"]()
            clickCD = maxClickCD
        end
    end
    if ttnp(O) then 
        sprite = max(32, (sprite + 1) % (maxSprite + 1)) 
        setWeaponStats()
    end
end

local function shortest_diff(a, b)
    return ((b - a + 0.5) % 1) - 0.5
end

local function updateWeaponDirectional()
    local diff = cursorUnwrap - weaponUnwrap
    local wts = weaponTurnSpeed * deltaTime
    local step = mid(-wts, diff, wts)
    if flr(diff * 50) % 50 == 0 then
        weaponUnwrap = cursorUnwrap
    end

    if abs(diff) <= weaponTurnSpeed then
        weaponUnwrap = cursorUnwrap
    else
        weaponUnwrap += step
    end


    weaponVelocity = weaponUnwrap - lastWeaponUnwrap
    lastWeaponUnwrap = weaponUnwrap

    if (abs(weaponVelocity) >= minTurnSpeed) then
        swingDistance += step * deltaTime
    else
        swingDistance = 0
    end
end

function updatePlayer()
    local cx, cy = getCursorPos()
    if push.mag > 0 then
        x += push.mag * cos(push.dir)
        y += push.mag * sin(push.dir)
        push.mag -= 0.5
    else
        applyInputs()
    end

    lastCursorAngle = cursorAngle
    cursorAngle = atan2(cx - x, cy - y) % 1

    local d = shortest_diff(lastCursorAngle, cursorAngle)
    cursorUnwrap += d

    if frame == 0 then
        weaponUnwrap = cursorUnwrap
    end

    updateWeaponDirectional()

    clickCD -= 1
    invincible -= 1
end

function drawPlayer()
    local length = weaponSize
    local weaponAngle = weaponUnwrap % 1
    local swing = isSwing()

    local hitboxes = getHitbox()
    for hitbox in all(hitboxes) do 
        circfill(hitbox.x, hitbox.y, hitbox.r, (swing and 8 or 3))
    end

    local sd = abs(swingDistance)
    if swing then
        local width = weaponSize/12
        local l = spriteData[sprite]["hitboxes"] and weaponSize * spriteData[sprite]["hitboxes"][1].length or weaponSize * 1.25
        local da = weaponAngle - mid(0, (sd - minSwingDistance)/(minSwingDistance), 1) * 0.1 * sgn(weaponVelocity)--(weaponVelocity * 5 * 0.02/weaponTurnSpeed)
        linefill(x + l * cos(da), y + l * sin(da), x + l * cos(weaponAngle), y + l * sin(weaponAngle), width, spriteData[sprite].color or 0)
    end
    local sx, sy = (sprite % 16) * 8, flr(sprite / 16) * 8
    rspr(sx, sy + 8, 8, 8, weaponAngle - 0.25, x + 0.25 * weaponSize * cos(weaponAngle), y + 0.25 * weaponSize * sin(weaponAngle), weaponSize, weaponSize)
    rspr(sx, sy, 8, 8, weaponAngle - 0.25, x + 0.96 * weaponSize * cos(weaponAngle), y + 0.96 * weaponSize * sin(weaponAngle), weaponSize, weaponSize)
    circfill(x, y, sizeRadius, 11)

    --[[
    local cx, cy = getCursorPos()
    local cursorDist = dist(x, y, cx, cy)
    local cursorAngle = atan2(cx - x, cy - y)
    for i = 1, ceil(cursorDist) do
        if i % 3 == 0 then
            local dx, dy = x + i * cos(cursorAngle), y + i * sin(cursorAngle)
            pset(dx, dy, 5)
        end
    end
    ]]
end

end