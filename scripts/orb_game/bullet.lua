do

local orb = {
    x = 64,
    y = 64,
    r = 1,
}
local player = {}
Bullet = Class:new({
    x = 64, 
    y = 64,
    dx = 0,
    dy = 0,
    col = 0,
    triAngle = 0,
    r = 1,
    dr = 0,
    dead = false,
    checkPlayer = function(_ENV)
        if dist(x, y, player.x, player.y) < r + 4 then
            local angle = atan2(player.x - x, player.y - y)
            pushPlayer(3 * player.kbMult, angle, 30)
            setPlayerHS(15)
            addPlayerPerc(0.07)
            dead = true

            local mag = 3
            for i=1, 8 do
                local a = angle + randDec(-0.05, 0.05)
                local m = mag * randDec(0.5, 1)
                local dx, dy = m * cos(a), m * sin(a)
                local radius = 5
                local len = 30
                Particle:new({
                    x = x,
                    dx = dx,
                    ddx = -dx/len,
                    y = y,
                    dy = dy,
                    ddy = -dy/len,
                    r = radius,
                    dr = -radius/len,
                    len = len,
                    col = col
                },particles)
            end
        end
    end,
    checkOrb = function(_ENV)
        orb.x, orb.y, orb.r = getOrbPos()
        if dist(x, y, orb.x, orb.y) < r * 2 + orb.r then
            local isDamaging = getOrbDamage()
            if isDamaging then
                dead = true
                setPlayerHS(7, false)
                
                local mag = 2
                for i=1, 4 do
                    local angle = randDec(0, 1)
                    local dx, dy = mag * cos(angle), mag * sin(angle)
                    local radius = 4
                    local len = 15
                    Particle:new({
                        x = x,
                        dx = dx,
                        ddx = -dx/len,
                        y = y,
                        dy = dy,
                        ddy = -dy/len,
                        r = radius,
                        dr = -radius/len,
                        len = len,
                        col = col
                    },particles)
                end
            end
        end
    end,
    update = function(_ENV)
        local _, xCol, yCol
        x, _, xCol = move_x(x, y, dx, r * 3)
        y, _, yCol = move_y(x, y, dy, r * 3)
        if (xCol or yCol) dead = true
        triAngle += 0.01
        range -= dist(0,0,dx,dy)
        checkOrb(_ENV)
        checkPlayer(_ENV)
        if (range <= 0) dead = true
    end,
    draw = function(_ENV)
        local R = 2 * r
        local verts = {}
        for s=0, 2 do 
            local angle = triAngle + (1/3) * s
            add(verts, {x + R * cos(angle), y + R * sin(angle)})
        end
        --circfill(x, y, r * 2, (col + 1) % 15)
        trian(verts[1][1],verts[1][2],verts[2][1],verts[2][2],verts[3][1],verts[3][2], col)
        --circfill(x, y, r, (col + 2) % 15)
    end
})
bullets = {}

function updateBullets()
    orb.x, orb.y, orb.r = getOrbPos()
    player = getPlayerState()
    for b in all(bullets) do 
        b:update()
        if b.dead then 
            del(bullets, b) 
        end 
    end
end

function drawBullets()
    for b in all(bullets) do
        b:draw()
    end
end

end