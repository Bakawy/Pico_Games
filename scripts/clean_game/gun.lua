do 

--txy tip xy
local player = {}
local aimDir, x, y, tx, ty, waterTie = 0, 64, 64, 64, 64, nil
local length, width = 8, 4

local fireRate, fireTimer = 2, 0

local function damageEnemy(_ENV, enemy)
    dead = true
    enemy:damage()
end


function updateGun()
    player = getPlayerState()
    x, y = player.x + player.r, player.y
    local cx, cy = getCursorPos()
    aimDir = atan2(cx - x, cy - y)
    tx, ty = x + length * cos(aimDir), y + length * sin(aimDir)

    if ttn(X) then
        if fireTimer <= 0 then 
            Projectile:new({
                x=tx,
                y=ty,
                speed=1,
                range=96,
                col=8,
                dir=aimDir,
                onEnemy = damageEnemy,
            }, projectiles)
            fireTimer = 60/fireRate
        end
    elseif ttn(O) then
        if fireTimer <= 0 then
            Projectile:new({
                x=tx,
                y=ty,
                speed=1,
                range=200,
                col=12,
                r=0.5,
                dir=aimDir,
                tie=(waterTie and dist(tx, ty, waterTie.x, waterTie.y) < 8) and waterTie or nil,
                onFlag0 = function(_ENV, mx, my)
                    local id = mget(mx, my)
                    if id > 16 then
                        id -= 1
                    else
                        id = 0
                    end
                    mset(mx, my, id)
                    dead = true
                end,
            }, projectiles)
            waterTie = projectiles[#projectiles]
            fireTimer = 2
        end
    else
        waterTie = nil
    end

    if (fireTimer > -1) fireTimer -= 1
end

function drawGun()
    linefill(x, y, tx + cos(aimDir), ty + sin(aimDir), width/2, 8)
end

end