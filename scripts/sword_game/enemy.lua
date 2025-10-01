do

local spawnDuration = 60

local function checkWeapon(enemy)

    local function vnorm(x,y)
        local m = sqrt(x*x + y*y)
        if (m < 0.0001) return 0,0,0
        return x/m, y/m, m
    end

    local hitboxes, wv = getHitbox()
    local px, py = getPlayerPos()
    for h in all(hitboxes) do
        if (isSwing() and dist(enemy.x, enemy.y, h.x, h.y) < enemy.size + h.r) then
            local rx, ry = h.x - px, h.y - py
            local rlen = sqrt(rx*rx + ry*ry)

            local dir = -sgn(wv)  -- PICO-8 has sgn()
            local tx, ty = -ry*dir, rx*dir
            local ux, uy, _ = vnorm(tx, ty)

            local linearSpeed = abs(wv) * rlen

            enemy.hit = atan2(ux, uy) + randDec(-0.07, 0.07)
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
    update = function(_ENV) 
        if spawn < spawnDuration then
            spawn += 1
            return
        end

        move(_ENV)

        if noHit > 0 then
            noHit -= 1
        else
            checkWeapon(_ENV)
        end

        checkPlayerCol(_ENV)

        if hit then
            local a, b, dmg = getHitbox()
            push = {mag=dmg * kb * def, dir=hit}
            hit = false
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
        local px, py = getPlayerPos()
        local dir = atan2(px - x, py - y)
        x += cos(dir) * speed * deltaTime
        y += sin(dir) * speed * deltaTime

        if x + size < 0 or x - size > 128 or y + size < 0 or y - size > 128 then
            dead = true
        end
    end,
    checkPlayerCol = function(_ENV)

        local px, py, pr = getPlayerPos()
        if dist(x, y, px, py) < size + pr then
            playerHit(atan2(px - x, py - y))
            stun = 15
        end
    end,
})
enemies = {}

function spawnEnemy(count)
    count = count or 1
    for i=1,count do
        local t = rnd({4, 5, 6})
        local tTable = {
            [4] = {
                dmg=10,
                speed=0.3,
                def=1,
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
        Enemy:new({
            x=randDec(8, 120), 
            y=randDec(8, 120), 
            col=t,
            dmg=tTable[t].dmg,
            speed=tTable[t].speed,
            def=tTable[t].def,
        }, enemies)
    end
end

function updateEnemies()
    for e in all(enemies) do
        e:update()
        if (e.dead) then
            addColor(e.col, 1)
            del(enemies, e)
            spawnEnemy()
        end
    end
end

function drawEnemies()
    for e in all(enemies) do
        if e.spawn < spawnDuration then
            spr(2, e.x - 4, e.y - 4)
        else
            circfill(e.x, e.y, e.size, e.col)
        end
    end
end

end