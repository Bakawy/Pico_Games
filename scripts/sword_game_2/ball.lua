Ball = Class:new({
    x = 64,
    y = 64,
    r = 6,
    noHit = 0,
    velmag = 0,
    veldir = 0,

    update = function(_ENV)
        if noHit > 0 then
            noHit -= 1
        else
            checkWeapon(_ENV)
        end

        local a, b, nx, ny = ballMove(_ENV)
        x,y=a,b

        if (nx != 0) veldir = 0.5 - veldir % 1
        if (ny != 0) veldir = -veldir % 1

        local frict = 0.03
        velmag -= frict * sgn(velmag)
        if (within(velmag, -frict, frict)) velmag = 0
    end,
    draw = function(_ENV)
        circfill(x, y, r, 5)
        --[[
        s = r/sqrt(2)
        rectfill(x - s, y - s, x + s, y + s, 4)
        rect(x - s, y - s, x + s, y + s, 6)
        ]]
    end,

    checkWeapon = function(_ENV)
        local hitbox, wv, _, direct = getHitbox()
        if (isSwing() and dist(x, y, hitbox.x, hitbox.y) < r + hitbox.r) then
            local rx, ry = hitbox.x - px, hitbox.y - py
            local rlen, dir = sqrt(rx*rx + ry*ry), -sgn(wv)
            local tx, ty = -ry*dir, rx*dir
            local ux, uy, _ = vnorm(tx, ty)

            local linearSpeed = abs(wv) * rlen

            local accuracyDeg = 60
            local accuracy = accuracyDeg/720
            local baseAngle = atan2(ux, uy)

            local minDist = 32767
            local finalAngle = baseAngle
            for e in all(enemies) do 
                local eAngle = to(x, y, e.x, e.y)
                if angleDiff(baseAngle, eAngle) < accuracy then
                    local eDist = dist(x, y, e.x, e.y)
                    if eDist < minDist then 
                        minDist = eDist
                        finalAngle = eAngle
                    end
                end
            end

            line(x, y, x + 96 * cos(baseAngle), y + 96 * sin(baseAngle), 4)
            line(x, y, x + 96 * cos(finalAngle), y + 96 * sin(finalAngle), 6)
            line(x, y, x + 96 * cos(baseAngle - accuracy), y + 96 * sin (baseAngle - accuracy), 5)
            line(x, y, x + 96 * cos(baseAngle + accuracy), y + 96 * sin (baseAngle + accuracy), 5)

            --[[
            draw(_ENV)
            line(x, y, x + 64 * cos(baseAngle - accuracy/100), y + 64 * sin (baseAngle - accuracy/100), 4)
            line(x, y, x + 64 * cos(baseAngle + accuracy/100), y + 64 * sin (baseAngle + accuracy/100), 4)
            stop()
            ]]
            --local finalAngle = baseAngle + randDec(-accuracy/100, accuracy/100)

            velmag, veldir, noHit = 5, finalAngle, 10
            --if (direct) enemy.hit = atan2(rx, ry) + randDec(-0.07, 0.07)
            --enemy.kb += 0.2
        end
    end,
    checkEnemy = function (_ENV)
        if (velmag < 0.5) return
        for e in all(enemies) do 
            local d = dist(x, y, e.x, e.y)
            if d < r + e.r then 
                local dx, dy = e.x - x, e.y - y
                
                -- Normalize collision vector
                local nx, ny = dx/d, dy/d
                
                -- Separate balls
                local overlap = (r + e.r) - d
                x -= nx * overlap--/2
                y -= ny * overlap--/2
                --e.x += nx * overlap/2
                --e.y += ny * overlap/2
                
                -- Get velocities
                local vx, vy = 
                    velmag * cos(veldir),
                    velmag * sin(veldir)
                
                -- reflect acroos normal
                local vn = vx*nx + vy*ny
                vx -= 2 * vn * nx
                vy -= 2 * vn * ny
                
                -- Update velocities
                velmag, veldir = 
                    dist(0, 0, vx, vy),
                    atan2(vx, vy),
                e:hit(atan2(-vx, -vy))
                
                break
            end
        end
    end,
})
balls = {}

function updateBalls()
    checkBallCollision()
    for b in all(balls) do 
        b:update()
    end
end

function drawBalls()
    for b in all(balls) do 
        b:draw()
    end
end

function checkBallCollision()
    for i = 1, #balls do 
        for j = i + 1, #balls do 
            local b1, b2 = balls[i], balls[j]
            local dx, dy = b2.x - b1.x, b2.y - b1.y
            local d = dist(0, 0, dx, dy)
            
            if d < b1.r + b2.r then
                -- Normalize collision vector
                local nx, ny = dx/d, dy/d
                
                -- Separate balls
                local overlap = (b1.r + b2.r) - d
                b1.x -= nx * overlap/2
                b1.y -= ny * overlap/2
                b2.x += nx * overlap/2
                b2.y += ny * overlap/2
                
                -- Get velocities
                local v1x, v1y, v2x, v2y = 
                    b1.velmag * cos(b1.veldir),
                    b1.velmag * sin(b1.veldir),
                    b2.velmag * cos(b2.veldir),
                    b2.velmag * sin(b2.veldir)
                
                -- Exchange normal components
                local v1n, v2n = 
                    v1x*nx + v1y*ny,
                    v2x*nx + v2y*ny
                
                v1x += (v2n - v1n) * nx
                v1y += (v2n - v1n) * ny
                v2x += (v1n - v2n) * nx
                v2y += (v1n - v2n) * ny
                
                -- Update velocities
                b1.velmag, b1.veldir, b2.velmag, b2.veldir = 
                    dist(0, 0, v1x, v1y),
                    atan2(v1x, v1y),
                    dist(0, 0, v2x, v2y),
                    atan2(v2x, v2y)
            end
        end
    end
end

function ballMove(self)
    local x, y, r, velmag, veldir = self.x, self.y, self.r, self.velmag, self.veldir

    local s, p = r * 2/sqrt(2), 0
    local dx, dy = dxdy(velmag, veldir)
    while (p < 1) do
        local pBall, ball = 1, nil
        for b in all(balls) do
            if (b == self) goto continue 
            local posx, posy, rad = 
                x - b.x, 
                y - b.y,
                r + b.r
            local bdx, bdy = dxdy(b.velmag, b.veldir)
            local velx, vely = 
                dx - bdx, 
                dy - bdy
            local A, B, C = 
                velx^2 + vely^2,
                2 * (posx * velx + posy * vely),
                posx^2 + posy^2 - rad^2

            if C <= 0 then
                pBall = 0
                ball = b
                break
            end
            if (A == 0) goto continue
            
            local D = B^2 - 4*A*C
            if (D < 0) goto continue

            local p0 = (-B - sqrt(D)) / (2*A)
            if 0 <= p0 and p0 < pBall then 
                pBall = p0 
                ball = b
            end

            ::continue::
        end
    end
end