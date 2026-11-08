started, endTime, time = false, 0, 64
function initGame()
    generateMap()
    started = false

    x, y = mapToScreen(findTile(21))
end

onTouch = {
    [17] = function()
        score += 1
    end,
    [18] = function()
        score -= 3
    end,
    [19] = function()
        initGame()
        setMusic(5)
    end,
    [20] = function()
        local tx, ty = randint(0, 15), randint(0, 13)
        x, y = mapToScreen(tx, ty)
        updateTile(tx, ty)
    end
}

function updateTile(tx, ty)
    local func = onTouch[mget(tx, ty)]
    debugText = tostr(mget(tx, ty))
    if func then
        mset(tx, ty, 16)
        func()
    end
end

function updateTime()
    if not started then
        endTime = beat + time
        return
    end
    if beat > endTime then
        state = 2
        music(-1)
    end
end