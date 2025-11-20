do

local sprite, size = 32, 64
local pixelSize = size/8 
local halfPixel, y_top, x, relx, rely, drawColor, noClick = pixelSize/2, 64 - size, 64 - size/2, 0, 0, 1, 0
--[[    Color stat list
    4 +kb
    5 +weapon turn
    6 +special
    7 +kb +weapon turn
    8 +kb +special
    9 +weapon turn +special
    10 +++kb -special
    11 +++weapon turn -kb
    12 +++special -weapon turn
]]
local weaponColors = {
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    99,
    99,
    99,
}
--[[
local oppositeColors = {
    [4] = 9,
    [5] = 8,
    [6] = 7,
    [7] = 6,
    [8] = 5,
    [9] = 4,
    [10] = 11,
    [11] = 12,
    [12] = 10,
}
]]
local function opp(c) return c<10 and 13-c or 10+((c-9)%3) end

function addColor(col, num)
    weaponColors[col] = mid(0, weaponColors[col] + num, 99)
end

function countColors(sprite)
    local colors = {}

    local sx, sy = 8 * (sprite % 16), 8 * flr(sprite/16)
    for x = sx, sx+7 do
        for y = sy, sy+15 do  -- use sy+7 if your sprite is 8x8
            local col = sget(x, y)
            colors[col] = (colors[col] or 0) + 1
        end
    end
    return colors
end

--[[
function debugInfiniteColors()
    for i=4,15 do
        weaponColors[i] = 99
    end
end
]]

function getWeaponColors()
    return weaponColors
end

function initDrawMenu()
    sprite, noClick, drawColor = getWeapon(), 60, 1
    poke(0x5f55, 0xa0)
    cls(3)
    poke(0x5f55, 0x80)
    for p in all(particles) do p.spawnBG = false end
end

function updateDrawMenu()
    sprite = getWeapon()   
    if (sprite == 35) sprite = 34 
    if sprite == 40 then 
        sprite = 38 
        setWeapon(38)
    end
    local cx, cy = getCursorPos()
    relx, rely = cx - x, cy - y_top
    local ix, iy = flr(relx / pixelSize), flr(rely / pixelSize)
    if ttn(X) and noClick < 0 then
        local sx, sy = ix + 8 * (sprite % 16), iy + 8 * flr(sprite/16)
        local col = sget(sx, sy)
        if ix == -1 and iy == 3 then
            gameState = 2
            initCombineMenu()
        elseif within(ix, 0, 7) and within(iy, 0, 15) then
            if weaponColors[drawColor] != 0 and count({drawColor, 0, 1}, col) == 0 then
                sset(sx, sy, drawColor)
                if sprite == 34 then
                    if sy == 25 and (sx == 18 or sx == 21) then
                        sy -= 1
                    end
                    sset(sx + 8, sy, opp(drawColor))
                end
                weaponColors[drawColor] -= 1
            end
        elseif ix == -1 then
            if (iy > 3 and iy < 13) drawColor = iy
        else
            if ttnp(X) and cx > 64 then
                gameState = 0
                initGame()
                setWeaponStats(countColors(sprite))
            end
        end
    end
    noClick -= 1
end

function drawDrawMenu()

    spawnBackgroundParticles()

    local sx, sy, y_bot = (sprite % 16) * 8, flr(sprite / 16) * 8, 64     
    sspr(sx,     sy,   8, 8, x + 1, y_top, size, size)
    sspr(sx, sy + 8,   8, 8, x + 1, y_bot, size, size)
    local px, py = x + -1 * pixelSize + halfPixel, y_top + 3 * pixelSize + halfPixel
    local cx, cy = px - halfPixel, py - halfPixel

    pal(2, cycle({4,4,6,4,6,6,5,6,5,5,4,5}, 60, 120), 0)
    pal(1, cycle({5,6,5,5,4,5,4,4,6,4,6,6}, 60, 120), 0)
    pal(4, cycle({7,8,9}, 60, 120), 0)
    sspr(cycle({0, 8, 16, 24}, 30), 8, 8, 8, cx + 1, cy, pixelSize, pixelSize)
    pal(0)
    for i = 4, 12 do
        py = y_top + i * pixelSize + halfPixel
        cy = py - halfPixel
        rectfill(cx + 1, cy, px + halfPixel, py + halfPixel - 1, i)
        if weaponColors[i] < 0 then
            sspr(32, 0, 8, 8, cx, cy, pixelSize + 1, pixelSize)
        else 
            local len = print(text, 0, -10, 1)
            centerPrint(weaponColors[i], px + 2, cy + 4, 1)
        end
    end 
    
    if relx >= -pixelSize and relx < size and rely >= 0 and rely < size * 2 then
    
        local ix, iy = flr(relx / pixelSize), flr(rely / pixelSize)

        local px, py = x + ix * pixelSize + halfPixel, y_top + iy * pixelSize + halfPixel

        rect(px - halfPixel + 1, py - halfPixel, px + halfPixel, py + halfPixel - 1, drawColor)
    end

    print("\#3fight", 102, 64, 1)
    centerPrint("\#1\f4damage \f5speed \f6special", 64, 125)
    centerPrint("\#1draw to improve stats", 64, 2, 3)
end

end
