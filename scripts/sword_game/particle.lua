do 
Particle = Class:new({
    len = 0,
    r = 0,
    dr = 0,
    ddr = 0,
    x = 64,
    dx = 0,
    ddx = 0,
    y = 64,
    dy = 64,
    ddy = 0,
    col = 0,
    update = function(_ENV)
        dx += ddx
        dy += ddy
        dr += ddr 
        x += dx
        y += dy
        r += dr
        len -= 1
    end,
    draw = function(_ENV)
        circfill(x, y, r, col)
    end,
})
particles = {}

function updateParticles()
    for p in all(particles) do
        p:update()
        if (p.len <= 0) del(particles, p)
    end
end

function drawParticles()
    for p in all(particles) do
        p:draw()
    end
end

end