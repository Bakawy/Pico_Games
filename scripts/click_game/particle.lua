Particle = Entity:new({
    len = 32767,
    dx = 0,
    dy = 0,
    ddy = 0,
    col = 0,
    init = Entity.init,
    --sprite = nil
}, particles)

function Particle.update(_ENV)
    dy += ddy
    x += dx
    y += dy

    if x - r > 128 or x + r < 0 then
        len = 0
    elseif y - r > 128 or y + r < 0 then
        len = 0
    end

    if (frame - spawnFrame > len) dead = true
end

function Particle.draw(_ENV)
    if sprite then
        spr(sprite, x - 4, y - 4)
    else
        circfill(x, y, r, col)
    end
end