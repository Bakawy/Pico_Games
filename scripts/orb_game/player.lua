do

local x, y = 64, 0
local xVel, yVel = 0, 0
local maxXVel = 2
local speed = 1
local size = 8
local spriteSize = size
local noInput = 0
local grounded = false
local facing = false --false left, true right
local animations = {
    [0] = {
        period = 1,
        sprites = {1}
    },
    [1] = {
        period = 12,
        sprites = {2, 3}
    },
    [2] = {
        period = 1,
        sprites = {4}
    },
}
local jumps = 0
local maxJumps = 1
local currentAnimation = 0
local animationTimer = 0
local animation = 0

local function applyInput()
    animation = 0
    if btn(0) and not btn(1) then --move left
        xVel -= speed
        facing = false
        animation = 1
    elseif btn(1) and not btn(0) then --move right
        xVel += speed
        facing = true
        animation = 1
    end
    xVel = mid(-maxXVel, xVel, maxXVel)

    if btnp(4) and jumps > 0 then
        yVel = -3
        if (not grounded) jumps -= 1
    end
end

local function movePlayer()
    local down, ycol = yVel > 0
    y, yVel, ycol = move_y(x, y, yVel, size)
    x, xVel = move_x(x, y, xVel, size)
    grounded = false
    if (down and ycol) then 
        grounded = true 
        jumps = maxJumps
    end
    if (not grounded and not ycol) animation = 2
    print(xVel, 64, 0)
    print(yVel)
end

function pushPlayer(mag, dir, noInputFrames)
    noInput = noInputFrames or 0
    local xDir = cos(dir)
    xVel = mag * cos(dir)
    yVel = mag * sin(dir) + gravity
end

function getPlayerPos()
    return x, y
end

function getPlayerFacing()
    return facing
end

function updatePlayer()
    yVel += gravity
    if (noInput <= 0) applyInput()

    --x += xVel
    --y += yVel
    movePlayer()
    local friction = speed
    if (noInput <= 0) xVel = abs(xVel) < friction and 0 or xVel - sgn(xVel)*friction
    noInput -= 1
end

function drawPlayer()
    local sprite
    if animation == currentAnimation then
        local period = animations[animation].period
        local sprites = animations[animation].sprites
        local index = flr(((animationTimer) % period) / (period / #sprites)) + 1
        sprite = sprites[index]
        animationTimer += 1
    else
        currentAnimation = animation
        animationTimer = 0
        sprite = animations[animation].sprites[1]
    end
    bigSpr(sprite, x-spriteSize/2, y-spriteSize/2, spriteSize, not facing)
    --circfill(x, y, 1, 8)
    --rectfill(x - size/2, y - size/2, x + size/2, y + size/2, 8)
end

end