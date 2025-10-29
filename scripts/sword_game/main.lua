do

L = {5, 1}
R = {3, 1}
U = {4, 1}
D = {0, 1}
O = {4, 0}
X = {5, 0}
deltaTime = nil
frame = 0
roundTimer = 0
roundTime = 20 * 60
roundCount = 0
gameState = 4
cam = {x=64, y=64}
cartdata("sword_game")
score = 0
mainPal = {
    [0] = -1,
    [1] = 0,
    [2] = 5,
    [3] = 7,
    [4] = 8,
    [5] = 10,
    [6] = -4,
    [7] = -7,
    [8] = 2,
    [9] = -5,
    [10] = 14,
    [11] = -9,
    [12] = 12,
    [13] = -13,
    [14] = -6,
    [15] = 7,
} 
global = _ENV
showHitbox = false

function _init()
    poke(0x5f2d, 0x1 + 0x2)
    poke(0x5f5c, 255)
    poke(0x5f34,0x2)
    menuitem(1, "infinite color", debugInfiniteColors)
    menuitem(2, "toggle hitbox", function()
        showHitbox = not showHitbox
    end)
    menuitem(3, "reset save data", function()
        for i=0, 63 do 
            dset(i, 0)
        end
    end)
    pal(mainPal, 1)
    initWeaponMenu()
end

function _update60()
    updateCursor()
    updateParticles()
    if gameState == 0 then
        deltaTime = 60 / stat(7)
        cls(13)
        updatePlayer()
        updateEnemies()
        updateProjectiles()

        --cam.x, cam.y = getPlayerPos()
        
        if (roundTimer >= roundTime) then
            gameState = 1
            initDrawMenu()
            projectiles = {}
            roundTimer = 0
        end
        roundTimer += 1
    elseif gameState == 1 then
        cls(0)

        updateDrawMenu()
    elseif gameState == 2 then
        cls(14)
        updateCombineMenu()
    elseif gameState == 3 then
        cls(1)
        if (btnp(4) or btnp(5)) run()
        local weapon = getWeapon()
        if (score > dget(weapon)) dset(weapon, score)
    elseif gameState == 4 then
        cls(3)
        updateWeaponMenu()
    end
    --camera(randDec(-2, 2), randDec(-2, 2))
    --_draw()
    --camera()
    camera(cam.x - 64, cam.y - 64)
    frame += 1
end

function _draw()
    --rect(-1, -1, 128, 128, 7)
    if gameState == 0 then
        drawProjectiles()
        drawEnemies()
        drawPlayer()
        drawParticles()
    elseif gameState == 1 then
        drawParticles()
        drawDrawMenu()
    elseif gameState == 2 then
        drawParticles()
        drawCombineMenu()
    elseif gameState == 3 then
        centerPrint(":(", 64, 64, 3)
        centerPrint("click to restart", 64, 70, 3)
        centerPrint("score: "..score, 64, 76, 3)
    elseif gameState == 4 then
        drawParticles()
        drawWeaponMenu()
    end
    drawCursor()
    drawDebug()
end

function drawDebug()
    camera()
    print(flr(stat(1)*100).."% cpu", 1, 1, 12)
    if gameState == 0 then
        print("score: "..score)
        --print("rmb to change weapon sprite")
        local text = "timer "..ceil((roundTime - roundTimer)/60)
        print(text, 96 - #text * 3, 1, 1)
    elseif gameState == 1 then
        print("click away to fight")
    end
    camera(cam.x - 64, cam.y - 64)
end

function initGame()
    setPlayerPos(64, 64)
    enemies = {}
    roundCount += 1
    spawnEnemy(3 + roundCount/3)
    roundTime = (20 + 2 * roundCount) * 60

    for p in all(particles) do 
        p.dx *= 20
    end
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

--[[
Class = setmetatable({
	new = function(self, table, toTable)
		table = table or {}
		setmetatable(table, {__index = self})
        add(toTable, table)
		return table
	end,
},{__index = _ENV})
]]
Class = setmetatable({
    new = function(_ENV,tbl, toTbl)
        tbl=tbl or {}
        
        setmetatable(tbl,{
            __index=_ENV
        })

        if (toTbl) add(toTbl, tbl)
        return tbl
    end,
    
    init=function()end
},{__index=_ENV})

end