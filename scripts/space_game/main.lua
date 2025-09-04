function _init()
    poke(0x5f2d, 0x1)
    pal({
        [1]=-15,
    }, 1)
end

function _update60()
    cls(1)
    updateCursor()
end

function _draw()
    drawCursor()
    print(stat(32).." "..stat(33), 0, 0, 2)
    print(stat(80).." "..stat(81).." "..stat(82).." "..stat(83).." "..stat(84).." "..stat(85))
end