do

Enemy = Class:new({
    x=64,
    y=64,
    sizeRadius=4,
    scoreRadius=12,
    dead=false,
    fireRate = 1,
    fireTimer = 0,
    checkPlayer=function(_ENV)
        local px, py, pr = getPlayerPos()
        local playerDist =  dist(x, y, px, py)
        if playerDist < pr + sizeRadius + scoreRadius then
            scoreRadius = max(0, playerDist - (pr + sizeRadius))

            if scoreRadius < 3 then
                global.score += 1
                dead = true
            end
        end
    end,
    update=function(_ENV)
        checkPlayer(_ENV)
        if fireTimer <= 0 then
            fireTimer = 60/fireRate
            shoot(_ENV)
        end
        fireTimer -= 1
    end,
    draw=function(_ENV) 
        circfill(x, y, sizeRadius, 8)
        circ(x, y, sizeRadius + scoreRadius, 8)
    end,
    shoot=function(_ENV)
        local px, py = getPlayerPos()
        local dir = atan2(px - x, py - y)
        add(projectiles, Projectile:new({
            x = x,
            y = y,
            speed = 1,
            dir = dir,
            radius = 3,
            col = 9,
        }))
    end,
})
enemies = {}

function updateEnemies()
    for e in all(enemies) do
        e:update()
        if (e.dead) del(enemies, e)
    end
end

function drawEnemies()
    for e in all(enemies) do
        e:draw()
    end
end

end