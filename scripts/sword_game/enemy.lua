local function isDamage(enemy)
    local hitbox = getHitbox()
    if (isSwing() and dist(enemy.x, enemy.y, hitbox.x, hitbox.y) < enemy.size + hitbox.r) return true
    return false
end
Enemy = Class:new({
    x = 64,
    y = 64,
    size = 4,
})
enemies = {}


function updateEnemies()
    for enemy in all(enemies) do
        if isDamage(enemy) then
            enemy.x = randDec(16, 112)
            enemy.y = randDec(16, 112)
        end
    end
end

function drawEnemies()
    for enemy in all(enemies) do
        circfill(enemy.x, enemy.y, enemy.size, 1)
    end
end