do 

local shieldX, shieldY, shieldR = getShieldPos()
local playerX, playerY, playerR = getPlayerPos()

Projectile = Class:new({
    col = 0,
    speed = 0,
    dSpeed = 0,
    maxSpeed = 0,
    dir = 0,
    radius = 1,
    x = 64,
    y = 64,
    dead = false,
    knocked = false,
    checkShield = function(_ENV)
        local shieldDist = dist(x, y, shieldX, shieldY)
        if shieldDist < radius + shieldR and not knocked then
            --dead = true
            dir -= 0.5
            speed *= 2
            knocked = true
            col = 4
        end
    end,
    checkPlayer = function(_ENV)
        if dist(x, y, playerX, playerY) < radius + playerR and not knocked and speed == maxSpeed then
            dead = true
            hurtPlayer()
        end
    end,
    update = function(_ENV)
        speed = min(speed + dSpeed, maxSpeed)

        x += speed * cos(dir)
        y += speed * sin(dir)
        checkShield(_ENV)
        checkPlayer(_ENV)

        if x != mid(-bounds, x, bounds) or y != mid(-bounds, y, bounds) then
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