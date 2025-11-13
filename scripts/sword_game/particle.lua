do 
Particle = Class:new({
    len = 0,
    r = 0,
    dr = 0,
    x = 64,
    dx = 0,
    ddx = 0,
    y = 64,
    dy = 0,
    ddy = 0,
    col = 0,
    --spawnBG = false,
    update = function(_ENV)
        dx += ddx
        dy += ddy
        x += dx
        y += dy
        r += dr
        len -= 1

        if ddx >= 0 and dx >= 0 and x - r > 128 then
            len = 0
        elseif ddx <= 0 and dx <= 0 and x + r < 0 then
            len = 0
        end
        if ddy >= 0 and dy >= 0 and y - r > 128 then
            len = 0
        elseif ddy <= 0 and dy <= 0 and y + r < 0 then
            len = 0
        end
    end,
    draw = function(_ENV)
        circfill(x, y, r, col)
    end,
})
particles, bgParticles = {}, {}

function updateParticles()
    for p in all(particles) do
        p:update()
        if p.len <= 0 then 
            if p.spawnBG then
                --add(bgParticles, p)
                poke(0x5f55, 0xa0)
                p:draw()
                poke(0x5f55, 0x80)
            end
            del(particles, p)
        end
    end
end

function drawParticles()
    for p in all(particles) do
        p:draw()
    end
end

function drawBGParticles()
    for p in all(bgParticles) do
        p:draw()
    end
end

end