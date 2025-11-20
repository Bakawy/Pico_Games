Ghost = Entity:new({
    speed = 0.1,
    sprite = 34,
    layer = 100,
    r = 2,
}, ghosts)

function Ghost.update(_ENV)
    local dir = to(x, y, cursorX, cursorY)
    x += speed * cos(dir)
    y += speed * sin(dir)

    if (dist(x, y, cursorX, cursorY) < r) run()
end

function Ghost.draw(_ENV)
    local period = 30 * 0.25/speed
    sspr(sprite % 16 * 8, sprite \ 16 * 8, 8, 8, x - r * 2, y - r * 2, r * 4, r * 4, (frame - spawnFrame) % period < period/2)
    --spr(sprite, x - 4, y - 4, 1, 1, (frame - spawnFrame) % period < period/2)
end

function Ghost.onGhost(_ENV, ghost)
    speed += ghost.speed
    r = dist(ghost.r, r, 0, 0)
    delete(ghost)
end