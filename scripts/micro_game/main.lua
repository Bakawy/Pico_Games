cursorX, cursorY, enemies, entities, particles, units, projectiles, ghosts, frame, leftMouseDown, rightMouseDown = 64, 64, {}, {}, {}, {}, {}, {}, 0, false, false

function _init()
    poke(0x5f2d, 0x1 + 0x2)
    poke(0x5f5c, 255)
    --[[
    Weapon:new({
        onRelease=throw, 
        col = 2,
        update_systems = {update_motion},
        killCondition = move_kill,
    })
    Weapon:new({
        sprite = 8,
        r = 16/sqrt(2),
        onRelease = spin,
        update_systems = {update_spin},
    })
    Weapon:new({
        progress = 0,
        r = 12,
        onShake = function(_ENV)
            charge(_ENV, 0.2)
        end,
        onProgressFull = function(_ENV)
            progress -= 1/duration
        end,
        killCondition = charged_kill,
    })
    ]]
    Unit:new({systems={sword}})
    Unit:new({systems={slingShot}})
    Unit:new({systems={grabber}})
    Unit:new({systems={mage}})

    Projectile:new({
        col = 12,
        r = 10,
        update = function(_ENV)
            local angle = frame/3000
            x = 64 + (64 - r) * cos(angle)
            y = 64 + (64 - r) * sin(angle)
        end,
        onUnit = function(_ENV, unit)
            if (not unit.magic) return
            unit.progress += unit.magic
        end,
    })
end 

function _update60()
    cls(7)
    updateCursor()
    
    while #enemies < 4 and frame % 180 == 0 do
        Enemy:new()
    end

    for e in all(entities) do 
        local _ENV = e
        update(_ENV)

        if onEnemy then
            for enemy in all(enemies) do 
                if (e != enemy and dist(x, y, enemy.x, enemy.y) < r + enemy.r) onEnemy(_ENV, enemy)
            end
        end

        if onGhost then
            for ghost in all(ghosts) do 
                if (e != ghost and dist(x, y, ghost.x, ghost.y) < r + ghost.r) onGhost(_ENV, ghost)
            end
        end

        if onUnit then
            for unit in all(units) do 
                if (e != unit and dist(x, y, unit.x, unit.y) < r + unit.r) onUnit(_ENV, unit)
            end
        end
    end
    frame += 1
end

function _draw()
    for e in all(entities) do 
        e:draw()
    end
    drawCursor()
end

Class = setmetatable({
    new = function(_ENV, tbl, toTbl)
        tbl=tbl or {}
        
        setmetatable(tbl,{
            __index=_ENV
        })

        tbl.tbl = toTbl

        if not toTbl and tbl.init then
            tbl:init()
        end

        return tbl
    end,
    
    init=function()end
},{__index=_ENV})

Entity = Class:new({
    x = 64,
    y = 64,
    layer = 0,
    r = 0,
    spawnFrame = frame,
}, true)

function Entity:init()
    add(entities, self)
    add(self.tbl, self)
    qsort(entities, function(a, b) return a.layer - b.layer end)
end

function Entity:draw() end
function Entity:update() end

function delete(_ENV)
    for tbl in all({entities, enemies, particles, units, projectiles, ghosts}) do 
        del(tbl, _ENV)
    end
end

function getEntitiesCirc(x, y, radius, tbl, condition)
    condition, tbl = condition or function () return true end, tbl or entities
    local output = {}
    for e in all(tbl) do 
        if (condition(e) and dist(e.x, e.y, x, y) < e.r + radius) add(output, e)
    end
    return output
end

function clampToScreen(_ENV)
    x = mid(r, x, 128 - r)
    y = mid(r, y, 128 - r)
end