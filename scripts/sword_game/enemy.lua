do

local spawnDuration, px, py, pr = 60, 64, 64, 8

local function checkWeapon(enemy)
    --if (spawn >= spawnDuration) return
    local function vnorm(x,y)
        local m = sqrt(x*x + y*y)
        if (m < 0.0001) return 0,0,0
        return x/m, y/m, m
    end

    local hitbox, wv, _, direct = getHitbox()
    if (isSwing() and dist(enemy.x, enemy.y, hitbox.x, hitbox.y) < enemy.size + hitbox.r) then
        addAmmo()
        local rx, ry = hitbox.x - px, hitbox.y - py
        local rlen, dir = sqrt(rx*rx + ry*ry), -sgn(wv)
        local tx, ty = -ry*dir, rx*dir
        local ux, uy, _ = vnorm(tx, ty)

        local linearSpeed = abs(wv) * rlen

        enemy.hit, enemy.noHit = atan2(ux, uy) + randDec(-0.07, 0.07), 10
        if (direct) enemy.hit = atan2(rx, ry) + randDec(-0.07, 0.07)
        enemy.kb += 0.2--mid(0.08, speed * 0.25, 0.28)
    end
end

Enemy = Class:new({
    x = 64,
    y = 64,
    size = 4,
    speed = 0.3,
    dmg = 5,
    def=1,
    push = mdir(0,0),
    --hit = false,
    --dead = false,
    stun = 0,
    kb = 1,
    spawn = spawnDuration,
    noHit = 0,
    col = 0,
    --onHit = nil,
    --onUpdate = nil,
    --onPlayer = nil,
    toh = true, --Trigger Weapon On Hit
    behavior = function(_ENV) 
        local dir = to(x,y,px,py)
        return mdir(1,dir)
    end,
    
    update = function(_ENV) 
        if spawn > 0 then
            spawn -= 1
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
            push = mdir(sqrt(dmg * kb * def), hit)
            hit = false

            particleBurst(x, y, 2, 5, 10, 10, col)
            sfx(4)
        end
        ::skip::
        if (onUpdate) onUpdate(_ENV)
    end,
    move = function(_ENV)
        if x + size < 0 or x - size > 128 or y + size < 0 or y - size > 128 then
            dead = true
        end
        if push.mag > 0 then
            x += cos(push.dir) * push.mag
            y += sin(push.dir) * push.mag
            push.mag -= 0.5
            return
        end
        if stun > 0 then
            stun -= 1
            return
        end
        bmove = behavior(_ENV)
        x += cos(bmove.dir) * bmove.mag * speed
        y += sin(bmove.dir) * bmove.mag * speed

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
    draw = function(_ENV)
        if spawn > 0 then
            pal(2, col)
            sspr(88, 0, 16, 16, x-8, y-8)
            pal(0)
        else
            circfill(x, y, size + 1, 1)
            circfill(x, y, size, col)
        end
    end,
})
enemies = {}

local function deathParticle(enemy)
    particleBurst(enemy.x, enemy.y, 3, 7, 30, 10, enemy.col, enemy.push.dir - 0.5, 0.2)
end

