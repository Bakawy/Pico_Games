do

local player = getPlayerState()
local basicAttack = {
    {x=-16, y=0, len=15},
    {x=16, y=-8, len=15, speed = 1.5},
    {x=24, y=0, len=15, speed = 1.5},
    endLag = 30,
}

Enemy = Class:new({
    x = 64,
    y = 64,
    xVel = 0,
    yVel = 0,
    noInput = 0,
    knocked = 0,
    grounded = false,
    hitStun = 0,
    dead = false,
    speed = 0.5,
    canSeePlayer = false,
    target = {x=64,y=64},
    wallTouch = false,
    runAway = false,
    kbMult = 1,

    attackCD = 0,
    attackData = basicAttack,
    attackAnchor = {x=64,y=64},
    behavior = "idle",
    currentAttackIndex = 1,
    attackTimer = 0,
    attackStartTime = 0,
    attackDir = 1,
    
    followTarget = function(_ENV, targetDist, speed)
        targetDist = targetDist or 0
        speed = speed or _ENV.speed
        local jumpStrength = 5
        local dx = target.x - x
        local dy = target.y - y
        local distToTarget = max(0.001, sqrt(dx*dx + dy*dy))

        local dirx = dx / distToTarget
        local diry = dy / distToTarget


        local desiredDir = (distToTarget > targetDist) and 1 or -1
        if (abs(distToTarget - targetDist) < 4) desiredDir = 0
        xVel = dirx * speed * desiredDir


        if grounded and (y - 4 > target.y) then
            yVel = -jumpStrength
            grounded = false
        end

        if yVel < -jumpStrength/3 and y < target.y then
            yVel = -jumpStrength/3
        end
        return desiredDir
    end,

    idle = function(_ENV)
        if (canSeePlayer) behavior = "follow"
    end,
    follow = function(_ENV)
        
        if canSeePlayer then
            target.x, target.y = player.x, player.y
        end

        local desiredDir = followTarget(_ENV, 16)

        if desiredDir == 0 and canSeePlayer and attackCD <= 0 and grounded then
            attackAnchor.x, attackAnchor.y = x, y
            behavior = "attack"
            attackTimer = 0
            attackStartTime = 0
            currentAttackIndex = 1
            baseSpeed = speed
            attackDir = sgn(player.x - x)
        end
    end,
    attack = function(_ENV)
        local currentPoint = attackData[currentAttackIndex]
        local nextPoint = attackData[currentAttackIndex + 1]
        local distToTarget = dist(x, y, target.x, target.y)

        if attackTimer > currentPoint.len + attackStartTime or distToTarget < 8 then
            attackStartTime = attackTimer
            currentAttackIndex += 1
            currentPoint = attackData[currentAttackIndex]
            nextPoint = attackData[currentAttackIndex + 1]

            --target.x, target.y = currentPoint.x + attackAnchor.x, currentPoint.y + attackAnchor.y
            --if (currentPoint.speed) speed = currentPoint.speed
            if currentAttackIndex > #attackData then
                behavior = "idle"
                target.x, target.y = x, y
                speed = baseSpeed
                noInput = attackData.endLag
                attackCD = 60
                return
            end
        end

        target.x, target.y = currentPoint.x * attackDir + attackAnchor.x, currentPoint.y + attackAnchor.y

        attackTimer += 1
        followTarget(_ENV, 0, currentPoint.speed)
        if checkPlayerCollison(_ENV) then
            pushPlayer(3, atan2(x - player.x, y - player.y), 30)
            setPlayerHS(15)
            --circfill(x, y, 4, 9)
            --circfill(player.x, player.y, 4, 10)
            --stop()
        end
    end,
    

    checkPlayerCollison = function (_ENV)
        return dist(x, y, player.x, player.y) < 8
    end,
    checkPlayerSight = function(_ENV)
        local _, _, xCol = move_x(x, y, player.x - x, 2)
        local _, _, yCol = move_y(x, y, player.y - y, 2)
        canSeePlayer = not (xCol or yCol)
        --line(x, y, player.x, player.y, canSeePlayer and 11 or 8)
        --centerPrint(tostr(xCol).." "..tostr(yCol), x, y - 20, 7)
    end,
    checkOrb = function(_ENV)
        local ox, oy, oRadius = getOrbPos()
        if dist(x, y, ox, oy) < sqrt(32) + oRadius then
            local isDamaging, knockback, hs = getOrbDamage()
            if isDamaging then
                --circfill(ox, oy, oRadius, 1)
                --circfill(x, y, sqrt(32), 2)
                --stop()
                knockback.mag *= kbMult
                xVel = knockback.mag * cos(knockback.dir)
                yVel = knockback.mag * sin(knockback.dir)
                hitStun = hs
                knocked = 10
                runAway = true
                kbMult += 0.05
                behavior = "idle"
            end
        end
    end,
    move = function(_ENV)
        yVel += gravity
        local xv = xVel
        local yv = yVel
        local down, yCol, xCol = yVel > 0
        y, yVel, yCol = move_y(x, y, yVel, 8)
        x, xVel, xCol = move_x(x, y, xVel, 8)

        wallTouch = xCol
        if xCol and fget(xCol, 1) then
            dead = true
            return
        end
        if yCol and fget(yCol, 1) then
            dead = true
            return
        end

        grounded = false
        if (down and yCol) then 
            grounded = true 
            runAway = false
        end

        if knocked > 0 and xCol then
            xVel = xv * -1
        end
        if knocked > 0 and yCol then
            yVel = yv * -1
        end

        local friction = 0.5
        if (noInput <= 0 and knocked <= 0) xVel = abs(xVel) < friction and 0 or xVel - sgn(xVel)*friction

        if (noInput > -1) noInput -= 1
        if (knocked > -1) knocked -= 1
        if (attackCD > -1) attackCD -= 1
    end,
    update = function(_ENV)
        if hitStun > 0 then
            hitStun -= 1
            return
        end
        checkOrb(_ENV)
        checkPlayerSight(_ENV)

        if noInput <= 0 and knocked <= 0 then
            _ENV[behavior](_ENV)
        end
        move(_ENV)
    end,
    draw = function(_ENV)
        local dx, dy = x, y
        if hitStun > 0 then
            dx += randDec(-1.5, 1.5)
            dy += randDec(-1.5, 1.5)
        end
        centerPrint("\#0"..flr((kbMult - 1) * 100).."%", dx, dy - 8, 7)
        if behavior == "attack" then
            rect(x - 5, y - 5, x + 4, y + 4, 9)
        end
        spr(16 + (knocked > 0 and 16 or 0), x - 4, y - 4)

        --centerPrint(dist(xVel, yVel, 0, 0), x, y - 10, 7)
        --centerPrint(behavior, x, y - 8, 7)
        --circfill(target.x, target.y, 2, 12)
    end,
})
enemies = {}

function updateEnemies() 
    player = getPlayerState()
    --player.x, player.y = 116, 116
    for e in all(enemies) do
        e:update()
        if e.dead then
            del(enemies, e)
        end
    end
end

function drawEnemies()
    for e in all(enemies) do
        e:draw()
    end
end

end