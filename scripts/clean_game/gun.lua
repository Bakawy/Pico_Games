do 

--txy tip xy
local player = {}
local aimDir, x, y, tx, ty = 0, 64, 64, 64, 64
local length, width = 8, 4


function updateGun()
    player = getPlayerState()
    x, y = player.x + player.r, player.y
    local cx, cy = getCursorPos()
    aimDir = atan2(cx - x, cy - y)
    tx, ty = x + length * cos(aimDir), y + length * sin(aimDir)

    if ttn(X) then
        Projectile:new({
            x=tx,
            y=ty,
            speed=1,
            range=96,
            col=11,
            dir=aimDir,
        }, projectiles)
    end
end

function drawGun()
    linefill(x, y, tx, ty, width/2, 11)
end

end