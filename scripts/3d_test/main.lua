draw3d = false
INFINITY = 32767
frame = 0

function _init()
    updateVision()
    pal({
        [1]=-15,
        [5]=1,
        [9]=-4,
        [13]=12,
    }, 1)
end

function _update60()
    cls(0)
    updatePlayer()
    frame += 1
end

function _draw()
    if draw3d then
        draw3dView()
    else
        local playerData = getPlayerData()
        camera(mid(0, playerData.x - 64, 128), 0)

        drawPlayer()
        map()
        print("press x to toggle 3d", 32, 0, 3)
        print("press z to change fov", 160, 0, 3)
    end
    camera()
    print(flr(stat(1)*100).."% ram", 0, 0, 2)
end 