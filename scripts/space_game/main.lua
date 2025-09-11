
function _init()
    poke(0x5f2d, 0x1 + 0x2)
    poke(0X5F5C, 255)
    --poke(0x5f2d, 0x2)
    pal({
        [1]=-15,
    }, 1)
    palt(0, false)
    palt(11, true)
end

function _update60()
    cls(1)
    updateCursor()
    updateMoons()
end

function _draw()
    drawMoons()
    drawCursor()
    drawPoints()
    print(flr(stat(1)*100).."% ram", 0, 0, 2)
    print(stat(32).." "..stat(33))
    print(stat(80).." "..stat(81).." "..stat(82).." "..stat(83).." "..stat(84).." "..stat(85))
    print(tostr(btn(4)).." "..tostr(btn(5)))
end

Class = setmetatable({
	new = function(self, table)
		table = table or {}
		setmetatable(table, {__index = self})
		return table
	end,
},{__index = _ENV})