local tTable = {
    [4] = {
        dmg=5.5,
        state=0,
        behavior = function(_ENV)
            local mag = 1
            local dir = to(x,y,px,py)
            local playerDist = dist(x, y, px, py)
            local targetDist = 28

            if state < 0 then
                state += 1
                mag = 3
                return mdir(mag,dir)
            end

            if within(targetDist - 2, playerDist, targetDist + 2) then
                state += 1
                mag = 0
                if (state >= 30) state = -30
            end

            if (playerDist < targetDist - 2) dir -= 0.5

            --centerPrint(state, x, y-8,3)
            return mdir(mag,dir)
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
            local dir = to(x,y,px,py)
            local playerDist = dist(x, y, px, py)
            local targetDist = 32

            if state < 0 then
                mag = 4.5
                linefill(moveLine[1],moveLine[2],moveLine[3],moveLine[4],1.125,col)
                if dist(x, y, moveLine[3], moveLine[4]) < size then 
                    onHit(_ENV)
                end
                return mdir(mag,lineDir)
            end

            if state > 0 then
                moveLine[3] += 2 * cos(lineDir)
                moveLine[4] += 2 * sin(lineDir)
                if not (within(moveLine[3], 2, 126) and within(moveLine[4], 2, 126)) then
                    state = 1000
                end

                state += 1
                if (state >= 33) state = -1
                linefill(moveLine[1],moveLine[2],moveLine[3],moveLine[4],1.125,col)
                return mdir(0,lineDir)
            end

            if within(playerDist, targetDist - 2, targetDist + 2) and push.mag <= 0 then
                state += 1
                lineDir=dir
                moveLine = {x,y,x,y}
            end

            if (playerDist < targetDist - 2) dir -= 0.5

            return mdir(mag,dir)
        end,
        onPlayer = function (_ENV)
            if (state < 0) stun = 0
        end,
    },
    [8] = {
        dmg=5.5,
        tps=2,
        onHit = function(_ENV)
            local direction = to(x,y,px,py)
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
            sfx(10)
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
                    col = 15,
                    onPlayer = function(_ENV)
                        playerHit(to(x,y,px,py))
                    end,
                    draw = function(_ENV)
                        circfill(x+randDec(-0.5,0.5),y+randDec(-0.5,0.5),size,col)
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
            local dir = to(x,y,px,py)
            local playerDist = dist(x, y, px, py)

            if state < 0 then
                state += 1
                return mdir(0,dir)
            end

            if state > 0 then
                moveSpeed += 0.2
                if outxy(x,y,size) then 
                    onPlayer(_ENV)
                    moveSpeed = 0
                end
                return mdir(moveSpeed,moveDir)
            end

            if not outxy(x,y,size) then 
                moveDir = dir
                state = 1
                moveSpeed = 0
            else
                dir = to(x,y,64,64)
            end

            return mdir(mag,dir)
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
                        playerHit(to(x,y,px,py), 7)
                    end,
                    draw = function(_ENV)
                        circ(x,y,size,col)
                        circ(x,y,size + 1,col)
                        circ(x,y,size + 2,col)
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
        dmg=3.5,
        moveDirection = nil,
        behavior = function(_ENV)
            local mag = 1
            local dir = to(x,y,px,py)
            local playerDist = dist(x, y, px, py)
            if state > 0 then
                if outxy(x,y,size) and push.mag <= 0 then 
                    moveDir = dir
                    sfx(9)
                end
                return mdir(mag,moveDir)
            end

            moveDirection = dir
            state = 1

            return mdir(mag,dir)
        end,
        onHit = function(_ENV)
            moveDirection = (0.5 - moveDirection) % 1
        end,
        onPlayer = function(_ENV)
            if state > 0 then
                local a = moveDirection
                local n = to(x,y,px,py)
                moveDirection = a - 2 * dot(a, n) * n
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
            local dir = to(x,y,px,py)
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
                        playerHit(to(x,y,px,py))
                        dead = true
                    end,
                    onWeapon = function(_ENV,h)
                        if (isSwing()) dead = true
                    end
                }, projectiles)
            end
            return mdir(0,dir)
        end,
    },
}

function spawnEnemy(count, typeTbl)
    if typeTbl == 1 then
        typeTbl = {2}--{15}
    elseif typeTbl == 2 then
        typeTbl = {4,5,6}
    elseif typeTbl == 3 then
        typeTbl = {7,8,9}
    elseif typeTbl == 4 then
        typeTbl = {10,11,12}
    end

    count = count or 1
    for i=1,count do
        t = rnd(typeTbl)
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
            addColor(e.col, 1)
            deathParticle(e)
            sfx(2)
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