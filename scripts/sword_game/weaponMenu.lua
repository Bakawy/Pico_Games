do 

local weapons = {
    {
        id = 32,
        name = "sword",
    },
    {
        id = 34,
        name = "mask",
    },
    {
        id = 33,
        name = "cannon",
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
        name = "shield",--"potion",
    },
    
    {
        id = 39,
        name = "ball",
    },
}
local y, size, weaponsPerRow = 40, 16, min(7, winCount + 1)
weapons = pack(unpack(weapons, 1, weaponsPerRow))
local size98, size25 = size * 9/8, size * 2.5
local length, roww = size98 * min(#weapons - 1, weaponsPerRow - 1), weaponsPerRow * size98
local x =  64 - length/2

function initWeaponMenu()
    buttons = {}
    local x, y, i = x + roww, y - size25, 0
    dset(34, max(dget(34), dget(35)))
    for w in all(weapons) do 
        if i % weaponsPerRow == 0 then 
            y += size25
            x -= roww
        end 

        local wid=w.id
        local function click()
            gameState=0
            setWeapon(wid)
            initGame()
        end

        for i=0,1 do
            Button:new({
                x=x,
                y=y+i*size,
                size=size,
                sprite=wid+i*16,
                onClick=click
            },buttons)
        end
        
        x += size98
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
    spawnBackgroundParticles()

    centerPrint("\#3choose a weapon", 64, y - 16, 1)
    for b in all(buttons) do
        b:draw()
    end
    local x, y, i = x + roww, y - size25, 0
    for w in all(weapons) do 
        if i % weaponsPerRow == 0  then 
            y += size25
            x -= roww
        end 

        centerPrint("\#3"..w.name, x, 2 * size + y + (i%2==0 and 0 or 6), 1)
        centerPrint("\#0"..(dget(w.id) == 0 and "" or flr(dget(w.id))), x, 2 * size + y + (i%2==0 and 0 or 6) + 12, 1)
        --circfill(x, 2 * size + y, 2, 13)
        x += size98
        i += 1
    end
end

end