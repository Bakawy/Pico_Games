Unit = Entity:new({
    layer = 1,
    r = 4,
    sprite = 3,
    facing = false,
    weaponSprite = 5,
    --dragged = nil,
    systems = {},

    --target = nil,
    dist_moved = 0,

    move_speed = 0.25,
    move_dist = 250,
    projectile_speed = 1,
    quantity = 1,
    size = 14,
    damage = 1,

}, units)

function run_systems(_ENV, type)
    for s in all(systems) do
        if (s[type]) s[type](_ENV)
    end
end

function Unit.init(_ENV)
    x, y, holding = randDec(56, 72), randDec(56, 72), {}
    run_systems(_ENV, "init")
    Entity.init(_ENV)
end

function Unit.update(_ENV)
    if target then
        x += move_speed * target[1]
        y += move_speed * target[2]
        facing = sgn(target[1]) == 1
        dist_moved += move_speed

        if (x - r < 0 or x + r > 128) target[1] *= -1
        if (y - r < 0 or y + r > 128) target[2] *= -1

        if dist_moved >= move_dist then 
            target = false
        end
    end

    if dragged and not leftMouseDown then
        local dir = to(dragged[1] + x, dragged[2] + y, cursorX, cursorY)
        target, dist_moved, dragged = {cos(dir), sin(dir)}, 0, nil
    end
    run_systems(_ENV, "update")
end

function Unit.onClick(_ENV)
    if (target) target = nil
    dragged = {cursorX - x, cursorY - y}
end

function Unit.draw(_ENV)
    local cycle = (frame - spawnFrame) \ 20 % 2 * 16
    if (target) cycle += 32
    if (#holding > 0) cycle += 64

    if not (target or #holding > 0) then
        local wx, wy = x - 4 + (facing and 8 or 0), y + (cycle == 0 and 0 or 1)
        spr(weaponSprite, wx - 4, wy - 4, 1, 1, facing)
    end

    spr(sprite + cycle, x - 4, y - 4, 1, 1, facing)

    if dragged then
        line(dragged[1] + x, dragged[2] + y, cursorX, cursorY, 6)
    end

    if #holding > 0 then
        local hy = y - 12
        for item in all(holding) do 
            spr(item.sprite, x - 4, hy + (cycle % 32 == 0 and 0 or 1), 1, 1, (frame - item.spawnFrame) \ 5 % 2 == 0, true)
            hy -= 8
        end
    end

    if progress then
        rectfill(x - r, y - r - 4, x + r, y - r - 2, 0)
        line(x - r + 1, y - r - 3, lerp(x - r + 1, x + r - 1, progress), y - r - 3, 3)
    end

    run_systems(_ENV, "draw")
end

sword = {
    init = function(_ENV)
        radius = sqrt(size) * 4
        hr = 0.3 * radius
    end,
    update = function(_ENV)
        if (not target) return
        angle = projectile_speed * frame/60
        for i = 0, quantity do
            local a = angle + i / quantity
            for e in all(getEntitiesCirc(x + (radius-hr) * cos(a), y + (radius-hr) * sin(a), hr, enemies)) do 
                e:kill()
            end
        end
    end,
    draw = function(_ENV)
        if (not target) return
        for i = 0, quantity do
            local a = angle + i / quantity
            --circfill(x + (radius-hr) * cos(angle), y + (radius-hr) * sin(angle), hr, 2)
            rspr(32, 0, 8, 8, a - 0.25, x + radius/2 * cos(a), y + radius/2 * sin(a), radius, radius)
        end
    end,
}
slingShot = {
    init = function(_ENV)
        weaponSprite, collectible = 21, {}
    end,
    update = function(_ENV)
        while #collectible < 7 do 
            add(collectible, Projectile:new({
                r = size / 7,
                x = randDec(2, 126),
                y = randDec(2, 126),
                col = 5,
                from = _ENV,
                onUnit = function(_ENV, unit)
                    if (unit != from) return
                    --unit.target = nil
                    for i=1, from.quantity do
                        local enemy = rnd(enemies)
                        if (not enemy) goto continue
                        Projectile:new({
                            x = x,
                            y = y,
                            r = r,
                            col = col,
                            range = 181,
                            velocity = {1.5 * from.projectile_speed, to(x, y, enemy.x, enemy.y)},
                            onEnemy = function(_ENV, enemy)
                                enemy:kill()
                                delete(_ENV)
                            end,
                        })
                        ::continue::
                    end
                    del(from.collectible, _ENV)
                    delete(_ENV)
                end,
            }))
        end
    end,
}
grabber = {
    init = function(_ENV)
        onEnemy = function(_ENV, enemy)
            if (#holding >= quantity or not target) return
            add(holding, enemy)
            --target = nil
            enemy:kill(true)
            move_speed = mid(base_speed, move_speed/2 * (1 + damage/20), 0.025)
        end
        weaponSprite, base_speed = 37, move_speed
    end,
    update = function(_ENV)
        if holding then
            if (x - r < 0 or x + r > 128) holding = {}
            if (y - r < 0 or y + r > 128) holding = {}
            if (#holding == 0) move_speed = base_speed
        end
        
    end,
}
mage = {
    init = function(_ENV)
        progress, weaponSprite = 0, 53
    end,
    update = function(_ENV)
        progress += 0.01
    end,
}