function _init()
end

function _update60()
    cls(7)
    updatePlayer()
end

function _draw()
    drawPlayer()
    print(flr(stat(1)*100).."% ram", 0, 0, 0)
end

