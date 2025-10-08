do

L = {5, 1}
R = {3, 1}
U = {4, 1}
D = {0, 1}
O = {4, 0}
X = {5, 0}
score = 0
global = _ENV
local cam = {x=64, y=64}
local function drawDebug()
    debugPrint(flr(stat(1)*100).."% cpu", 1, 1, 12)
    debugPrint(score)
    debugPrint(#projectiles)
    local px, py = getPlayerPos()
    debugPrint(px.." "..py)
end

function _init()
    poke(0x5f2d, 0x1 + 0x2)
    palt(0, false)
    palt(11, true)

    Enemy:new({x=16, y=16}, enemies)
end

function _update60()
    cls(7)
    local px, py = getPlayerPos()
    setCamera(px, py)
    updateCursor()
    updatePlayer()
    updateEnemies()
    updateProjectiles()
end

function _draw()
    drawEnemies()
    drawPlayer()
    drawProjectiles()
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

local cam = {x=64, y=64}

function setCamera(x, y)
    --y = max(0, y)
    cam.x, cam.y = x, y
    camera(x - 64, y - 64)
end

function getCamera()
    return cam.x, cam.y
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