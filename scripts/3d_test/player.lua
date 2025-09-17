local x = 64
local y = 64
local moveSpeed = 1
local turnSpeed = 0.015
local size = 4
local lookAngle = 0.25
local fov = 0.25
local rays = {}
local rayDiv = 2
local tileColorTable = { 
    [1]=9,
    [2]=10,
}

local function castRay(sx, sy, angle, maxDistance)
    local distance = 0
    local dx, dy = cos(angle), sin(angle)
    local tileX, tileY = flr(sx / 8), flr(sy / 8)
    local stepX = (dx>0) and 1 or (dx<0) and -1 or 0
    local stepY = (dy>0) and 1 or (dy<0) and -1 or 0
    local sideDistX, sideDistY
    local deltaDistX, deltaDistY
    maxDistance = maxDistance or 181

    if dx > 0 then
        deltaDistX = 8 / dx
        sideDistX = ((tileX + 1) * 8 - sx) / dx
    elseif dx < 0 then
        deltaDistX = -8 / dx
        sideDistX = (sx - tileX * 8) / -dx
    else
        sideDistX, deltaDistX = INFINITY, INFINITY
        stepX = 0
    end
    if dy > 0 then
        deltaDistY = 8 / dy
        sideDistY = ((tileY + 1) * 8 - sy) / dy
    elseif dy < 0 then
        deltaDistY = -8 / dy
        sideDistY = (sy - tileY * 8) / -dy
    else 
        sideDistY, deltaDistY = INFINITY, INFINITY
        stepY = 0
    end


    while distance < maxDistance do
        if sideDistX < sideDistY then
            tileX += stepX
            distance = sideDistX
            sideDistX += deltaDistX
        else
            tileY += stepY
            distance = sideDistY
            sideDistY += deltaDistY
        end
        local tile = mget(tileX, tileY)
        if tile != 0 then
            distance = min(distance, maxDistance)
            return {x=sx + dx * distance, y=sy + dy * distance, distance=distance, angle=angle, hit=tile}
        end
    end
    distance = min(distance, maxDistance)
    return {x=sx + dx * distance, y=sy + dy * distance, distance=distance, angle=angle, hit=0}
end

local function drawRays()
    for ray in all(rays) do
        line(x, y, ray.x, ray.y, 10)
    end
end

function updateVision()
    local angle = lookAngle - fov/2
    local angleStep = fov / (128/rayDiv)--64
    rays = {}

    while angle < lookAngle + fov/2 do
        local ray = castRay(x, y, angle)
        add(rays, ray)
        angle += angleStep
    end
end

function updatePlayer()
    local doUpdateVision = false
    if btn(2) then 
        local a = sgn(cos(lookAngle)) == 1 and 0 or 0.5
        local ray = castRay(x, y, a, moveSpeed * abs(cos(lookAngle)))
        x = ray.x
        if ray.hit != 0 then
            ray = castRay(x, y, a, size)
            x = ray.x - size * sgn(cos(lookAngle))
        end

        a = sgn(sin(lookAngle)) == 1 and 0.75 or 0.25
        ray = castRay(x, y, a, moveSpeed * abs(sin(lookAngle)))
        y = ray.y
        if ray.hit != 0 then
            ray = castRay(x, y, a, size)
            y = ray.y - size * sgn(sin(lookAngle))
        end
        doUpdateVision = true
    end
    if btn(3) then 
        local angle = (lookAngle + 0.5) % 1
        local a = sgn(cos(angle)) == 1 and 0 or 0.5
        local ray = castRay(x, y, a, moveSpeed * abs(cos(angle)))
        x = ray.x
        if ray.hit != 0 then
            ray = castRay(x, y, a, size)
            x = ray.x - size * sgn(cos(angle))
        end

        a = sgn(sin(angle)) == 1 and 0.75 or 0.25
        ray = castRay(x, y, a, moveSpeed * abs(sin(angle)))
        y = ray.y
        if ray.hit != 0 then
            ray = castRay(x, y, a, size)
            y = ray.y - size * sgn(sin(angle))
        end
        doUpdateVision = true
    end
    if btn(0) then
        lookAngle = (lookAngle - turnSpeed) % 1
        doUpdateVision = true
    end
    if btn(1) then
        lookAngle = (lookAngle + turnSpeed) % 1
        doUpdateVision = true
    end
    if btnp(5) then
        draw3d = not draw3d
        camera()
    end
    if btn(4) then
        fov = (fov + 0.01) % 0.5
        --rayDiv = ((rayDiv + 0.05) % 20) + 1
        doUpdateVision = true
    end

    if doUpdateVision then
        updateVision()
    end
end

function drawPlayer()
    circfill(x, y, size, 11)
    line(x, y, x + cos(lookAngle) * size, y + sin(lookAngle) * size, 3)

    drawRays()
end

function getPlayerData()
    return {x=x, y=y}
end

function draw3dView()
    local screenWidth = 128
    local screenHeight = 128
    local wallHeight = 40
    local sliceWidth = screenWidth / #rays

    --[[
    for i=1,#rays do
        if rays[i].position == nil then
            rays[i].position = i
        end
    end

    for i=2, #rays do
        local dist = rays[i].distance
        for j=1, i - 1 do
            if dist > rays[j].distance then
                add(rays, rays[i], j)
                deli(rays, i + 1)
                break
            end
        end
    end
    ]]
    for i=1,#rays do
        local ray = rays[i]
        local alpha = ray.angle - lookAngle
        local d_perp = ray.distance * cos(alpha)
        local d_proj = (screenWidth / 2) / tan(fov/2)
        local sliceHeight = (d_proj * wallHeight) / max(d_perp, 0.001)
        local x0 = (i-1) * sliceWidth + frame%rayDiv
        --local x1 = x0 + sliceWidth
        local y0 = (screenHeight / 2) - (sliceHeight / 2)
        local y1 = y0 + sliceHeight
        local color = 13
        if (ray.distance > 32) color -= 4
        if (ray.distance > 64) color -= 4
        if (ray.distance > 112) color -= 4
        --rectfill(x0, y0, x1, y1, color)
        line(x0, y0, x0, y1, color)
    end
end