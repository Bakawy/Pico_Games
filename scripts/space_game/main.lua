score = 0
state = 0
restartTimer = 0
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
    if state == 0 then
        cls(1)
        updateCursor()
        updateMoons()
        updateEnemies()
    elseif state == 1 then
        restartTimer += 1
        if restartTimer > 120 then
            run()
        end
    end
end

function _draw()
    if state == 0 then
        drawMoons()
        drawPoints()
        drawEnemies()
        drawCursor()
        print("score: "..score, 0, 0, 7)
        print("click the moon and")
        print("protect from criticizm")
        --print(flr(stat(1)*100).."% ram", 0, 0, 2)
        --print(stat(32).." "..stat(33))
        --print(stat(80).." "..stat(81).." "..stat(82).." "..stat(83).." "..stat(84).." "..stat(85))
        --print(tostr(btn(4)).." "..tostr(btn(5)))
    elseif state == 1 then
        cls(0)
        local text = "you lose"
        print(text, 64 -  #text * 3, 64, 7)
    end
end

Class = setmetatable({
	new = function(self, table)
		table = table or {}
		setmetatable(table, {__index = self})
		return table
	end,
},{__index = _ENV})