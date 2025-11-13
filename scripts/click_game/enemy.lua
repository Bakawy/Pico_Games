Enemy = Entity:new({
    x = 0,
    speed = 0.25,
    r = 5.65685424949,--sqrt(2 * (8/2)^2)
    sprite = 2,
}, enemies)

function Enemy.init(_ENV)
    Entity.init(_ENV)
    y, speed = randDec(0, 128), numVary(speed, 0.05)
end

function Enemy.draw(_ENV)
    local period = 30 * 0.25/speed
    spr(sprite, x - 4, y - 4, 1, 1, (frame - spawnFrame) % period < period/2)
end

function Enemy.update(_ENV)
    x += speed
end

function Enemy.onClick(_ENV)
    dead = true
    local dir = randDec(0, 0.5)
    Particle:new({
        x = x,
        y = y,
        dx = 2 * cos(dir),
        dy = 2 * sin(dir),
        ddy = 0.1,
        sprite = sprite + 16,
    })
end