do 

cam = {x=64, y=64}
mapData = {w=32,h=16}

function _init()
    poke(0x5f2d, 0x1 + 0x2)
    poke(0x5f5c, 255)
    pal({[11]=-6}, 1)
    spawnEnemy()
end 

function _update60()

    cls(0)
    map()
    updateCursor()
    updatePlayer()
    updateGun()
    updateEnemies()
    updateProjectiles()

    runRoutines()

    local player = getPlayerState()
    cam.x, cam.y = player.x, player.y
    cam.x = mid(64, cam.x, mapData.w * 8 - 64)
    cam.y = mid(64, cam.y, mapData.h * 8 - 64)
    camera(cam.x - 64, cam.y - 64)
end 

function _draw()
    drawProjectiles()
    drawPlayer()
    drawGun()
    drawEnemies()
    drawCursor()

    print(flr(stat(1)*100).."% cpu", 1, 1, 12)
    rect(-1, -1, mapData.w*8, mapData.h*8, 7)
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