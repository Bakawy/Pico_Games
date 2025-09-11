local innerColor = 6
local outerColor = 0--2
local width = 72
local height = 128
local eye1 = {x=50,y=55}
local eye2 = {x=78,y=55}

local state = "idle"
local progress = 0
local duration = -1
local blockHigh = false
local blockLow = false
local arms = {
    {
        dir = false,
        handAnchor = {x=8,y=64},
        elbowAnchor = {x=20,y=64},
        shoulderAnchor = {x=30,y=64},
        state = "idle",
        progress = rnd(90),
        duration = -1,
    },
    {
        dir = false,
        handAnchor = {x=120,y=64},
        elbowAnchor = {x=108,y=64},
        shoulderAnchor = {x=98,y=64},
        state = "idle",
        progress = rnd(90),
        duration = -1,
    },
    {
        dir = false,
        handAnchor = {x=8,y=64 + 32},
        elbowAnchor = {x=20,y=64 + 32},
        shoulderAnchor = {x=30,y=64 + 32},
        state = "idle",
        progress = rnd(90),
        duration = -1,
    },
    {
        dir = false,
        handAnchor = {x=120,y=64 + 32},
        elbowAnchor = {x=108,y=64 + 32},
        shoulderAnchor = {x=98,y=64 + 32},
        state = "idle",
        progress = rnd(90),
        duration = -1,
    },
}

local function drawIdle()
    local eyeRadius = 4
    eye1.x = 50 + sin(progress/250) * 2.5
    eye2.x = 78 + sin(progress/300) * -2.5
    eye1.y = 55 + cos(progress/350) * -2.5
    eye2.y = 55 + cos(progress/400) * 2.5

    circfill(eye1.x, eye1.y, eyeRadius, outerColor)
    circfill(eye2.x, eye2.y, eyeRadius, outerColor)
    drawCurve({x=eye1.x, y=eye1.y - 24}, {x=(eye1.x + eye2.x)/2, y=(eye1.y + eye2.y)/2}, {x=eye2.x, y=eye2.y - 24}, outerColor, 1.5)
    linefill(eye1.x - eyeRadius * 2, eye1.y + 12, eye2.x + eyeRadius * 2, eye2.y + 12, 1.5, outerColor)
end

local function drawHurt()
    local eyeRadius = 4
    eye1.x = 50 + sin(progress/(15)) * 8
    eye2.x = 78 + sin(progress/(15 * 1.2)) * -8
    eye1.y = 55 + cos(progress/(15 * 1.4)) * -8
    eye2.y = 55 + cos(progress/(15 * 1.6)) * 8

    --circfill(eye1.x, eye1.y, eyeRadius, 0)
    --circfill(eye2.x, eye2.y, eyeRadius, 0)
    drawCurve({x=eye1.x - eyeRadius, y=eye1.y - eyeRadius}, {x=eye1.x + eyeRadius, y=eye1.y}, {x=eye1.x - eyeRadius, y=eye1.y + eyeRadius}, outerColor, 1.5)
    drawCurve({x=eye2.x + eyeRadius, y=eye2.y - eyeRadius}, {x=eye2.x - eyeRadius, y=eye2.y}, {x=eye2.x + eyeRadius, y=eye2.y + eyeRadius}, outerColor, 1.5)
    drawCurve({x=eye1.x, y=eye1.y - 24}, {x=(eye1.x + eye2.x)/2, y=(eye1.y + eye2.y)/2}, {x=eye2.x, y=eye2.y - 24}, outerColor, 1.5)
    linefill(eye1.x - eyeRadius * 2, eye1.y + 12, eye2.x + eyeRadius * 2, eye2.y + 12, 1.5, outerColor)
end

local stateDrawTable = {
    idle = drawIdle,
    hurt = drawHurt,
}

local function drawArm(arm)
    local gloveRadius = 7
    drawCurve(arm.shoulder, arm.elbow, arm.hand, outerColor, 2)
    circfill(arm.hand.x, arm.hand.y, gloveRadius, 4)
    circfill(arm.hand.x, arm.hand.y, gloveRadius * 4/5, 8)
end

local function drawArmIdle(arm)
    local progressRatio = arm.progress / 90
    arm.hand = {
        x=arm.handAnchor.x,
        y=arm.handAnchor.y + sin(progressRatio) * 6 - 2,
    }
    arm.elbow = {
        x=arm.elbowAnchor.x,
        y=arm.elbowAnchor.y + cos(progressRatio) * 4 - 2,
    }
    arm.shoulder = arm.shoulderAnchor
    drawArm(arm)
end

local function drawArmHurt(arm)
    local progressRatio = arm.progress / 15
    arm.hand = {
        x=arm.handAnchor.x + cos(progressRatio) * 8 * (dir and 1 or -1),
        y=arm.handAnchor.y - sin(progressRatio) * 8,
    }
    arm.elbow = {
        x=arm.elbowAnchor.x + cos(progressRatio) * 8 * (dir and 1 or -1),
        y=arm.elbowAnchor.y - sin(progressRatio + 0.5) * 8,
    }
    arm.shoulder = arm.shoulderAnchor
    drawArm(arm)
end

local armStateDrawTable = {
    idle = drawArmIdle,
    hurt = drawArmHurt
}

function getEnemyBlock()
    return blockHigh, blockLow
end

function hurtEnemy()
    state = "hurt"
    progress = rnd(60)
    duration = progress + 15
    for arm in all(arms) do
        arm.state = "hurt"
        arm.progress = rnd(15)
        arm.duration = arm.progress + 15
    end
end 

function updateEnemy()
    progress += 1
    if duration > 0 and progress > duration then
        state = "idle"
        duration = -1
        progress = rnd(1000)
    end
    for arm in all(arms) do
        arm.progress += 1
        if arm.duration > 0 and arm.progress > arm.duration then
            arm.state = "idle"
            arm.duration = -1
            arm.progress = rnd(1000)
        end
    end
end

function drawEnemy()
    local radius = 16
    local margin = 6
    rrectfill((128 - width)/2, 128 - height + radius, width, height, radius, outerColor)
    rrectfill((128 - width)/2 + margin/2, 128 - height + radius + margin/2, width - margin, height - margin/2, radius, innerColor)
    for arm in all(arms) do
        armStateDrawTable[arm.state](arm)
    end
    stateDrawTable[state]()
end