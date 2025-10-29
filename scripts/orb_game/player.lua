do

local x, y = 64, 96
local xVel, yVel = 0, 0
local maxXVel = 2
local dodgeFrames = 6
local dodgeDist = 12
local kbMult = 1

local speed = 1
local jumpStrength = 3
local jumps = 0
local maxJumps = 1

local size = 8
local spriteSize = size

local noInput = 0
local totalNoInput = -100000000


local lavaHit = false
local knocked = 0
local hitStun = 0
local hsShake = true
local jumpBuffer = 0
local invulnerable = 0

local wallTouch = false
local grounded = false
local facing = false --false left, true right
local freefall = false
local animations = {
    [0] = { --idle
        period = 1,
        sprites = {1}
    },
    [1] = { --walk
        period = 12,
        sprites = {2, 3}
    },
    [2] = { --air
        period = 1,
        sprites = {4}
    },
    [3] = { --crouch
        period = 1,
        sprites = {5}
    },
}
local currentAnimation = 0
local animationTimer = 0
local animation = 0
local headSprite = 17

local function applyInput()
    animation = 0
    headSprite = btn(2) and 18 or 17
    if btn(3) and grounded then
        animation = 3
        headSprite = 19
        if btn(0) and not btn(1) then
            facing = false
        elseif btn(1) and not btn(0) then
            facing = true
        end
    elseif btn(0) and not btn(1) then --move left
        xVel -= speed
        facing = false
        animation = 1
    elseif btn(1) and not btn(0) then --move right
        xVel += speed
        facing = true
        animation = 1
    end


    xVel = mid(-maxXVel, xVel, maxXVel)

    if (btnp(4)) then
        if wallTouch and not grounded then
            playerWallJump()
        else
            playerJump()
        end
    end

    local shortJumpStrength = jumpStrength/-3
    if not btn(4) and yVel < shortJumpStrength and noInput < 0 and knocked < 0 then
        yVel = shortJumpStrength       -- cut jump short
    end
end

local function applyDI()
    local inputX = 0
    local inputY = 0
    if (btn(0)) inputX -= 1
    if (btn(1)) inputX += 1
    if (btn(2)) inputY -= 1
    if (btn(3)) inputY += 1

    local mag = dist(0, 0, xVel, yVel)
    if mag == 0 then return 0,0 end

    -- current knockback direction
    local dir = atan2(xVel, yVel)

    -- normalize input
    local inputMag = dist(0,0,inputX,inputY)
    if inputMag > 0 then
        local inputDir = atan2(inputX, inputY)

        -- how far to rotate (max DI influence)
        local di_strength = 0.005 -- radians (~9 degrees)

        -- shortest angular difference
        local diff = inputDir - dir
        -- wrap to [-pi, pi]
        if diff > 0.5 then diff -= 1
        elseif diff < -0.5 then diff += 1 end

        -- clamp how much DI we apply
        local rotation = mid(-di_strength, diff, di_strength)

        dir += rotation
    end

    xVel = mag * cos(dir)
    yVel = mag * sin(dir)
end

local function movePlayer()
    local down, yCol = yVel > 0
    local xv, yv = xVel, yVel
    y, yVel, yCol = move_y(x, y, yVel, size)
    x, xVel, xCol = move_x(x, y, xVel, size)

    if xCol and fget(xCol, 1) and invulnerable <= 0 and not lavaHit then
        pushPlayer(5, xv > 0 and 0.5 or 0, 30)
        setPlayerHS(30)
        lavaHit = true
        return
    end
    if yCol and fget(yCol, 1) and invulnerable <= 0 and not lavaHit then
        pushPlayer(5, yv > 0 and 0.25 or 0.75, 30)
        setPlayerHS(30)
        lavaHit = true
        return
    end

    grounded = false
    if (down and yCol) then 
        grounded = true 
        jumps = maxJumps
        freefall = false
        if (jumpBuffer > 0) playerJump()
    end
    wallTouch = false
    if (xCol) wallTouch = sgn(xv)

    if knocked > 0 and xCol then
        xVel = xv * -1
    end
    if knocked > 0 and yCol then
        yVel = yv * -1
    end

    if (not grounded and not yCol) animation = 2
end

function pushPlayer(mag, dir, knockedFrames)
    knocked = knockedFrames or 0
    
    local xDir = cos(dir)
    xVel = mag * cos(dir)
    yVel = mag * sin(dir) + gravity
end

function playerWallJump()
    facing = true
    if (wallTouch == 1) facing = false
    local mag = jumpStrength * 1.5
    local dir = 0.125--0.1875
    xVel += mag * cos(dir) * -wallTouch
    yVel += mag * sin(dir)
    noInput = 10
    totalNoInput = 10000
end

function playerJump()
    if jumps > 0 and not freefall then
        yVel = -jumpStrength
        if (not grounded) jumps -= 1
        return
    end
    jumpBuffer = 10
end

local function playerDodge() --unused
    local dir = facing and 1 or -1
    xVel = dir * dodgeDist/dodgeFrames
    noInput = dodgeFrames
    invulnerable = dodgeFrames
    totalNoInput = 10000
end

function getPlayerState()
    return {
        x = x,
        y = y,
        facing = facing,
        grounded = grounded,
        freefall = freefall,    
        noInput = noInput,
        knocked = knocked,
        jumpBuffer = jumpBuffer,
        hitStun = hitStun,
        kbMult = kbMult
    }
end

function setNoInput(frames)
    applyInput()
    noInput = frames
    totalNoInput = frames
end

function setFreefall(bool)
    freefall = bool
end

function setPlayerHS(frames, shake)
    shake = shake == nil and true or shake
    hitStun = frames
    hsShake = shake
end

function addPlayerPerc(perc)
    kbMult += perc
end

function updatePlayer()
    if hitStun > 0 then
        hitStun -= 1
        return
    end
    yVel += gravity

    if noInput < 0 and knocked < 0 then 
        applyInput()
        lavaHit = false
    elseif knocked > 0 and noInput < 0 then
        applyDI()
        animation = grounded and 0 or 2
        headSprite = btn(2) and 18 or 17
    end

    if btnp(4) and grounded then
        if noInput > totalNoInput - 5 then
            grounded = false
            doAttack()
            playerJump()
        elseif noInput > 0 then
            jumpBuffer = 10
        end
    end

    movePlayer()

    local friction = speed
    if (noInput <= 0 and knocked <= 0) xVel = abs(xVel) < friction and 0 or xVel - sgn(xVel)*friction

    
    if (noInput > -1) noInput -= 1
    if (knocked > -1) knocked -= 1
    if (jumpBuffer > -1) jumpBuffer -= 1
    if (invulnerable > -1) invulnerable -= 1
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
    local dx, dy = x, y
    if hitStun > 0 and hsShake then
        dx += randDec(-1.5, 1.5)
        dy += randDec(-1.5, 1.5)
    end
    bigSpr(headSprite, dx-spriteSize/2, dy-spriteSize/2, spriteSize, not facing)
    bigSpr(sprite, dx-spriteSize/2, dy-spriteSize/2, spriteSize, not facing)
    centerPrint("\#0"..flr((kbMult - 1) * 100).."%", dx, dy - 8, 7)
    --circfill(x, y, 1, 8)
    --rectfill(x - size/2, y - size/2, x + size/2, y + size/2, 8)
end

end