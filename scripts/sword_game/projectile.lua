do

local px, py, pr

Projectile = Class:new({
    x = 64,
    y = 64,
    dir = 0,
    speed = 0,
    range = nil,
    traveled = 0,
    len = 1000000,
    size = 2,
    dsize = 0,
    col = 0,
    sprite = nil,
    --dead = false,
    --onWeapon = nil,
    --onEnemy = nil,
    --onDead = nil,
    --onPlayer = nil,
    move = function(_ENV) 
        x += speed * cos(dir)
        y += speed * sin(dir)
        size += dsize
        if range then
            traveled += speed
            if (traveled > range) dead = true
        end
        if len then
            len -= 1
            if (len <= 0) dead = true
        end
        if x != mid(-size,x,128+size) or y != mid(-size,y,128+size) then
            dead = true
        end
    end,
    collide = function(_ENV) 
        if onEnemy then
            for e in all(enemies) do
                if e.spawn <= 0 and dist(x, y, e.x, e.y) < size + e.size then
                    onEnemy(_ENV, e)
                end
            end
        end
        if onPlayer then
            if dist(x, y, px, py) < size + pr then
                onPlayer(_ENV)
            end
        end
        if onWeapon then
            local hitbox = getHitbox()
            if dist(x, y, hitbox.x, hitbox.y) < size + hitbox.r then
                onWeapon(_ENV, hitbox)
            end
        end
    end,
    draw = function(_ENV)
        if sprite then
            local halfSize = size
            local sx, sy = (sprite % 16) * 8, flr(sprite / 16) * 8
            sspr(sx, sy, 8, 8, x - halfSize, y - halfSize, size * 2, size * 2)
        else
            circfill(x, y, size, col)
        end
    end,
})
projectiles = {}

function updateProjectiles()
    px, py, pr = getPlayerPos()
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