Unit = Entity:new({
    layer = 1,
    r = 4,
    sprite = 3,
    facing = false,
    --dragged = nil,
    systems = {},

    --target = nil,
    dist_moved = 0,

    move_speed = 0.25,
    move_dist = 250,
    projectile_speed = 1,
    quantity = 1,
    size = 14,

}, units)

function run_systems(_ENV, type)
    for s in all(systems) do
        s[type](_ENV)
    end
end

function Unit.init(_ENV)
    x, y = randDec(56, 72), randDec(56, 72)
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
        local dir = to(x, y, cursorX, cursorY)
        target, dist_moved, dragged = {cos(dir), sin(dir)}, 0, nil
    end
    run_systems(_ENV, "update")
end

function Unit.onClick(_ENV)
    if (target) return
    dragged = {cursorX - x, cursorY - y}
end

function Unit.draw(_ENV)
    local cycle = (frame - spawnFrame) \ 20 % 2 * 16
    if (target) cycle += 32
    spr(sprite + cycle, x - 4, y - 4, 1, 1, facing)

    if dragged then
        line(dragged[1] + x, dragged[2] + y, cursorX, cursorY, 6)
    end
    run_systems(_ENV, "draw")
end

sword = {
    update = function(_ENV)
        if (not target) return
        for i = 0, quantity do
            local angle, radius, hr = projectile_speed * frame/60 + i / quantity, size, 0.3 * size
            for e in all(getEntitiesCirc(x + (radius-hr) * cos(angle), y + (radius-hr) * sin(angle), hr, enemies)) do 
                e:kill()
            end
        end
    end,
    draw = function(_ENV)
        if (not target) return
        for i = 0, quantity do
            local angle, radius, hr = projectile_speed * frame/60 + i / quantity, size, 0.3 * size
            --circfill(x + (radius-hr) * cos(angle), y + (radius-hr) * sin(angle), hr, 2)
            rspr(32, 0, 8, 8, angle - 0.25, x + radius/2 * cos(angle), y + radius/2 * sin(angle), radius, radius)
        end
    end,
}