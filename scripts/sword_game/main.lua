L = {5, 1}
R = {3, 1}
U = {4, 1}
D = {0, 1}
O = {4, 0}
X = {5, 0}
deltaTime = null

function _init()
    poke(0x5f2d, 0x1 + 0x2)
    palt(0, false)
    palt(11, true)

    Enemy:new({x=96, y=96}, enemies)
end

function _update60()
    deltaTime = 1--60 / stat(7)
    cls(7)
    updateCursor()
    updatePlayer()
    updateEnemies()
    --camera(randDec(-2, 2), randDec(-2, 2))
    --_draw()
    --camera()
end

function _draw()
    drawEnemies()
    drawPlayer()
    drawCursor()
    drawDebug()
end

function drawDebug()
    print(flr(stat(1)*100).."% cpu", 1, 1, 2)
    print(stat(7).." fps")
    print("wasd to move")
    print("lmb to change size")
    print("rmb to change sword sprite")
    --print(tostr(ttn(X)).." "..tostr(ttn(O)))
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
	new = function(self, table, toTable)
		table = table or {}
		setmetatable(table, {__index = self})
        add(toTable, table)
		return table
	end,
},{__index = _ENV})