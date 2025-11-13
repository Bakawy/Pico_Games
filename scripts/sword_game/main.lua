do

--[[
    cart data
    0 - weapons unlocked
    weapon ids - weapon highscore
]]
cartdata("bakawi_sword_game")
L, R, U, D, O, X, frame, roundCount, wave, gameState, score, global, noClick, winCount = {5, 1}, {3, 1}, {4, 1}, {0, 1}, {4, 0}, {5, 0}, 0, 0, 0, 4, 1000, _ENV, 0, dget(0)
waveString, waveData = [[
1 2 3 01
11 21 31 02
21 22 32 03
31 13 22 001
111 211 221 003
6 33 402 004
221 321 322 0001
032 042 053 0002
3001 3101 3111
0311 0421 0531 0004
]], {{{}}}
for i=1,#waveString-1 do
    local char, lastRound = waveString[i], waveData[#waveData]
    local code = ord(char)
    if code == 10 then
        add(waveData, {})
        add(waveData[#waveData], {})
    elseif code == 32 then
        add(lastRound, {})
    else
        add(lastRound[#lastRound], tonum(char))
    end
end

function _init()
    cls()
    poke(0x5f2d, 0x1 + 0x2)
    poke(0x5f5c, 255)
    --poke(0x5f34,0x2)

    poke(0x5f55, 0xa0)
    cls(3)
    poke(0x5f55, 0xc0)
    map()
    poke(0x5f55, 0x80)

    --[[
    menuitem(1, "infinite color", debugInfiniteColors)
    menuitem(2, "toggle hitbox", function()
        showHitbox = not showHitbox
    end)
    ]]
    menuitem(3, "reset save data", function()
        menuitem(3, "are you sure?", function()
            for i=0, 63 do 
                dset(i, 0)
            end
            run()
        end)
        return true
    end)
    pal({
        [0] = -1,
        0,
        5,
        7,
        8,
        10,
        -4,
        -7,
        2,
        -5,
        14,
        -9,
        12,
        -13,
        -6,
        3,
    }, 1)
    initWeaponMenu()
end

function _update60()
    updateCursor()
    updateParticles()
    if gameState == 0 then
        memcpy(0x6000, 0xa000, 8192)
        updatePlayer()
        updateEnemies()
        updateProjectiles()

        local currentWave = waveData[roundCount]
        if playerHasMoved() then
            score -= 0.02777777777 --1000/(60 fps * 60 seconds * 10 minutes)
            if #enemies == 0 then
                wave += 1
                if wave > #currentWave then
                    gameState = 1
                    if (not waveData[roundCount + 1]) winGame()
                    initDrawMenu()
                    projectiles = {}
                else 
                    for i = 1, #currentWave[wave] do
                        spawnEnemy(currentWave[wave][i], i)
                    end
                end
            end
        end
    elseif gameState == 1 then
        cls(0)

        updateDrawMenu()
    elseif gameState == 2 then
        cls(14)
        updateCombineMenu()
    elseif gameState == 3 then
        cls(1)
        if ((ttnp(O) or ttnp(X)) and noClick <= 0) run()
    elseif gameState == 4 then
        cls(3)
        updateWeaponMenu()
    elseif gameState == 5 then
        cls(1)
        if ((ttnp(O) or ttnp(X)) and noClick <= 0) run()
    end
    runRoutines()
    if (noClick >= 0) noClick -= 1
    frame += 1
end

function _draw()
    if gameState == 0 then
        drawProjectiles()
        drawEnemies()
        drawPlayer()

        if not playerHasMoved() then
            weapon = getWeapon()
            if weapon == 32 then
                centerPrint("swing your sword to hit enemies", 64, 26, 1)
                centerPrint("wasd to move", 64, 32, 1)
                centerPrint(isSwing() and "\f9swinging" or "\f4not swinging",64, 38, 1)
            elseif count({33,39}, weapon) != 0 then
                centerPrint("click to shoot", 64, 32, 1)
                centerPrint("attack with melee to gain ammo", 64, 38, 1)
            elseif weapon == 36 then
                centerPrint("click to dash into enemies", 64, 32, 1)
            elseif weapon == 38 then
                centerPrint("click to throw", 64, 26, 1)
                centerPrint("walk to shield to pick up", 64, 32, 1)
            end
            centerPrint("\#3w", 64, 54, 1)
            centerPrint("\#3a", 54, 64, 1)
            centerPrint("\#3s", 64, 74, 1)
            centerPrint("\#3d", 74, 64, 1)
        end

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
    elseif gameState == 4 then
        drawParticles()
        drawWeaponMenu()
    elseif gameState == 5 then
        centerPrint(":)", 64, 64, 3)
        centerPrint("click to restart", 64, 70, 3)
        centerPrint("score: "..flr(score), 64, 76, 3)
    end
    drawCursor()
    drawDebug()

    poke(0x5f55, 0x60)
    if count({0, 4}, gameState) != 0 then
        memcpy(0x6000, 0xc000, 8192)
    else
        cls(0)
    end
    poke(0x5f54, 0x80)
    sspr(0, 0, 128, 128, 0, 0)
    poke(0x5f54, 0x00)
    poke(0x5f55, 0x80)
end

function drawDebug()
    camera()
    if gameState == 0 then
        print("score: "..flr(score), 1, 1, 1)
        --print("rmb to change weapon sprite")
        centerPrint("round "..roundCount.."/"..#waveData, 64, 3, 1)
        centerPrint("wave "..wave.."/"..#waveData[roundCount], 64, 9, 1)
    end
end

function winGame()
    local weapon = getWeapon()
    if (score > dget(weapon)) dset(weapon, score)
    gameState, noClick = 5, 30
    music(0)
    dset(0, winCount + 1)
end

function initGame()
    setPlayerPos(64, 64)
    enemies, wave = {}, 0
    roundCount += 1

    for p in all(particles) do 
        p.dx *= 20
    end
end

function ttn(input)--table btn
    return btn(input[1], input[2])
end
function ttnp(input)
    return btnp(input[1], input[2])
end

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