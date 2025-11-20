Projectile = Entity:new({
    layer = -1,
    dmg = 0,
    hurtEnemy = false,
    show = true,
    velocity = {0, 0},
    col = 2,
    range = 32767,
    len = 32767,
}, projectiles)

function Projectile.update(_ENV)
    local mag, dir = velocity[1], velocity[2]
    x += mag * cos(dir)
    y += mag * sin(dir)
    
    range -= mag
    len -= 1
    if (range < 0 or len < 0) delete(_ENV)
end

function Projectile.draw(_ENV)
    if (not show) return
    circfill(x, y, r, col)
end

function Projectile.onEnemy(_ENV, enemy)
    if (not hurtEnemy) return

    enemy:kill()
end