do

L = {5, 1}
R = {3, 1}
U = {4, 1}
D = {0, 1}
O = {4, 0}
X = {5, 0}
score = 0
global = _ENV
local function drawDebug()
    print(score, 1, 1, 0)
    print(#enemies)
end

function _init()
    poke(0x5f2d, 0x1 + 0x2)
    palt(0, false)
    palt(11, true)

    Enemy:new({x=16, y=16}, enemies)
end

function _update60()
    cls(7)
    updateCursor()
    updatePlayer()
    updateEnemies()
end

function _draw()
    drawEnemies()
    drawPlayer()
    drawCursor()
    drawDebug()
end

function ttn(input)--table btn
    --print(input[1].." "..input[2])
    --print(btn(input[1], input[2]))
    --print(btn(0, 0))
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

        add(toTbl, tbl)
        return tbl
    end,
    
    init=function()end
},{__index=_ENV})

end