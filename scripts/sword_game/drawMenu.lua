do

local sprite = 32
local size = 64--64
local pixelSize = size/8 
local halfPixel = pixelSize/2
local y_top = 64 - size
local x = 64 - size/2
local relx = 0
local rely = 0
local drawColor = 1
local noClick = 0
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
    [1] = 0,
    [4] = 0,
    [5] = 0,
    [6] = 0,
    [7] = 0,
    [8] = 0,
    [9] = 0,
    [10] = 0,
    [11] = 0,
    [12] = 0,
    [13] = 99,
    [14] = 99,
    [15] = 99,
}
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

function debugInfiniteColors()
    for i=4,15 do
        weaponColors[i] = 99
    end
end

function getWeaponColors()
    return weaponColors
end

function initDrawMenu()
    sprite = getWeapon()
    noClick = 60
    drawColor = 1
end

function updateDrawMenu()
    sprite = getWeapon()   
    if (sprite == 35) sprite = 34 
    local cx, cy = getCursorPos()
    relx = cx - x
    rely = cy - y_top
    local ix = flr(relx / pixelSize)
    local iy = flr(rely / pixelSize)
    if ttn(X) and noClick < 0 then
        local sx, sy = ix + 8 * (sprite % 16), iy + 8 * flr(sprite/16)
        --stop(sx.." "..sy.." "..sget(sx, sy), 1, 1)
        local col = sget(sx, sy)
        if ix == -1 and iy == 3 then
            gameState = 2
            initCombineMenu()
        elseif ix == mid(0, ix, 7) and iy == mid(0, iy, 15) then
            if weaponColors[drawColor] != 0 and count({drawColor, 0, 1}, col) == 0 then
                sset(sx, sy, drawColor)
                if sprite == 34 then
                    if sy == 25 and (sx == 18 or sx == 21) then
                        sy -= 1
                    end
                    sset(sx + 8, sy, oppositeColors[drawColor])
                end
                weaponColors[drawColor] -= 1
            end
        elseif ix == -1 then
            if (iy > 3 and iy < 13) drawColor = iy
        else
            if ttnp(X) then
                gameState = 0
                initGame()
                kills = 0
                setWeaponStats(countColors(sprite))
            end
        end
    end
    noClick -= 1
end

function drawDrawMenu()

    spawnBackgroundParticles()

    local sx, sy = (sprite % 16) * 8, flr(sprite / 16) * 8 
    local y_bot = 64          
    
    sspr(sx,     sy,   8, 8, x + 1, y_top, size, size)
    sspr(sx, sy + 8,   8, 8, x + 1, y_bot, size, size)
    local px = x + -1 * pixelSize + halfPixel

    local py = y_top + 3 * pixelSize + halfPixel
    pal(2, cycle({4,4,6,4,6,6,5,6,5,5,4,5}, 60, 120), 0)
    pal(3, cycle({5,6,5,5,4,5,4,4,6,4,6,6}, 60, 120), 0)
    pal(4, cycle({7,8,9}, 60, 120), 0)
    sspr(cycle({0, 8, 16, 24}, 30), 8, 8, 8, px - halfPixel + 1, py - halfPixel, pixelSize, pixelSize, flip, flip)
    pal(0)
    for i = 4, 12 do
        py = y_top + i * pixelSize + halfPixel
        rectfill(px - halfPixel + 1, py - halfPixel, px + halfPixel, py + halfPixel - 1, i)
        if weaponColors[i] < 0 then
            sspr(32, 0, 8, 8, px - halfPixel, py - halfPixel, pixelSize + 1, pixelSize)
        else 
            --local text = tostr(weaponColors[i])
            local len = print(text, 0, -10, 1)
            centerPrint(weaponColors[i], px + 2, py - halfPixel + 4, 1)
        end
    end 
    
    if relx >= -pixelSize and relx < size and rely >= 0 and rely < size * 2 then
    
        local ix = flr(relx / pixelSize)
        local iy = flr(rely / pixelSize)


        ix = ix
        iy = iy


        local px = x + ix * pixelSize + halfPixel
        local py = y_top + iy * pixelSize + halfPixel

        --circfill(px, py, 2, 1)
        rect(px - halfPixel + 1, py - halfPixel, px + halfPixel, py + halfPixel - 1, drawColor)
    end
end

end
