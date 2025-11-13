do

local x, y, sizeRadius, cursorAngle, lastCursorAngle, push, invincible, cursorUnwrap, weaponUnwrap, lastWeaponUnwrap, wasSwinging, weaponTurnSpeed, weaponVelocity, weaponColor, swingDistance, sprite, stateTimer, weaponTurnSpeed, weaponSize, knockback, maxClickCD, ammo, minTurnSpeed, minSwingDistance, clickCD, forceSwing, debugSpecial, moveSpeed = 64, 64, 4, 0, 0, mdir(0,0), 0, 0, 0, 0, false, 0.02, 0, 1, 0, 39, 0, 0, 16, 0, 0, -1, 0.01, 0.15, 0, 0, 0, 0.775

local function mask_setSpecial(s) debugSpecial=max(3+s/5,0.25) stateTimer=debugSpecial*60 end
local function mask_toggle(next_id,col)
  sprite=next_id
  setWeaponStats(countColors(sprite))
  weaponColor=col
  stateTimer=debugSpecial*60
end

local smallHitbox = {
    size = 0.5,
    length = 0.9,
    offset = 0
}

local spriteData = {
    [32] = {
        kb = 25,
        wts = 0.025,
        setSpecial = function(special)
            weaponSize = round(16 + 0.35 * special)
            debugSpecial = weaponSize
        end
    },
    [33] = {
        kb = 25,
        wts = 0.025,
        mccd = 30,
        streakLen = 0.9,
        ammo = 5,
        size = 18,
        onClick = function()
            if ammo > 0 then
                fireRoutine = addRoutine(function()
                    for i=1,debugSpecial do
                        sfx(1)
                        Projectile:new({
                            x=x, 
                            y=y, 
                            dir=weaponUnwrap % 1, 
                            speed=2, 
                            range=96,
                            size=3.375,
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
            debugSpecial = max(flr(1 + special), 1)
        end,
        hitbox = smallHitbox,
    },
    [34] = {
        kb = 25,
        wts = 0.025,
        streakLen = 1.25,
        hitbox = {
            size = 1.2,
            length = 0.75,
            offset = 0
        },
        onTimer = function()
            mask_toggle(35,3)
        end,
        setSpecial = mask_setSpecial,
    },
    [35] = {
        kb = 25,
        wts = 0.025,
        streakLen = 1.25,
        hitbox = {
            size = 1.2,
            length = 0.75,
            offset = 0
        },
        onTimer = function()
            mask_toggle(34,1)
        end,
        setSpecial = mask_setSpecial,
    },
    [36] = {
        kb = 25,
        wts = 0.025,
        mccd = 180,
        onClick = function()
            push = mdir(7.5, weaponUnwrap)
            forceSwing = 30
            sfx(5)
        end,
        setSpecial = function (special)
            maxClickCD = 180 - 165 * (special/84)
            debugSpecial = maxClickCD/60
        end,
    },
    [37] = {
        kb = 9,
        wts = 0.018,
        setSpecial = function(special)
            debugSpecial = 1 + 5 * (special/108)
        end,
        onHit = function() 
            local hitbox = getHitbox()
            --[[
            local noSpawn = false
            for p in all(projectiles) do
                if p.fireRate then
                    if dist(hitbox.x, hitbox.y, p.x, p.y) < 3 + p.size then
                        p.size += 3
                        p.fireRate += debugSpecial
                        noSpawn = true
                    end
                end
            end
            if (noSpawn) return
            ]]
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
        kb = 2,
        wts = 0.02,
        streakLen = 0.9,
        hitbox = {
            size = 1,
            length = 0.4,
            offset = 0
        },
        setSpecial = function(special)
            debugSpecial = special
            isSwing = function()
                return true
            end
        end,
        onClick = function()
            sprite = 40
            Projectile:new({
                x=x, 
                y=y, 
                dir=weaponUnwrap, 
                a=weaponUnwrap,
                speed = 2, 
                size = weaponSize/2 * (1 + 0.01136363636 * debugSpecial),
                onEnemy = function(_ENV, e)
                    e.hit = to(_ENV.x,_ENV.y,e.x,e.y)
                    e.kb += 0.2
                    speed /= 2
                end,
                move = function(_ENV) 
                    _ENV.x = mid(size, _ENV.x + speed * cos(dir), 128 - size)
                    _ENV.y = mid(size, _ENV.y + speed * sin(dir), 128 - size)
                    speed = max(0, speed - 0.05)
                    a += speed/40
                end,
                draw = function(_ENV)
                    rspr(48, 21, 8, 11, a-0.25, _ENV.x, _ENV.y, _ENV.size*2, _ENV.size * (11/4))
                end,
                onPlayer = function(_ENV)
                    if (speed > 0) return
                    sprite, dead = 38, true
                    setWeaponStats(countColors(38))
                end,
            }, projectiles)
            setWeaponStats(countColors(38))
        end,
    },
    --[[
    [38] = {
        kb = 9,
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
                                local dir = to(_ENV.x,_ENV.y,e.x,e.y)
                                e.hit = dir
                                e.kb += 0.2
                            end,
                        }, projectiles)
                    end,
                }, projectiles)
                ammo -= 1
            end
        end,
        hitboxes = smallHitbox,
    },
    ]]
    [39] = {
        kb = 16,
        wts = 0.025,
        streakLen = 0.6,
        mccd = 30,
        ammo = 5,
        size = 24,
        hitbox = {
            size = 0.7,
            length = 0.4,
            offset = 0
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
                    dir=weaponUnwrap, 
                    speed = 2, 
                    sprite = 55,
                    size = weaponSize * 0.7/2,
                    bounces = debugSpecial,
                    noHit = 0,
                    move = function(_ENV)
                        _ENV.x += speed * cos(dir)
                        _ENV.y += speed * sin(dir)
                        
                        if _ENV.x + size > 128 or _ENV.x - size < 0 then
                            dir = mirrorX(dir)
                            bounces -= 1
                            sfx(9)
                        end
                        if _ENV.y + size > 128 or _ENV.y - size < 0 then 
                            dir = mirrorY(dir) 
                            bounces -= 1
                            sfx(9)
                        end
                        if bounces < 0 then 
                            dead = true
                            sfx(9, -2)
                        end
                        noHit -= 1
                    end,
                    onEnemy = function(_ENV, e)
                        if (noHit > 0) return
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
    [40] = {
        kb = 3,
        wts = 1,
        size = 0,
        setSpecial = function(special)
            moveSpeed = 1 + 0.01515151515 * special
            debugSpecial = special
        end,
    },
}

function playerHit(dir, dmg)
    dmg = dmg or 4.5
    if (invincible > 0) return
    push, invincible = mdir(dmg,dir), 10
    sfx(8)
end

function isSwing()
    return (abs(weaponVelocity) >= min(minTurnSpeed, weaponTurnSpeed) and abs(swingDistance) > minSwingDistance and push.mag <= 0) or forceSwing > 0
end

function getHitbox()
    local kbMult, weaponAngle = 1, weaponUnwrap % 1
    local hitbox = spriteData[sprite].hitbox or {
        size = 1,
        length = 1,
        offset = 0,
    }
    outputHitbox = {
        x = x + cos(weaponAngle + hitbox.offset) * weaponSize * hitbox.length,
        y = y + sin(weaponAngle + hitbox.offset) * weaponSize * hitbox.length,
        r = weaponSize * hitbox.size/2,
    }
    return outputHitbox, weaponVelocity, knockback * kbMult, (forceSwing > 0 and sprite == 36 or sprite == 38)
end

function getWeapon()
    return sprite, spriteData[sprite]
end

function getPlayerPos()
    return x, y, sizeRadius
end

function setWeaponStats(colors)
    --weaponTurnSpeed = spriteData[sprite].wts or 0.03
    local weapon = spriteData[sprite]
    maxClickCD, ammo, weaponSize, moveSpeed = weapon.mccd or 0, weapon.ammo or -1, weapon.size or 16, weapon.speed or 0.775
    local red, yellow, blue = (colors[4] or 0) + (colors[7] or 0) + (colors[8] or 0) + 3 * (colors[10] or 0) - (colors[11] or 0),
    (colors[5] or 0) + (colors[7] or 0) + (colors[9] or 0) + 3 * (colors[11] or 0) - (colors[12] or 0),
    (colors[6] or 0) + (colors[8] or 0) + (colors[9] or 0) + 3 * (colors[12] or 0) - (colors[10] or 0)
    knockback, weaponTurnSpeed = weapon["kb"] * (1 + 0.06118 * red), max(weapon["wts"] + 0.0005 * yellow, 0.001)
    weapon["setSpecial"](blue)
end

setWeaponStats({})

function setWeaponColor(col)
    weaponColor = col
end

function setPlayerPos(posx, posy)
    x, y, clickCD = posx, posy, 15
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

function applyInputs(speed)
    local  dir = {0, 0}
    speed = speed or moveSpeed
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
    local diff, wts = cursorUnwrap - weaponUnwrap, weaponTurnSpeed
    local step = mid(-wts, diff, wts)
    if flr(diff * 50) % 50 == 0 then
        weaponUnwrap = cursorUnwrap
    end

    if abs(diff) <= weaponTurnSpeed then
        weaponUnwrap = cursorUnwrap
    else
        weaponUnwrap += step
    end


    weaponVelocity, lastWeaponUnwrap = weaponUnwrap - lastWeaponUnwrap, weaponUnwrap

    if abs(weaponVelocity) >= min(minTurnSpeed, weaponTurnSpeed) then
        swingDistance += step
    else
        swingDistance = 0
    end


    local swinging = abs(weaponVelocity) >= minTurnSpeed and abs(swingDistance) > minSwingDistance and push.mag <= 0

    if swinging and not wasSwinging and weaponSize > 0 then
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
    cursorAngle = to(x,y,cx,cy)

    local d = shortest_diff(lastCursorAngle, cursorAngle)
    cursorUnwrap += d

    if frame == 0 then
        weaponUnwrap = cursorUnwrap
    end

    updateWeaponDirectional()

    if push.mag > 0 then 
        if x != mid(-4, x, 132) or y != mid(-4, y, 132) then
            gameState, noClick = 3, 30
            local weapon = getWeapon()
            if (dget(weapon) <= 0 and score < dget(weapon)) dset(weapon, -roundCount)
            if (roundCount > #waveData/2) dset(0, winCount + 1) dset(0, winCount + 1)
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

    --[[
    --show hitboxes for debugging
    local hitbox = getHitbox()
    circfill(hitbox.x, hitbox.y, hitbox.r, (swing and 4 or 9)) 
    ]]

    local sd = abs(swingDistance)
    if swing then
        local width = weaponSize/12
        local l = spriteData[sprite]["streakLen"] and weaponSize * spriteData[sprite]["streakLen"] or weaponSize * 1.25
        local da = weaponAngle - mid(0, (sd - minSwingDistance)/(minSwingDistance), 1) * 0.1 * sgn(weaponVelocity)--(weaponVelocity * 5 * 0.02/weaponTurnSpeed)
        linefill(x + l * cos(da), y + l * sin(da), x + l * cos(weaponAngle), y + l * sin(weaponAngle), width, weaponColor)
    end
    local sx, sy = (sprite % 16) * 8, flr(sprite / 16) * 8
    circfill(x, y, sizeRadius + 1, 3)
    rspr(sx, sy + 8, 8, 8, weaponAngle - 0.25, x + 0.25 * weaponSize * cos(weaponAngle), y + 0.25 * weaponSize * sin(weaponAngle), weaponSize, weaponSize)
    rspr(sx, sy, 8, 8, weaponAngle - 0.25, x + 0.96 * weaponSize * cos(weaponAngle), y + 0.96 * weaponSize * sin(weaponAngle), weaponSize, weaponSize)
    circfill(x, y, sizeRadius, 0)


    local text = "\#1\f4"..round(knockback, 10).." \f5"..round(weaponTurnSpeed * 1000,10).." \f6"..round(debugSpecial, 10)
    local len = print(text, 0, -10)
    print(text, 64 - len/2, 120, 1)


    local percent = false
    if ammo >= 0 then
        percent = ammo/10
    elseif maxClickCD > 0 and clickCD > 0 then
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