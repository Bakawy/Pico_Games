do

local spawnDuration = 60
local px, py, pr = 64, 64, 8

local function checkWeapon(enemy)

    local function vnorm(x,y)
        local m = sqrt(x*x + y*y)
        if (m < 0.0001) return 0,0,0
        return x/m, y/m, m
    end

    local hitboxes, wv, _, direct = getHitbox()
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
    onHit = nil,
    onUpdate = nil,
    onPlayer = nil,
    toh = true, --Trigger Weapon On Hit
    behavior = function(_ENV) 
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
            local flag
            if (onHit) flag = onHit(_ENV)
            if (flag) goto skip
            local _, _, dmg = getHitbox()
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
        ::skip::
        if (onUpdate) onUpdate(_ENV)
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
        if dist(x, y, px, py) < size + pr then
            playerHit(velDir, dmg)
            stun = 15
            if (onPlayer) onPlayer(_ENV)
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
        local t = rnd({4, 5, 6, 7, 8, 9, 10, 11, 12})
        local tTable = {
            [4] = {
                dmg=5.5,
                state=0,
                behavior = function(_ENV)
                    local mag = 1
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
                speed=0.6,
            },
            [6] = {
                def=0.85,
                size=6,
            },
            [7] = {
                state=0,
                moveLine=nil,
                lineDir=nil,
                dmg=5.5,
                speed=0.45,
                col = col, --cuz vscode says its an error without this
                onHit = function (_ENV)
                    moveLine=nil
                    state=0
                    lineDir=0
                end,
                behavior = function(_ENV)
                    local mag = 1
                    local dir = atan2(px - x, py - y)
                    local playerDist = dist(x, y, px, py)
                    local targetDist = 32

                    if state < 0 then
                        mag = 4.5
                        linefill(moveLine[1],moveLine[2],moveLine[3],moveLine[4],1.125,col)
                        if dist(x, y, moveLine[3], moveLine[4]) < size then 
                            onHit(_ENV)
                        end
                        return {mag=mag,dir=lineDir}
                    end

                    if state > 0 then
                        moveLine[3] += 2 * cos(lineDir)
                        moveLine[4] += 2 * sin(lineDir)
                        if moveLine[3] != mid(2, moveLine[3], 126) or moveLine[4] != mid(2, moveLine[4], 126) then
                            state = 1000
                        end

                        state += 1
                        if (state >= 33) state = -1
                        linefill(moveLine[1],moveLine[2],moveLine[3],moveLine[4],1.125,col)
                        return {mag=0,dir=lineDir}
                    end

                    if playerDist == mid(targetDist - 2, playerDist, targetDist + 2) and push.mag <= 0 then
                        state += 1
                        lineDir=dir
                        moveLine = {x,y,x,y}
                    end

                    if (playerDist < targetDist - 2) dir -= 0.5

                    return {mag=mag,dir=dir}
                end,
            },
            [8] = {
                dmg=5.5,
                tps=2,
                onHit = function(_ENV)
                    local direction = atan2(px - x, py - y)
                    --local distance = dist(x, y, px, py)
                    x = px + 20 * cos(direction)
                    y = py + 20 * sin(direction)
                    hit = false

                    local len = 15
                    local radius = 12
                    Particle:new({
                        x = x,
                        y = y,
                        r = radius,
                        dr = -radius/len,
                        len = len,
                        col = col
                    },particles)

                    tps -= 1
                    if tps <= 0 then
                        onHit = nil
                    end
                    return true
                end,
            },
            [9] = {
                spawnInterval=4,
                spawnTimer = 0,
                speed=0.45,
                onUpdate = function(_ENV)
                    --if (push.mag > 0) return
                    spawnTimer -= 1
                    if spawnTimer <= 0 then
                        spawnTimer = spawnInterval
                        Projectile:new({
                            x = x,
                            y = y,
                            len = spawnInterval * 50,
                            size = size,
                            col = col,
                            onPlayer = function(_ENV)
                                playerHit(atan2(px - x, py - y))
                            end,
                            draw = function(_ENV)
                                fillp(▒)
                                circfill(x,y,size,col)
                                fillp()
                            end
                        }, projectiles)
                    end
                end,
            },
            [10] = {
                size = 8,
                def = 0.5,
                state = 0,
                dmg = 6.5,
                moveDir = nil,
                moveSpeed = 0,
                behavior = function(_ENV)
                    local mag = 1
                    local dir = atan2(px - x, py - y)
                    local playerDist = dist(x, y, px, py)

                    if state < 0 then
                        state += 1
                        return {mag=0,dir=dir}
                    end

                    if state > 0 then
                        moveSpeed += 0.2
                        if x != mid(size, x, 128-size) or y != mid(size, y, 128-size) then 
                            onPlayer(_ENV)
                            moveSpeed = 0
                        end
                        return {mag=moveSpeed,dir=moveDir}
                    end

                    if x == mid(size, x, 128-size) and y == mid(size, y, 128-size) then 
                        moveDir = dir
                        state = 1
                        moveSpeed = 0
                    else
                        dir = atan2(64 - x, 64 - y)
                    end

                    return {mag=mag,dir=dir}
                end,
                onHit = function(_ENV)
                    state = -30
                end,
                onPlayer = function(_ENV)
                    local len = 30
                    if state > 0 then
                        state = -len
                        x = mid(size, x, 128-size)
                        y = mid(size, y, 128-size)
                        Projectile:new({
                            x = x,
                            y = y,
                            len = len,
                            size = size - 1,
                            dsize = 16/len,
                            col = col,
                            onPlayer = function(_ENV)
                                playerHit(atan2(px - x, py - y), 7)
                            end,
                            draw = function(_ENV)
                                circfill(x,y,size+2,col)
                                circfill(x,y,size,13)
                            end
                        }, projectiles)
                    end
                end
            },
            [11] = {
                size = 8,
                def = 0.5,
                state = 0,
                speed = 1.75,
                dmg=3,
                moveDir = nil,
                behavior = function(_ENV)
                    local mag = 1
                    local dir = atan2(px - x, py - y)
                    local playerDist = dist(x, y, px, py)
                    if state > 0 then
                        if (x != mid(size, x, 128-size) or y != mid(size, y, 128-size)) and push.mag <= 0 then 
                            moveDir = dir
                        end
                        return {mag=mag,dir=moveDir}
                    end

                    moveDir = dir
                    state = 1

                    return {mag=mag,dir=dir}
                end,
                onHit = function(_ENV)
                    moveDir = (0.5 - moveDir) % 1
                end,
                onPlayer = function(_ENV)
                    if state > 0 then
                        local a = moveDir
                        local n = atan2(x - px, y - py)
                        moveDir = a - 2 * dot(a, n) * n
                        stun = 0
                    end
                end
            },
            [12] = {
                x = randDec(56,72),
                y = randDec(56,72),
                size = 8,
                def = 0.5,
                fireTimer = 30,
                fireRate = 1,
                behavior = function(_ENV)
                    local mag = 1
                    local dir = atan2(px - x, py - y)
                    --local playerDist = dist(x, y, px, py)
                    fireTimer -= 1
                    if fireTimer <= 0 then
                        fireTimer = 60 / fireRate
                        Projectile:new({
                            x = x,
                            y = y,
                            speed = 1,
                            dir = dir,
                            range = 200,
                            size = 4,
                            col = col,
                            onPlayer = function(_ENV)
                                playerHit(atan2(px - x, py - y))
                                dead = true
                            end,
                            onWeapon = function(_ENV,h)
                                if (isSwing()) dead = true
                            end
                        }, projectiles)
                    end
                    return {mag=0,dir=dir}
                end,
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
    px, py, pr = getPlayerPos()
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