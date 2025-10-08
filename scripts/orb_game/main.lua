do 

gravity = 0.2

function _init()
    poke(0x5f5c, 255)
    Enemy:new({x=32,y=64}, enemies)
end

function _update60()
    cls(0)
    map()

    updatePlayer()
    updateAttacks()
    updateOrb()
    updateEnemies()
end

function _draw()
    drawEnemies()
    drawOrb()
    drawPlayer()
    print(flr(stat(1)*100).."% cpu", 1, 1, 12)
end

Class = setmetatable({
    new = function(_ENV,tbl, toTbl)
        tbl=tbl or {}
        
        setmetatable(tbl,{
            __index=_ENV
        })

        if (toTbl) add(toTbl, tbl)
        return tbl
    end,
    
    init=function()end
},{__index=_ENV})

end