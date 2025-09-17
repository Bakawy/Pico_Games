function _init()
    poke(0x5f5c, 255)
    pal({
        --[2]=-12,
        [3]=-15,
        [4]=-8,
        [5]=-4,
        --[6]=-1,
        [9]=12,
    }, 1)
    --[[
        pal({
            [0] = -16,
            [1] = -15,
            [2] = -14,
            [3] = -13,
            [4] = -12,
            [5] = -11,
            [6] = -10,
            [7] = 7,
            [8] = -8,
            [9] = -7,
            [10] = -6,
            [11] = -5,
            [12] = -4,
            [13] = -3,
            [14] = -2,
            [15] = 15,
        }, 1)
    ]]
    palt(0, false)
    palt(11, true)
    initBattle()
end


function _update60()
    cls(7)
    updatePlayer()
    updateEnemy()
end

function _draw()
    --spr(128, 32, 0, 8, 8)
    drawEnemy()
    drawPlayer()
    print(flr(stat(1)*100).."% ram", 0, 0, 0)
end

function initBattle()

end
