do 

gravity = 0.2
frame = 0

function _init()
    poke(0x5f5c, 255)
    Enemy:new({x=40,y=64}, enemies)
    Enemy:new({x=32,y=64}, enemies)
    Enemy:new({x=24,y=64}, enemies)
    for i=1, 200 do
        --Bullet:new({x=randint(0,128),y=randint(0,128),r=3,col=randint(1,15),triAngle=rnd(),dx=randDec(-0.1,0.1),dy=randDec(-0.1,0.1)}, bullets)
    end
    initNav()
end

function _update60()
    cls(0)
    map()

    updatePlayer()
    updateAttacks()
    updateOrb()
    updateEnemies()
    updateBullets()
    updateParticles()
    frame += 1
end

function _draw()
    drawOrb()
    drawPlayer()
    drawBullets()
    drawEnemies()
    drawParticles()
    print(flr(stat(1)*100).."% cpu", 1, 1, 12)
end

local function generateLevel()
    
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