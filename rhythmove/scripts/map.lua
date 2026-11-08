function findTile(id)
    for x = 0, 15 do
        for y = 0, 13 do
            if mget(x, y) == id then
                return x, y
            end
        end
    end
    return -1
end

function mapToScreen(x, y)
    -- (y + 2) * 8 + 4
    return x * 8 + 4, y * 8 + 20
end

function screenToMap(x, y)
    return x \ 8, y \ 8 - 2
end

function generateMap()
    for tx = 0, 15 do
        for ty = 0, 13 do
            mset(tx, ty, 16)
        end
    end

    mset(0, randint(0, 13), 21)
    mset(15, randint(0, 13), 19)

    for i = 0, 80 do
        placeTile(17)
    end
    for i = 0, 40 do
        placeTile(18)
    end
    for i = 0, 5 do
        placeTile(20)
    end
end

function placeTile(id)
    local tile, tx, ty = 0, 0, 0

    while tile != 16 do
        tx, ty = randint(0, 15), randint(0, 13)
        tile = mget(tx, ty)
    end

    mset(tx, ty, id)
end