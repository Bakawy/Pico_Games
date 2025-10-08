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

local wasSwinging = false
local weaponTurnSpeed = 0.02
local weaponVelocity = 0
local weaponColor = 1
local swingDistance = 0
local sprite = 32--32

--weapon stats
local weaponTurnSpeed = 0
local weaponSize = 16
local knockback = 0
local maxClickCD = 0

local minTurnSpeed = 0.01
local minSwingDistance = 0.15

local clickCD = 0

local debugSpecial = 0

local spriteData = {
    [32] = {
        kb = 5,
        wts = 0.025,
        setSpecial = function(special)
            weaponSize = round(16 + 0.35 * special)
            debugSpecial = weaponSize
        end
    },
    [33] = {
        kb = 5,
        wts = 0.025,
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
        setSpecial = function (special)
            maxClickCD = 30 - 0.25 * special
            debugSpecial = maxClickCD
        end,
        hitboxes = {
            {
                size = 0.5,
                length = 0.9,
                offset = 0
            },
        },
    },
    --[[
    [34] = {
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
        mccd = 30,
        onClick = function()
            sprite = 44
            setWeaponStats()
        end,
    },
    [37] = {
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
    ]]
}

function playerHit(dir, dmg)
    dmg = dmg or 5
    if (invincible > 0) return
    push = {mag=dmg, dir=dir}
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
    return outputHitboxes, weaponVelocity, knockback
end

function getWeapon()
    return sprite, spriteData[sprite]
end

function getPlayerPos()
    return x, y, sizeRadius
end

function setWeaponStats(colors)
    --weaponTurnSpeed = spriteData[sprite].wts or 0.03
    --maxClickCD = spriteData[sprite].mccd or 0
    local red = (colors[4] or 0) + (colors[7] or 0) + (colors[8] or 0) + 3 * (colors[10] or 0) - (colors[11] or 0)
    local yellow = (colors[5] or 0) + (colors[7] or 0) + (colors[9] or 0) + 3 * (colors[11] or 0) - (colors[12] or 0)
    local blue = (colors[6] or 0) + (colors[8] or 0) + (colors[9] or 0) + 3 * (colors[12] or 0) - (colors[10] or 0)
    knockback = spriteData[sprite]["kb"] + 0.05 * red
    weaponTurnSpeed = spriteData[sprite]["wts"] + 0.0005 * yellow
    spriteData[sprite]["setSpecial"](blue)
end

setWeaponStats({})

function setWeaponColor(col)
    weaponColor = col
end

function setPlayerPos(posx, posy)
    x = posx
    y = posy
end

function swapWeapon()
    sprite = 32 + ((sprite + 1) % 2)
    setWeaponStats({})
end

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


    local swinging = abs(weaponVelocity) >= minTurnSpeed and abs(swingDistance) > minSwingDistance and push.mag <= 0

    if swinging and not wasSwinging then
        sfx(0)
    end

    wasSwinging = swinging
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

    if (x != mid(-4, x, 132) or y != mid(-4, y, 132)) then 
        gameState = 3
        sfx(3)
    end

    clickCD -= 1
    invincible -= 1
end

function drawPlayer()
    local length = weaponSize
    local weaponAngle = weaponUnwrap % 1
    local swing = isSwing()

    if showHitbox then
        local hitboxes = getHitbox()
        for hitbox in all(hitboxes) do 
            circfill(hitbox.x, hitbox.y, hitbox.r, (swing and 4 or 9))
        end
    end

    local sd = abs(swingDistance)
    if swing then
        local width = weaponSize/12
        local l = spriteData[sprite]["hitboxes"] and weaponSize * spriteData[sprite]["hitboxes"][1].length or weaponSize * 1.25
        local da = weaponAngle - mid(0, (sd - minSwingDistance)/(minSwingDistance), 1) * 0.1 * sgn(weaponVelocity)--(weaponVelocity * 5 * 0.02/weaponTurnSpeed)
        linefill(x + l * cos(da), y + l * sin(da), x + l * cos(weaponAngle), y + l * sin(weaponAngle), width, weaponColor)
    end
    local sx, sy = (sprite % 16) * 8, flr(sprite / 16) * 8
    rspr(sx, sy + 8, 8, 8, weaponAngle - 0.25, x + 0.25 * weaponSize * cos(weaponAngle), y + 0.25 * weaponSize * sin(weaponAngle), weaponSize, weaponSize)
    rspr(sx, sy, 8, 8, weaponAngle - 0.25, x + 0.96 * weaponSize * cos(weaponAngle), y + 0.96 * weaponSize * sin(weaponAngle), weaponSize, weaponSize)
    circfill(x, y, sizeRadius, 0)


    local text = "\#1\f4"..knockback.." \f5"..weaponTurnSpeed.." \f6"..debugSpecial
    local len = print(text, 0, -10)
    print(text, 64 - len/2, 120, 1)
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