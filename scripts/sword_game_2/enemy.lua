Enemy = Class:new({
    x = 64,
    y = 64,
    r = 4,
    velmag = 0,
    veldir = 0,
    timer = 0,

    behavior = function(_ENV)
        if dist(x, y, targetX, targetY) > r then 
            x, y = colMove(x, y, 2 * r/sqrt(2), 0.25, to(x, y, targetX, targetY))
        end 
    end,
    ragdoll = function(_ENV)
        x, y = colMove(x, y, 2 * r/sqrt(2), velmag, veldir)

        local frict = 0.1
        velmag -= frict * sgn(velmag)
        if (within(velmag, -frict, frict)) velmag = 0

        if (timer >= 0) update = behavior
    end,

    update = function(_ENV)
        targetX, targetY = x,y
        update = behavior
    end,
    draw = function(_ENV)
        spr(16, x - 4, y - 4)
    end,

    hit = function(_ENV, dir)
        timer, update, velmag, veldir = 
            -10,
            ragdoll,
            2,
            dir
    end,


})
enemies = {}

function updateEnemies()
    for e in all(enemies) do 
        e:update()
        e.timer += 1
    end
end

function drawEnemies()
    for e in all(enemies) do 
        e:draw()
    end
end