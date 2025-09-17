local enemies = {

}
local spawnPeriod = 60
local spawnTimer = 999999

local function spawnEnemy()
    local angle = rnd(1)
    add(enemies, {
        x = 64 + 64 * cos(angle),
        y = 64 + 64 * sin(angle),
        size = 12,
    })
end

local function moveEnemies()
    local speed = 0.25
    for enemy in all(enemies) do
        local angle = atan2(64 - enemy.x, 64 - enemy.y)
        enemy.x += speed * cos(angle)
        enemy.y += speed * sin(angle)
    end
end

local function checkCollision()
    local cursorX, cursorY = getCursorPos()
    local points = getPoints()
    for enemy in all(enemies) do
        if dist(cursorX + 4, cursorY + 4, enemy.x, enemy.y) < enemy.size/2 + 4 then
            del(enemies, enemy)
        end
        for point in all(points) do
            if dist(point.x, point.y, enemy.x, enemy.y) < enemy.size/2 then
                state = 1
            end
        end
    end
end

function updateEnemies()
    moveEnemies()
    checkCollision()

    spawnTimer += 1
    if spawnTimer >= spawnPeriod then
        spawnTimer = 0
        spawnEnemy()
    end
end

function drawEnemies()
    for enemy in all(enemies) do
        --circfill(enemy.x, enemy.y, enemy.size/2, 8)
        sspr(24, 0, 16, 16, enemy.x - enemy.size/2, enemy.y - enemy.size/2, enemy.size, enemy.size)
    end
end
