do 

local x, y, r = 64, 64, 4

function getPlayerState()
    return {
        x = x,
        y = y,
        r = r,
    }
end

function updatePlayer()
    local speed = 1
    local dir = {0, 0}
    if (ttn(L)) dir[1] -= 1
    if (ttn(R)) dir[1] += 1
    if (ttn(U)) dir[2] -= 1
    if (ttn(D)) dir[2] += 1
    if dir[1] != 0 or dir[2] != 0 then
        dir = atan2(dir[1], dir[2])
        x += speed * cos(dir)
        y += speed * sin(dir)

        x = mid(r, x, mapData.w * 8 - r)
        y = mid(r, y, mapData.h * 8 - r)
    end
end

function drawPlayer()
    circfill(x, y, r, 8)
end

end