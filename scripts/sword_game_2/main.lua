L, R, U, D, X, frame = {5, 1}, {3, 1}, {4, 1}, {0, 1}, {5, 0}, 0

function _init()
    poke(0x5f2d, 0x1 + 0x2)
    poke(0x5f5c, 255)
    pal({
        [0] = -1,
        0,
        5,
        7,
        8,
        10,
        -4,
        -7,
        2,
        -5,
        14,
        -9,
        12,
        -13,
        -6,
        3,
    }, 1) 

    local c = 1
    for i=1,c do
        local a = i/c
        Ball:new({
            x = 64 + 32 * cos(a),
            y = 64 + 32 * sin(a),
        }, balls)
    end

    Enemy:new({
        x = 64,
        y = 32,
    }, enemies)
end

function _update60()
    cls()
    updateCursor()
    updatePlayer()
    updateBalls()
    updateEnemies()

    frame += 1
end

function _draw()
    drawBalls()
    drawEnemies()
    drawPlayer()

    map(1, 1)
    drawCursor()
end

function ttn(input)--table btn
    return btn(input[1], input[2])
end
function ttnp(input)
    return btnp(input[1], input[2])
end

Class = setmetatable({
    new = function(_ENV,tbl, toTbl)
        tbl=tbl or {}
        
        setmetatable(tbl,{
            __index=_ENV
        })

        if (toTbl) add(toTbl, tbl)
        init(_ENV)
        return tbl
    end,
    
    init=function()end
},{__index=_ENV})