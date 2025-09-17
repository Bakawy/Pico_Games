local innerColor = 6
local outerColor = 0--2
local width = 72
local height = 128
local rrectRadius = 16
local eye1 = {x=50,y=55}
local eye2 = {x=78,y=55}

local state = "idle"
local progress = 0
local duration = -1

local metaState = "init"
local metaProgress = 0
local metaDuration = 1

local blockHigh = false
local blockLow = false

local punchStart = 45
local punchMid = 30
local punchEnd = 30

local hits = 0
local maxHits = 3

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
        dir = true,
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
        dir = true,
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

local function drawArm(arm, r)
    local gloveRadius = r or 7
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

local function drawArmBlock(arm)
    local len = 15
    if arm.progress < len and false then
        arm.hand = {
            x=ease(arm.handAnchor.x, arm.handAnchor.x + 44 * (arm.dir and -1 or 1), arm.progress/len, easeOutQuad),
            y=arm.handAnchor.y,
        }
        arm.elbow = {
            x=ease(arm.elbowAnchor.x, arm.elbowAnchor.x + 20 * (arm.dir and -1 or 1), arm.progress/len, easeOutQuad),
            y=arm.elbowAnchor.y,
        }
    else
        local progressRatio = (arm.progress - len) / 90
        arm.hand = {
            x=arm.handAnchor.x + 44 * (arm.dir and -1 or 1),
            y=arm.handAnchor.y + sin(progressRatio) * 6,
        }
        arm.elbow = {
            x=arm.elbowAnchor.x + 20 * (arm.dir and -1 or 1),
            y=arm.elbowAnchor.y + cos(progressRatio) * 4 - 2,
        }
    end
    arm.shoulder = arm.shoulderAnchor
    drawArm(arm)
end

local function drawArmPunch(arm)
    local R = 7
    local r = 7
    if arm.progress < punchStart then
        local progressRatio = arm.progress / punchStart
        r = ease(R, R * 1.25, progressRatio, easeOutQuad)
        arm.hand = {
            x=arm.handAnchor.x,
            y=ease(arm.handAnchor.y, arm.handAnchor.y - 28, progressRatio, easeOutQuad),
        }
        arm.elbow = {
            x=ease(arm.elbowAnchor.x, arm.elbowAnchor.x + 8 * (arm.dir and 1 or -1), progressRatio, easeOutQuad),
            y=arm.elbowAnchor.y,
        }
    elseif arm.progress < punchStart + punchMid then
        local progressRatio = (arm.progress - punchStart) / punchMid
        r = ease(R * 1.25, R * 2, progressRatio, easeInCubic)
        arm.hand = {
            x=ease(arm.handAnchor.x, 64, progressRatio, easeInCubic),
            y=ease(arm.handAnchor.y - 28, 115, progressRatio, easeInCubic),
        }
        local x = arm.elbowAnchor.x + 8 * (arm.dir and 1 or -1)
        arm.elbow = {
            x=ease(x, (x + 64)/2, progressRatio, easeInCubic),
            y=ease(arm.elbowAnchor.y, (arm.elbowAnchor.y + 115)/2, progressRatio, easeInCubic),
        }
    else
        local progressRatio = (arm.progress - punchStart - punchMid) / punchEnd
        r = ease(R * 2, R, progressRatio, easeOutCubic)
        arm.hand = {
            x=ease(64, arm.handAnchor.x, progressRatio, easeOutCubic),
            y=ease(115, arm.handAnchor.y, progressRatio, easeOutCubic),
        }
        local x = arm.elbowAnchor.x + 8 * (arm.dir and 1 or -1)
        arm.elbow = {
            x=ease((x + 64)/2, arm.elbowAnchor.x, progressRatio, easeOutCubic),
            y=ease((arm.elbowAnchor.y + 115)/2, arm.elbowAnchor.y, progressRatio, easeOutCubic),
        }
    end
    arm.shoulder = arm.shoulderAnchor
    drawArm(arm, r)
end

local function isHigh(arm)
    return arm.shoulderAnchor.y > 128 - (height - rrectRadius)/2
end


local armStateDrawTable = {
    idle = drawArmIdle,
    hurt = drawArmHurt,
    block = drawArmBlock,
    punch = drawArmPunch,
}

local function punch()
    shuffle(arms)
    local arm = arms[1]
    for arm in all(arms) do 
        if count({"idle", "block"}, arm.state) > 0 then
            arm.state = "punch"
            arm.progress = 0
            arm.duration = punchStart + punchMid + punchEnd
            break
        end
    end
end

local function setEnemyBlock(high, low)
    blockHigh = high
    blockLow = low
    for arm in all(arms) do
        if ((blockHigh and isHigh(arm)) or (blockLow and not isHigh(arm))) and arm.state != "block" then
            arm.state = "block"
            arm.progress = 0
            arm.duration = -1
        elseif ((not blockHigh and isHigh(arm)) or (not blockLow and not isHigh(arm))) and arm.state == "block" then
            arm.state = "idle"
            arm.progress = rnd(1000)
            arm.duration = -1
        end
    end
end

local metaStateFunctTable = {
    idle = function() 
        if rnd() < 1/120 then
            local t = {true, false}
            setEnemyBlock(rnd(t), rnd(t)) 
        end
        if (rnd() < 1/165) punch()
    end,
    init = function()
        --local t = {true, false}
        --setEnemyBlock(rnd(t), rnd(t)) 
        punch()
    end,
    punch = function() 
        if metaProgress == 1 then
            shuffle(arms)
            for arm in all(arms) do
                if arm.state == "idle" or arm.state == "block" then
                    arm.state = "punch"
                    arm.progress = 0
                    arm.duration = punchStart + punchMid + punchEnd
                end
            end
        end
    end,
    hurt = function() end,
}

function getEnemyBlock()
    return blockHigh, blockLow
end

function hurtEnemy()
    hits += 1
    if hits >= maxHits then
        setEnemyBlock(true, true)
        hits = 0
        metaState = "idle"
        metaProgress = 0
        metaDuration = -1
    end

    local len = 17
    state = "hurt"
    metaState = "hurt"
    metaProgress = 0
    metaDuration = 17
    progress = rnd(60)
    duration = progress + len
    for arm in all(arms) do
        arm.state = "hurt"
        arm.progress = rnd(15)
        arm.duration = arm.progress + len
    end
end 

function updateEnemy()
    metaProgress += 1
    if metaDuration > 0 and metaProgress > metaDuration then
        metaState = "idle"
        metaDuration = -1
        metaProgress = 0
    end
    metaStateFunctTable[metaState]()

    progress += 1
    if duration > 0 and progress >= duration then
        state = "idle"
        duration = -1
        progress = rnd(1000)
    end

    for arm in all(arms) do
        arm.progress += 1
        if arm.duration > 0 and arm.progress >= arm.duration then
            if (blockHigh and isHigh(arm)) or (blockLow and not isHigh(arm)) then
                arm.state = "block"
                arm.duration = -1
                arm.progress = 0
            else
                arm.state = "idle"
                arm.duration = -1
                arm.progress = rnd(1000)
            end
        end
    end

end

function drawEnemy()
    local radius = rrectRadius
    local margin = 6
    rrectfill((128 - width)/2, 128 - height + radius, width, height, radius, outerColor)
    rrectfill((128 - width)/2 + margin/2, 128 - height + radius + margin/2, width - margin, height - margin/2, radius, innerColor)
    stateDrawTable[state]()
    for arm in all(arms) do
        armStateDrawTable[arm.state](arm)
    end
end