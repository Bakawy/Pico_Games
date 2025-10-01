do
local weaponColors = getWeaponColors()
local recipies = {
    {4, 5, 7},
    {4, 6, 8},
    {5, 6, 9},
    {4, 7, 10},
    {4, 8, 10},
    {5, 7, 11},
    {5, 9, 11},
    {6, 8, 12},
    {6, 9, 12},
}
Button = Class:new({
    x = 64,
    y = 64,
    size = 8,
    sprite = 0,
    col = nil,
    draw = function(_ENV) 
        local halfSize = size/2
        if col then
            rectfill(x - halfSize, y - halfSize, x + halfSize, y + halfSize, col)
        elseif (size == 8) then
            spr(sprite, x - halfSize, y - halfSize)
        else
            local sx, sy = (sprite % 16) * 8, flr(sprite / 16) * 8
            sspr(sx, sy, 8, 8, x - halfSize, y - halfSize, size, size)
        end
    end,
    checkClick = function(_ENV, cx, cy) 
        local halfSize = size/2
        local clicked = (cx >= x - halfSize and cx <= x + halfSize and cy >= y - halfSize and cy <= y + halfSize)
        if (clicked) onClick(_ENV)
        return clicked
    end,
    onClick = function(_ENV) end,
})
buttons = {}

local selected = 0
local input2
local input1 = Button:new({
    x = 20,
    size = 32,
    sprite = 5,
    onClick = function (_ENV)
        sprite = 21
        if (selected == 2) input2.sprite = 6
        selected = 1
    end
}, buttons)
input2 = Button:new({
    x = 55,
    size = 32,
    sprite = 6,
    onClick = function (_ENV)
        sprite = 22
        if (selected == 1) input1.sprite = 5
        selected = 2
    end
}, buttons)
local combine = Button:new({
    x = 92,
    size = 32,
    sprite = 7,
    onClick = function (_ENV)
        if (not (input1.col and input2.col)) return
        local color1 = min(input1.col, input2.col)
        local color2 = max(input1.col, input2.col)
        for r in all(recipies) do 
            if r[1] == color1 and r[2] == color2 and weaponColors[color1] > 0 and weaponColors[color2] > 0 then
                addColor(color1, -1)
                addColor(color2, -1)
                addColor(r[3], 1)
            end
        end
    end
}, buttons)
local goBack = Button:new({
    x = 64,
    y = 115,
    size = 16,
    sprite = 8,
    onClick = function (_ENV)
        global.gameState = 1
        --initDrawMenu()
    end
}, buttons)
colorButtons = {}
for i=4,15 do 
    add(colorButtons, Button:new({
        y = 96,
        x = 10 * i - 40 + 10,
        col = i,
        onClick = function ()
            if selected == 1 then
                input1.col = i
            elseif selected == 2 then
                input2.col = i
            end
        end
    }, buttons))
end

function initCombineMenu()
    weaponColors = getWeaponColors()
    input1.col = nil
    input2.col = nil
end

function updateCombineMenu()
    if ttnp(X) then
        local cx, cy = getCursorPos()
        for b in all(buttons) do 
            if (b:checkClick(cx, cy)) break
        end
    end
end

function drawCombineMenu()
    for b in all(buttons) do
        b:draw()
    end
    for b in all(colorButtons) do
        text = tostr(weaponColors[b.col])
        len = print(text, 0, -10)
        print(text, b.x - len/2, b.y - 2, 1)
    end
end

end