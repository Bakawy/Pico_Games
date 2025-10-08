do

Enemy = Class:new({
    x = 64,
    y = 64,
    xVel = 0,
    yVel = 0,
    noInput = 0,
    jumps = 0,
    maxJumps = 2,
    grounded = false,
    hitStun = 0,
    dead = false,
    checkOrb = function(_ENV)
        local ox, oy, oRadius = getOrbPos()
        if dist(x, y, ox, oy) < sqrt(32) + oRadius then
            local isDamaging, knockback, hs = getOrbDamage()
            if isDamaging then
                --circfill(ox, oy, oRadius, 1)
                --circfill(x, y, sqrt(32), 2)
                --stop()
                xVel = knockback.mag * cos(knockback.dir)
                yVel = knockback.mag * sin(knockback.dir)
                hitStun = hs
                noInput = 10
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
            jumps = maxJumps
        end

        if noInput > 0 and xCol then
            xVel = xv * -1
        end
        if noInput > 0 and yCol then
            yVel = yv * -1
        end

        local friction = 0.5
        if (noInput <= 0) xVel = abs(xVel) < friction and 0 or xVel - sgn(xVel)*friction
    end,
    draw = function(_ENV)
        local dx, dy = x, y
        if hitStun > 0 then
            dx += randDec(-1.5, 1.5)
            dy += randDec(-1.5, 1.5)
        end
        spr(16, dx - 4, dy - 4)

        centerPrint(dist(xVel, yVel, 0, 0), x, y - 10, 7)
    end,
})
enemies = {}

function updateEnemies() 
    for e in all(enemies) do
        if e.hitStun > 0 then
            e.hitStun -= 1
            return
        end
        e:checkOrb()
        e:move()

        e.noInput -= 1
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