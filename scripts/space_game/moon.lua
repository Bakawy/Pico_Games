local orbitProgress = 0
local moons = {
    {
        x = 64,
        y = 64,
        sprite = 2,
        orbitRadius = 40,
        orbitPeriod = 300,
        startAngle = 0.75,
        sizeMin = 8,
        sizeMax = 16,
        front = true,
        accuracyRadius = 8,
    },
}
local jupiterX = 64
local jupiterY = 64

local function drawMoon(moon)
    sspr((moon.sprite % 16) * 8, flr(moon.sprite / 8), 8, 8, moon.x - moon.size / 2, moon.y - moon.size / 2, moon.size, moon.size)
    circ(moon.x, moon.y, moon.accuracyRadius + moon.size/2, 8)
end

function updateMoons()
    jupiterY = 64 + sin(orbitProgress / 500) * 20
    jupiterX = 64 + cos(orbitProgress / 500) * 20
    for moon in all(moons) do
        local angle = (orbitProgress / moon.orbitPeriod) % 1 + moon.startAngle
        moon.front = (angle % 1) > 0.5 
        moon.x = jupiterX + cos(angle) * moon.orbitRadius
        moon.y = jupiterY
        moon.size = moon.sizeMin + (moon.sizeMax - moon.sizeMin) * ((sin(angle) + 1) / 2) * ((sin(angle) + 1) / 2)
    end
    orbitProgress += 1
end

function drawMoons()
    for moon in all(moons) do
        if not moon.front then
            drawMoon(moon)
        end
        spr(33, jupiterX - 8, jupiterY - 8, 2, 2)
        if moon.front then
            drawMoon(moon)
        end
    end
end