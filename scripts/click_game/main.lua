cursorX, cursorY, enemies, entities, particles, frame = 64, 64, {}, {}, {}, 0

function _init()
    poke(0x5f2d, 0x1 + 0x2)
    for i=1,5 do Enemy:new() end 
end 

function _update60()
    cls(7)
    updateCursor()
    for e in all(entities) do 
        e:update()
        if e.dead then 
            del(entities, e)
            del(enemies, e)
            del(particles, e)
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