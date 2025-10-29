do 

cam = {x=64, y=64}

function _init()
    poke(0x5f2d, 0x1 + 0x2)
    poke(0x5f5c, 255)
end 

function _update60()
    cls(0)
    updateCursor()
    updatePlayer()
    updateGun()
    updateProjectiles()
end 

function _draw()
    drawProjectiles()
    drawPlayer()
    drawGun()
    drawCursor()
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