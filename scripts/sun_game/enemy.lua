do

Enemy = Class:new({
    x=64,
    y=64,
    sizeRadius=4,
    scoreRadius=12,
    dead=false,
    checkPlayer=function(_ENV)
        local px, py, pr = getPlayerPos()
        local playerDist =  dist(x, y, px, py)
        if playerDist < pr + sizeRadius + scoreRadius then
            scoreRadius = max(0, playerDist - (pr + sizeRadius))

            if scoreRadius < 3 then
                global.score += 1
                dead = true
            end
        end
        print(dead)
    end,
    update=function(_ENV)
        checkPlayer(_ENV)
    end,
    draw=function(_ENV) 
        circfill(x, y, sizeRadius, 8)
        circ(x, y, sizeRadius + scoreRadius, 8)
    end,
})
enemies = {}

function updateEnemies()
    for e in all(enemies) do
        e:update()
        if (e.dead) del(enemies, e)
    end
end

function drawEnemies()
    for e in all(enemies) do
        e:draw()
    end
end

end