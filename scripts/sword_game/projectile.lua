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
    onEnemy = function() end,
})
projectiles = {}

function updateProjectiles()
    for p in all(projectiles) do
        p:move()
        p:collide()
        if (p.dead) del(projectiles, p)
    end
end

function drawProjectiles()
    for p in all(projectiles) do
        circfill(p.x, p.y, p.size, p.color)
    end
end

end