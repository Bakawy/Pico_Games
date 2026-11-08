playerX, playerY, playerSpeed, extend = 64, 64, 1, 0

function updatePlayer()
    dirX, dirY = 0, 0

    dirX += tonum(btn(1)) - tonum(btn(0))
    dirY += tonum(btn(3)) - tonum(btn(2))

    if dirX != 0 or dirY != 0 then
        dir = atan2(dirX, dirY)
        playerX += playerSpeed * cos(dir)
        playerY += playerSpeed * sin(dir)
    end

    extend = lerp(extend, tonum(btn(5)), 1 / 1.5)
end

function drawPlayer()
    spr(1, playerX - 4, playerY - 4)
end