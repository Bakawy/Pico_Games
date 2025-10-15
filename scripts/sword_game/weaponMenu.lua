do 

local weapons = {
    {
        id = 32,
        name = "sword",
    },
    {
        id = 33,
        name = "cannon",
    },
    {
        id = 34,
        name = "mask",
    },
    {
        id = 36,
        name = "spear",
    },
    {
        id = 37,
        name = "wrench",
    },
    {
        id = 38,
        name = "potion",
    },
    {
        id = 39,
        name = "ball",
    },
}
local y = 40
local size = 16
local weaponsPerRow = 7
local length = size * 9/8 * min(#weapons - 1, weaponsPerRow - 1)
local x =  64 - length/2

function initWeaponMenu()
    buttons = {}
    local x = x + weaponsPerRow * size * 9/8
    local y = y - size * 2.5
    i = 0
    for w in all(weapons) do 
        if (i % weaponsPerRow == 0)  then 
            y += size * 2.5
            x -= weaponsPerRow * size * 9/8
        end 

        Button:new({
            x = x,
            y = y,
            size = size,
            sprite = w.id,
            onClick = function (_ENV)
                global.gameState = 0
                setWeapon(w.id)
                initGame()
            end
        }, buttons)
        Button:new({
            x = x,
            y = y + size,
            size = size,
            sprite = w.id + 16,
            onClick = function (_ENV)
                global.gameState = 0
                setWeapon(w.id)
                initGame()
            end
        }, buttons)
        x += size * 9/8
        i += 1
    end
end

function updateWeaponMenu()
    if ttnp(X) then
        local cx, cy = getCursorPos()
        for b in all(buttons) do 
            if (b:checkClick(cx, cy)) break
        end
    end
end

function drawWeaponMenu()
    --rrectfill(x - size*0.5 , y - 20, 9/8 * #weapons - (x + size*0.5), 3.2 * size, 6, 3)
    spawnBackgroundParticles()

    centerPrint("\#3choose a weapon", 64, y - 16, 1)
    for b in all(buttons) do
        b:draw()
    end
    local x = x + weaponsPerRow * size * 9/8
    local y = y - size * 2.5
    local i = 0
    for w in all(weapons) do 
        if (i % weaponsPerRow == 0)  then 
            y += size * 2.5
            x -= weaponsPerRow * size * 9/8
        end 

        centerPrint("\#3"..w.name, x, 2 * size + y + (i%2==0 and 0 or 6), 1)
        centerPrint("\#3"..dget(w.id), x, 2 * size + y + (i%2==0 and 0 or 6) + 6, 1)
        --circfill(x, 2 * size + y, 2, 13)
        x += size * 9/8
        i += 1
    end
end

end