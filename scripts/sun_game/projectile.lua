do 

local shieldX, shieldY, shieldR = getShieldPos()
local playerX, playerY = getPlayerPos()

Projectile = Class:new({
    col = 0,
    speed = 0,
    dir = 0,
    radius = 1,
    x = 64,
    y = 64,
    dead = false,
    checkShield = function(_ENV)
        local shieldDist = dist(x, y, shieldX, shieldY)
        if shieldDist < radius + shieldR then
            --dead = true
            dir -= 0.5
            speed *= 2
        end
    end,
    update = function(_ENV)
        x += speed * cos(dir)
        y += speed * sin(dir)
        checkShield(_ENV)

        local playerDist = dist(x, y, playerX, playerY)
        debugPrint(playerDist, 64)
        if playerDist > 362 then
            dead = true
        end
    end,
    draw = function(_ENV)
        circfill(x, y, radius, col)
    end

})
projectiles = {}

function updateProjectiles()
    shieldX, shieldY, shieldR = getShieldPos()
    playerX, playerY = getPlayerPos()
    for p in all(projectiles) do
        p:update()
        if (p.dead) del(projectiles, p)
    end
end

function drawProjectiles()
    for p in all(projectiles) do
        p:draw()
    end
end

end