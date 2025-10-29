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
local sprite = 37
local stateTimer = 0

--weapon stats
local weaponTurnSpeed = 0
local weaponSize = 16
local knockback = 0
local maxClickCD = 0
local ammo = -1

local minTurnSpeed = 0.01
local minSwingDistance = 0.15

local clickCD = 0
local forceSwing = 0

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
        wts = 0.02,
        mccd = 30,
        streakLen = 0.9,
        ammo = 5,
        onClick = function()
            if ammo > 0 then
                fireRoutine = cocreate(function()
                    for i=1,flr(debugSpecial) do  -- fire 3 times
                        sfx(1)
                        Projectile:new({
                            x=x, 
                            y=y, 
                            dir=weaponUnwrap % 1, 
                            speed=2, 
                            range=96,
                            size=3,
                            onEnemy = function(_ENV, e)
                                dead = true
                                e.hit = dir
                                e.kb += 0.2
                            end,
                        }, projectiles)
                        wait(ceil(maxClickCD/(debugSpecial)))
                    end
                end)
                ammo -= 1
            end
        end,
        setSpecial = function (special)
            special /= 3
            maxClickCD = 30 + special
            debugSpecial = flr(1 + special)
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
        kb = 5,
        wts = 0.025,
        streakLen = 1.25,
        hitboxes = {
            {
                size = 1.2,
                length = 0.75,
                offset = 0
            },
        },
        onTimer = function()
            sprite = 35
            setWeaponStats(countColors(sprite))
            weaponColor = 3
            stateTimer = debugSpecial * 60
        end,
        setSpecial = function(special)
            --weaponSize = round(16 + 0.35 * special)
            debugSpecial = max(3 + special/5, 0.25)
            stateTimer = debugSpecial * 60
        end
    },
    [35] = {
        kb = 5,
        wts = 0.025,
        streakLen = 1.25,
        hitboxes = {
            {
                size = 1.2,
                length = 0.75,
                offset = 0
            },
        },
        onTimer = function()
            sprite = 34
            setWeaponStats(countColors(sprite))
            weaponColor = 1
            stateTimer = debugSpecial * 60
        end,
        setSpecial = function(special)
            debugSpecial = max(3 + special/5, 0.25)
            stateTimer = debugSpecial * 60
        end
    },
    [36] = {
        kb = 5,
        wts = 0.025,
        mccd = 180,
        onClick = function()
            push = {mag=7.5, dir=weaponUnwrap%1}
            forceSwing = 30
            sfx(5)
        end,
        setSpecial = function (special)
            maxClickCD = 180 - 165 * (special/84)
            debugSpecial = maxClickCD/60
        end,
    },
    [37] = {
        kb = 1.5,
        wts = 0.025,
        setSpecial = function(special)
            debugSpecial = 1 + 5 * (special/108)
        end,
        onHit = function() 
            local hitbox = getHitbox()[1]
            Projectile:new({
                x = hitbox.x,
                y = hitbox.y,
                col = 0,
                aim = 0,
                size = 3,
                fireTimer = 60,
                fireRate = debugSpecial,
                move = function (_ENV)
                    aim += 0.01
                    aim %= 1

                    if fireTimer < 0 then
                        sfx(1)
                        Projectile:new({
                            x=_ENV.x, 
                            y=_ENV.y, 
                            dir=aim, 
                            speed=2, 
                            range=64,
                            onEnemy = function(_ENV, e)
                                dead = true
                                --e.stun = 60
                                e.toh = false
                                e.hit = dir
                                e.kb += 0.2
                            end,
                        }, projectiles)
                        fireTimer = 60 / fireRate
                    end

                    fireTimer -= 1
                end,
                draw = function (_ENV)
                    local x, y = _ENV.x, _ENV.y
                    circfill(x, y, size, col)
                    linefill(x + size * 2 * cos(aim), y + size * 2 * sin(aim), x, y, size, col)
                end,
            }, projectiles)
        end,
    },
    [38] = {
        kb = 3,
        wts = 0.02,
        streakLen = 0.9,
        mccd = 40,
        ammo = 5,
        setSpecial = function(special)
            local a = 1 - special/126
            local b = 1 - a * a
            debugSpecial = 8 + 24 * b
        end,
        onClick = function()
            if ammo > 0 then
                sfx(1)
                Projectile:new({
                    x=x, 
                    y=y, 
                    dir=weaponUnwrap % 1, 
                    speed=2, 
                    range=48,
                    size = debugSpecial/2,
                    onEnemy = function(_ENV, e)
                        dead = true
                    end,
                    onDead = function(_ENV) 
                        Projectile:new({
                            x=_ENV.x, 
                            y=_ENV.y, 
                            len=300,
                            size=debugSpecial,
                            onEnemy = function(_ENV, e)
                                local dir = atan2(e.x - _ENV.x, e.y - _ENV.y)
                                e.hit = dir
                                e.kb += 0.2
                            end,
                        }, projectiles)
                    end,
                }, projectiles)
                ammo -= 1
            end
        end,
        hitboxes = {
            {
                size = 0.5,
                length = 0.9,
                offset = 0
            },
        },
    },
    [39] = {
        kb = 4,
        wts = 0.025,
        streakLen = 0.6,
        mccd = 30,
        ammo = 5,
        size = 24,
        hitboxes = {
            {
                size = 0.7,
                length = 0.4,
                offset = 0
            },
        },
        setSpecial = function(special)
            debugSpecial = 1 + flr(14 * sqrt(special / 72))
        end,
        onClick = function()
            if ammo > 0 then
                sfx(1)
                Projectile:new({
                    x=x, 
                    y=y, 
                    dir=weaponUnwrap % 1, 
                    speed = 2, 
                    sprite = 55,
                    size = weaponSize * cos(0.125)/2,
                    bounces = debugSpecial,
                    noHit = 0,
                    move = function(_ENV)
                        _ENV.x += speed * cos(dir)
                        _ENV.y += speed * sin(dir)
                        
                        if (_ENV.x + size > 128 or _ENV.x - size < 0) then
                            dir = mirrorX(dir)
                            bounces -= 1
                        end
                        if (_ENV.y + size > 128 or _ENV.y - size < 0) then 
                            dir = mirrorY(dir) 
                            bounces -= 1
                        end
                        if (bounces < 0) dead = true
                        noHit -= 1
                    end,
                    onEnemy = function(_ENV, e)
                        if (noHit > 0 or e.spawn < 60) return
                        e.hit = dir
                        e.kb += 0.2
                        dir -= 0.5
                        bounces -= 1
                        noHit = 10
                        if (bounces < 0) dead = true
                    end,
                }, projectiles)
                ammo -= 1
            end
        end,
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
    dmg = dmg or 4.5
    if (invincible > 0) return
    push = {mag=dmg, dir=dir}
    invincible = 10
end

function isSwing()
    return (abs(weaponVelocity) >= min(minTurnSpeed, weaponTurnSpeed) and abs(swingDistance) > minSwingDistance and push.mag <= 0) or forceSwing > 0
end

function getHitbox()
    local kbMult = 1
    --if (sprite == 36 and forceSwing > 0) kbMult = 1.25

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
    return outputHitboxes, weaponVelocity, knockback * kbMult, (forceSwing > 0 and sprite == 36)
end

function getWeapon()
    return sprite, spriteData[sprite]
end

function getPlayerPos()
    return x, y, sizeRadius
end

function setWeaponStats(colors)
    --weaponTurnSpeed = spriteData[sprite].wts or 0.03
    maxClickCD = spriteData[sprite].mccd or 0
    ammo = spriteData[sprite].ammo or -1
    weaponSize = spriteData[sprite].size or 16
    local red = (colors[4] or 0) + (colors[7] or 0) + (colors[8] or 0) + 3 * (colors[10] or 0) - (colors[11] or 0)
    local yellow = (colors[5] or 0) + (colors[7] or 0) + (colors[9] or 0) + 3 * (colors[11] or 0) - (colors[12] or 0)
    local blue = (colors[6] or 0) + (colors[8] or 0) + (colors[9] or 0) + 3 * (colors[12] or 0) - (colors[10] or 0)
    knockback = spriteData[sprite]["kb"] + 0.05 * red
    weaponTurnSpeed = max(spriteData[sprite]["wts"] + 0.0005 * yellow, 0.001)
    spriteData[sprite]["setSpecial"](blue)
end

setWeaponStats({})

function setWeaponColor(col)
    weaponColor = col
end

function setPlayerPos(posx, posy)
    x = posx
    y = posy
    clickCD = maxClickCD
end

function setWeapon(s)
    sprite = s
    setWeaponStats(getWeaponColors(sprite))
end

function addAmmo(amount)
    ammount = ammount or 1
    if (ammo >= 0) ammo += ammount
end

function triggerOnHit()
    if (spriteData[sprite]["onHit"]) spriteData[sprite]["onHit"]()
end

local function applyInputs()
    local speed = 0.775 * deltaTime
    local dir = {0, 0}
    if ttn(L) then dir[1] -= 1 end
    if ttn(R) then dir[1] += 1 end
    if ttn(U) then dir[2] -= 1 end
    if ttn(D) then dir[2] += 1 end
    if dir[1] != 0 or dir[2] != 0 then
        dir = atan2(dir[1], dir[2])
        x += speed * cos(dir)
        y += speed * sin(dir)
    end

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

    if (abs(weaponVelocity) >= min(minTurnSpeed, weaponTurnSpeed)) then
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
        if fireRoutine and costatus(fireRoutine) ~= "dead" then
            coresume(fireRoutine)
        end
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

    if push.mag > 0 then 
        if (x != mid(-4, x, 132) or y != mid(-4, y, 132))  then
            gameState = 3
            sfx(3)
        end
    else
        x = mid(4, x, 123)
        y = mid(4, y, 123)
    end

    if (stateTimer <= 0 and spriteData[sprite]["onTimer"]) spriteData[sprite]["onTimer"]()

    clickCD -= 1
    invincible -= 1
    stateTimer -= 1
    forceSwing -= 1
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
        local l = spriteData[sprite]["streakLen"] and weaponSize * spriteData[sprite]["streakLen"] or weaponSize * 1.25
        local da = weaponAngle - mid(0, (sd - minSwingDistance)/(minSwingDistance), 1) * 0.1 * sgn(weaponVelocity)--(weaponVelocity * 5 * 0.02/weaponTurnSpeed)
        linefill(x + l * cos(da), y + l * sin(da), x + l * cos(weaponAngle), y + l * sin(weaponAngle), width, weaponColor)
    end
    local sx, sy = (sprite % 16) * 8, flr(sprite / 16) * 8
    rspr(sx, sy + 8, 8, 8, weaponAngle - 0.25, x + 0.25 * weaponSize * cos(weaponAngle), y + 0.25 * weaponSize * sin(weaponAngle), weaponSize, weaponSize)
    rspr(sx, sy, 8, 8, weaponAngle - 0.25, x + 0.96 * weaponSize * cos(weaponAngle), y + 0.96 * weaponSize * sin(weaponAngle), weaponSize, weaponSize)
    circfill(x, y, sizeRadius, 0)


    local text = "\#1\f4"..round(knockback, 100).." \f5"..round(weaponTurnSpeed * 1000).." \f6"..round(debugSpecial, 100)
    local len = print(text, 0, -10)
    print(text, 64 - len/2, 120, 1)


    local percent = false
    if ammo >= 0 then
        percent = ammo/10
    elseif maxClickCD > 0 then
        percent = clickCD/maxClickCD
    end
    if percent then
        percent = min(percent, 1)
        local w = 8
        local ry = 12
        fillp(▒)
        rectfill(x - w/2 - 1, y - ry - 1, x + w/2 + 1, y - ry + 3, 1)
        if (percent > 0) rectfill(x - w/2, y - ry, x - w/2 + w * mid(0, percent, 1), y - ry + 2, 14)
        fillp()
    end
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