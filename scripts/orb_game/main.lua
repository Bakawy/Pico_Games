do 

gravity = 0.2

function _init()
    poke(0x5f5c, 255)
end

function _update60()
    cls(0)
    updatePlayer()
    updateOrb()
    updateAttacks() 
end

function _draw()
    map()
    drawOrb()
    drawPlayer()
    print(flr(stat(1)*100).."% cpu", 1, 1, 12)
end

end