do

local player = {}
local px, py, pr = 64, 64, 8

Projectile = Class:new({
    x = 64,
    y = 64,
    dir = 0,
    speed = 0,
    range = nil,
    traveled = 0,
    len = nil,
    r = 2,
    dr = 0,
    col = 0,
    sprite = nil,
    dead = false,
    onEnemy = nil,
    onDead = nil,
    onPlayer = nil,
    move = function(_ENV) 
        x += speed * cos(dir)
        y += speed * sin(dir)
        r += dr
        if range then
            traveled += speed
            if (traveled > range) dead = true
        end
        if len then
            len -= 1
            if (len <= 0) dead = true
        end
        if x != mid(-r,x,128+r) or y != mid(-r,y,128+r) then
            dead = true
        end
    end,
    collide = function(_ENV) 
        --[[
        if onEnemy then
            for e in all(enemies) do
                if dist(x, y, e.x, e.y) < r + e.r then
                    onEnemy(_ENV, e)
                end
            end
        end
        ]]
        if onPlayer then
            if dist(x, y, px, py) < r + pr then
                onPlayer(_ENV)
            end
        end
    end,
    draw = function(_ENV)
        if sprite then
            local halfSize = r
            local sx, sy = (sprite % 16) * 8, flr(sprite / 16) * 8
            sspr(sx, sy, 8, 8, x - halfSize, y - halfSize, r * 2, r * 2)
        else
            circfill(x, y, r, col)
        end
    end,
})
projectiles = {}

function updateProjectiles()
    player = getPlayerState()
    px, py, pr = player.x, player.y, player.r
    for p in all(projectiles) do
        p:move()
        p:collide()
        if p.dead then 
            if (p.onDead) p:onDead()
            del(projectiles, p) 
        end
    end
end

function drawProjectiles()
    for p in all(projectiles) do
        p:draw()
    end
end

end