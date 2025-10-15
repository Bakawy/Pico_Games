do

local spawnDuration = 60

local function checkWeapon(enemy)

    local function vnorm(x,y)
        local m = sqrt(x*x + y*y)
        if (m < 0.0001) return 0,0,0
        return x/m, y/m, m
    end

    local hitboxes, wv, _, direct = getHitbox()
    local px, py = getPlayerPos()
    for h in all(hitboxes) do
        if (isSwing() and dist(enemy.x, enemy.y, h.x, h.y) < enemy.size + h.r) then
            addAmmo()
            local rx, ry = h.x - px, h.y - py
            local rlen = sqrt(rx*rx + ry*ry)

            local dir = -sgn(wv)  -- PICO-8 has sgn()
            local tx, ty = -ry*dir, rx*dir
            local ux, uy, _ = vnorm(tx, ty)

            local linearSpeed = abs(wv) * rlen

            enemy.hit = atan2(ux, uy) + randDec(-0.07, 0.07)
            if (direct) enemy.hit = atan2(rx, ry) + randDec(-0.07, 0.07)
            enemy.kb += 0.2--mid(0.08, speed * 0.25, 0.28)
            enemy.noHit = 10
            break
        end
    end
end

Enemy = Class:new({
    x = 64,
    y = 64,
    size = 4,
    speed = 0.3,
    dmg = 5,
    def=1,
    hit = false,
    dead = false,
    stun = 0,
    push = {mag=0, dir=0},
    kb = 1,
    spawn = 0,
    noHit = 0,
    col = 0,
    toh = true, --Trigger On Hit
    behavior = function(_ENV) 
        local px, py = getPlayerPos()
        local dir = atan2(px - x, py - y)
        return {mag=1,dir=dir}
    end,
    
    update = function(_ENV) 
        if spawn < spawnDuration then
            spawn += 1
            return
        end

        moveDir = move(_ENV)

        if noHit > 0 then
            noHit -= 1
        else
            checkWeapon(_ENV)
        end

        checkPlayerCol(_ENV, moveDir)

        if hit then
            if (toh) triggerOnHit()
            toh = true
            local a, b, dmg = getHitbox()
            push = {mag=dmg * kb * def, dir=hit}
            hit = false

            local mag = 2
            for i=1, 10 do
                local angle = randDec(0, 1)
                local dx, dy = mag * cos(angle), mag * sin(angle)
                local radius = 5
                local len = 10
                Particle:new({
                    x = x,
                    dx = dx,
                    ddx = -dx/len,
                    y = y,
                    dy = dy,
                    ddy = -dy/len,
                    r = radius,
                    dr = -radius/len,
                    len = len,
                    col = col
                },particles)
            end

            sfx(4)
        end
    end,
    move = function(_ENV)
        if push.mag > 0 then
            x += cos(push.dir) * push.mag * deltaTime
            y += sin(push.dir) * push.mag * deltaTime
            push.mag -= 0.5
        end
        if stun > 0 then
            stun -= 1
            return
        end
        bmove = behavior(_ENV)
        x += cos(bmove.dir) * bmove.mag * speed * deltaTime
        y += sin(bmove.dir) * bmove.mag * speed * deltaTime

        if x + size < 0 or x - size > 128 or y + size < 0 or y - size > 128 then
            dead = true
        end
        return bmove.dir
    end,
    checkPlayerCol = function(_ENV, velDir)
        if (push.mag > 0) return
        local px, py, pr = getPlayerPos()
        if dist(x, y, px, py) < size + pr then
            playerHit(velDir)
            stun = 15
        end
    end,
})
enemies = {}

local function deathParticle(enemy)
    local dir = enemy.push.dir - 0.5--atan2(enemy.x - 64, enemy.y - 64) - 0.5
    local mag = 3
    for i=1, 10 do
        local angle = dir + randDec(-0.1, 0.1)
        local dx, dy = mag * cos(angle), mag * sin(angle)
        local radius = 7
        Particle:new({
            x = enemy.x,
            dx = dx,
            ddx = -dx/30,
            y = enemy.y,
            dy = dy,
            ddy = -dy/30,
            r = radius,
            dr = -radius/30,
            len = 30,
            col = enemy.col
        },particles)
    end
end

function spawnEnemy(count)
    count = count or 1
    for i=1,count do
        local t = rnd({4, 5, 6})
        local tTable = {
            [4] = {
                dmg=10,
                speed=0.3,
                def=1,
                state=0,
                behavior = function(_ENV)
                    local mag = 1
                    local px, py = getPlayerPos()
                    local dir = atan2(px - x, py - y)
                    local playerDist = dist(x, y, px, py)
                    local targetDist = 28

                    if state < 0 then
                        state += 1
                        mag = 3
                        return {mag=mag,dir=dir}
                    end

                    if playerDist == mid(targetDist - 2, playerDist, targetDist + 2) then
                        state += 1
                        mag = 0
                        if (state >= 30) state = -30
                    end

                    if (playerDist < targetDist - 2) dir -= 0.5

                    --centerPrint(state, x, y-8,3)
                    return {mag=mag,dir=dir}
                end,
            },
            [5] = {
                dmg=5,
                speed=0.6,
                def=1,
            },
            [6] = {
                dmg=5,
                speed=0.3,
                def=0.75,
            },
        }
        local enemy = {
            x=randDec(8, 120), 
            y=randDec(8, 120), 
            col=t,
        }
        for k, v in pairs(tTable[t]) do
            enemy[k] = v
        end
        Enemy:new(enemy, enemies)
    end
end

function updateEnemies()
    for e in all(enemies) do
        e:update()
        if e.dead then
            score += 1
            addColor(e.col, 1)
            deathParticle(e)
            sfx(2)
            del(enemies, e)
            spawnEnemy()
        end
    end
end



function drawEnemies()
    for e in all(enemies) do
        if e.spawn < spawnDuration then
            pal(8, e.col)
            spr(2, e.x - 4, e.y - 4)
            pal(0)
        else
            circfill(e.x, e.y, e.size, e.col)
        end
    end
end

end