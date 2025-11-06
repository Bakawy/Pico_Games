do 

local maxSpawnTimer = 30
player = {}

Enemy = Class:new({
    x = 64,
    y = 64,
    hp = 1,
    r = 4,
    speed = 0.5,
    spawnTimer = maxSpawnTimer,
    dead = false,

    checkCollision = function(_ENV)
        
    end,
    damage = function(_ENV)
        hp -= 1
        if (hp <= 0) dead = true
    end,

    update = function(_ENV)
        if spawnTimer > 0 then
            spawnTimer -= 1
            return
        end
        local direction = atan2(player.x - x, player.y - y)
        x += speed * cos(direction)
        y += speed * sin(direction)

        checkCollision(_ENV)
    end,
    draw = function(_ENV)
        local sprite = 4
        if spawnTimer > 0 then
            local progress = (maxSpawnTimer - spawnTimer)/maxSpawnTimer
            sspr(sprite * 8, 8 * flr(sprite/16), 8, 8, x - 4, lerp(y + 4, y - 4, progress), 8, lerp(0, 8, progress))
        else
            spr(sprite, x - 4, y - 4)
        end
    end,
})
enemies = {}

function spawnEnemy()
    local locations = {}
    for y=0,mapData.h do 
        for x=0,mapData.w do 
            if fget(mget(x,y), 0) then
                add(locations, {x=x*8+4, y=y*8+4})
            end
        end
    end
    local location = rnd(locations)
    if location then
        addRoutine(function()
            wait(15)
            Enemy:new({
                x = location.x,
                y = location.y,
                hp = 2,
            }, enemies)
        end)
    end
end

function updateEnemies()
    player = getPlayerState()
    for e in all(enemies) do 
        e:update()
        if e.dead then 
            del(enemies, e)
            spawnEnemy()
        end
    end
    
end

function drawEnemies()
    for e in all(enemies) do e:draw() end
end

end