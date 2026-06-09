do

px, py = 64, 64
local sizeRadius, cursorAngle, lastCursorAngle, push, invincible, cursorUnwrap, weaponUnwrap, lastWeaponUnwrap, wasSwinging, weaponTurnSpeed, weaponVelocity, weaponColor, swingDistance, sprite, weaponSize, knockback, maxClickCD, ammo, minTurnSpeed, minSwingDistance, moveSpeed = 4, 0, 0, mdir(0,0), 0, 0, 0, 0, false, 0.03, 0, 1, 0, 32, 20, 0, 0, -1, 0.01, 0.15, 0.775

function playerHit(dir, dmg)
    dmg = dmg or 4.5
    if (invincible > 0) return
    push, invincible = mdir(dmg,dir), 10
    sfx(8)
end

function isSwing()
    return (abs(weaponVelocity) >= min(minTurnSpeed, weaponTurnSpeed) and abs(swingDistance) > minSwingDistance and push.mag <= 0)
end

function getHitbox()
    local kbMult, weaponAngle = 1, weaponUnwrap % 1
    local hitbox = {
        size = 1,
        length = 1,
        offset = 0,
    }
    outputHitbox = {
        x = px + cos(weaponAngle + hitbox.offset) * (weaponSize * 0.625 + sizeRadius),
        y = py + sin(weaponAngle + hitbox.offset) * (weaponSize * 0.625 + sizeRadius),
        r = weaponSize * 0.34375,
    }
    return outputHitbox, weaponVelocity, knockback * kbMult, sprite == 38
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
        px, py = colMove(px, py, 2 * sizeRadius/sqrt(2), speed, dir)
    end

    if ttn(X) then 
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
        px += push.mag * cos(push.dir)
        py += push.mag * sin(push.dir)
        push.mag -= 0.5
    else
        applyInputs()
    end

    lastCursorAngle = cursorAngle
    cursorAngle = to(px,py,cx,cy)

    local d = shortest_diff(lastCursorAngle, cursorAngle)
    cursorUnwrap += d

    if frame == 0 then
        weaponUnwrap = cursorUnwrap
    end

    updateWeaponDirectional()

    --px = mid(sizeRadius, px, 128 - sizeRadius)
    --py = mid(sizeRadius, py, 128 - sizeRadius)

    invincible -= 1
end

function drawPlayer()
    local length = weaponSize
    local weaponAngle = weaponUnwrap % 1
    local swing = isSwing()

    --show hitboxes for debugging
    local hitbox = getHitbox()
    circfill(hitbox.x, hitbox.y, hitbox.r, (swing and 4 or 9)) 

    local sd = abs(swingDistance)
    if swing then
        local width = weaponSize/12 
        local l = weaponSize + sizeRadius - width/2
        local da = weaponAngle - mid(0, (sd - minSwingDistance)/(minSwingDistance), 1) * 0.1 * sgn(weaponVelocity)--(weaponVelocity * 5 * 0.02/weaponTurnSpeed)
        linefill(px + l * cos(da), py + l * sin(da), px + l * cos(weaponAngle), py + l * sin(weaponAngle), width, weaponColor)
    end
    local sx, sy = (sprite % 16) * 8, flr(sprite / 16) * 8
    circfill(px, py, sizeRadius + 1, 1)
    --circfill(px + (sizeRadius + weaponSize * 0.25) * cos(weaponAngle), py + (sizeRadius + weaponSize * 0.25) * sin(weaponAngle), weaponSize/4, 4)
    --circfill(px + (sizeRadius + weaponSize * 0.75) * cos(weaponAngle), py + (sizeRadius + weaponSize * 0.75) * sin(weaponAngle), weaponSize/4, 5)
    rspr(sx, sy + 8, 8, 8, weaponAngle - 0.25, px + (sizeRadius + weaponSize * 0.25) * cos(weaponAngle), py + (sizeRadius + weaponSize * 0.25) * sin(weaponAngle), weaponSize/2 * sqrt(2), weaponSize/2 * sqrt(2))
    rspr(sx, sy    , 8, 8, weaponAngle - 0.25, px + (sizeRadius + weaponSize * 0.75) * cos(weaponAngle), py + (sizeRadius + weaponSize * 0.75) * sin(weaponAngle), weaponSize/2 * sqrt(2), weaponSize/2 * sqrt(2))

    circfill(px, py, sizeRadius, 3)
    --[[
    local s = sizeRadius/sqrt(2)
    rect(px - s, py - s, px + s, py + s, 4)
    ]]
end


end