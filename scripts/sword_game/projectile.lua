do

Projectile = Class:new({
    x = 64,
    y = 64,
    dir = 0,
    speed = 1,
    range = 64,
    traveled = 0,
    size = 2,
    color = 0,
    sprite = nil,
    dead = false,
    move = function(_ENV) 
        x += speed * cos(dir)
        y += speed * sin(dir)
        traveled += speed
        if (traveled > range) dead = true
    end,
    collide = function(_ENV) 
        for e in all(enemies) do
            if dist(x, y, e.x, e.y) < size + e.size then
                onEnemy(_ENV, e)
            end
        end
    end,
    draw = function(_ENV)
        if sprite then
            local halfSize = size
            local sx, sy = (sprite % 16) * 8, flr(sprite / 16) * 8
            sspr(sx, sy, 8, 8, x - halfSize, y - halfSize, size * 2, size * 2)
        else
            circfill(x, y, size, color)
        end
    end,
    onEnemy = function() end,
    onDead = function () end,
})
projectiles = {}

function updateProjectiles()
    for p in all(projectiles) do
        p:move()
        p:collide()
        if p.dead then 
            p:onDead()
            del(projectiles, p) 
        end
    end
end

function drawProjectiles()
    for p in all(projectiles) do
        p:draw()
    end
end

end