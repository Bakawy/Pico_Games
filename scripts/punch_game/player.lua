local playerState = {
    type="idle", 
    progress=0,
    facing=false,
    punchHigh=false,
    bufferPunch=false,
    duration=-1,
}
local centerX, centerY = 64, 115
local radius = 30
local outerColor = 0
local innerColor = 7
local gloveRadius = 7

local function punch()
    playerState.type = "punch"
    playerState.progress = 0
    playerState.duration = 15
    playerState.facing = not playerState.facing
end

local function dodge()
    playerState.type = "dodge"
    playerState.progress = 0
    playerState.duration = 15
end

local function drawArm(p1, p2, p3)
    drawCurve(p1, p2, p3, outerColor, 1.5)
    circfill(p3.x, p3.y, gloveRadius, 4)
    circfill(p3.x, p3.y, gloveRadius * 4/5, 8)
end

local function drawIdle()
    local cy = centerY + 2.5 + 2.5 * cos(playerState.progress / 60)
    local handHeight = playerState.punchHigh and 32 or 16

    drawArm({x=centerX - radius, y=cy}, {x=centerX - radius - 16, y=cy}, {x=centerX - radius, y=cy - handHeight})
    drawArm({x=centerX + radius, y=cy}, {x=centerX + radius + 16, y=cy}, {x=centerX + radius, y=cy - handHeight})
    circfill(centerX, cy, radius, outerColor)
    circfill(centerX, cy, radius - 3, innerColor)
end

local function drawPunch()
    local progress = playerState.progress / playerState.duration
    local cy = ease(centerY - 16, centerY + 5, progress, easeOutQuad)
    local handHeight = playerState.punchHigh and 32 or 16
    local handY = ease(48 - (handHeight - 16), cy - handHeight, progress, easeOutQuad)
    local elbowY = ease((handY + cy) / 2, cy, progress, easeOutQuad)
    if playerState.facing then
        local handX = ease(48, centerX - radius, progress, easeOutQuad)
        local elbowX = ease((handX + (centerX - radius - 16)) / 2, centerX - radius - 16, progress, easeOutQuad)
        drawArm({x=centerX - radius, y=cy}, {x=elbowX, y=elbowY}, {x=handX, y=handY})

        drawArm({x=centerX + radius, y=cy}, {x=centerX + radius + 16, y=cy}, {x=centerX + radius, y=cy - handHeight})
    else
        local handX = ease(80, centerX + radius, progress, easeOutQuad)
        local elbowX = ease((handX + (centerX + radius + 16)) / 2, centerX + radius + 16, progress, easeOutQuad)
        drawArm({x=centerX + radius, y=cy}, {x=elbowX, y=elbowY}, {x=handX, y=handY})

        drawArm({x=centerX - radius, y=cy}, {x=centerX - radius - 16, y=cy}, {x=centerX - radius, y=cy - handHeight})
    end
    circfill(centerX, cy, radius, outerColor)
    circfill(centerX, cy, radius - 3, innerColor)
end

local function drawDodge()
    local progress = playerState.progress / playerState.duration
    local handHeight = playerState.punchHigh and 32 or 16
    local outerX = 0
    local innerX = 0
    local sign = playerState.facing and -1 or 1
    if not playerState.facing then
        outerX = ease(0, centerX - radius, progress, easeInCubic)
        innerX = ease(radius, centerX + radius, progress, easeInCubic)
    else
        outerX = ease(128 - radius, centerX - radius, progress, easeInCubic)
        innerX = ease(128, centerX + radius, progress, easeInCubic)
    end

    local hand1 = {
        x=ease(outerX + 16 * sign, centerX - radius, progress, easeInCubic),
        y=ease(64, centerY - handHeight, progress, easeInCubic),
    }
    local elbow1 = {
        x=ease(hand1.x - 16 * sign, centerX - radius - 16, progress, easeInCubic),
        y=ease((hand1.y + centerY)/2, centerY, progress, easeInCubic),
    }
    local hand2 = {
        x=ease(innerX + 16 * sign, centerX + radius, progress, easeInCubic),
        y=ease(64, centerY - handHeight, progress, easeInCubic),
    }
    local elbow2 = {
        x=ease(hand2.x - 16 * sign, centerX + radius + 16, progress, easeInCubic),
        y=ease((hand2.y + centerY)/2, centerY, progress, easeInCubic),
    }
    drawArm({x=outerX, y=centerY}, {x=elbow1.x, y=elbow1.y}, {x=hand1.x, y=hand1.y})
    drawArm({x=innerX, y=centerY}, {x=elbow2.x, y=elbow2.y}, {x=hand2.x, y=hand2.y})
    ovalfill(outerX, centerY - radius, innerX, centerY + radius, outerColor)
    ovalfill(outerX + 3, centerY - radius + 3, innerX - 3, centerY + radius - 3, innerColor)
end

local function drawBlock()
    local cy = centerY + 5
    local handHeight = 40

    drawArm({x=centerX - radius, y=cy}, {x=centerX - radius - 8, y=cy - radius/2}, {x=centerX - radius/3, y=cy - handHeight})
    drawArm({x=centerX + radius, y=cy}, {x=centerX + radius + 8, y=cy - radius/2}, {x=centerX + radius/3, y=cy - handHeight})
    circfill(centerX, cy, radius, outerColor)
    circfill(centerX, cy, radius - 3, innerColor)
end

local stateDrawTable = {
    idle = drawIdle,
    punch = drawPunch,
    dodge = drawDodge,
    block = drawBlock,
}

function updatePlayer()
    playerState.punchHigh = btn(2)

    if btnp(4) then
        if playerState.type == "idle" then
            punch()
        elseif playerState.type == "punch" and playerState.progress > playerState.duration / 3 then
            playerState.bufferPunch = true
        end
    end
    if playerState.type == "idle" then
        if btnp(0) then
            playerState.facing = false
            dodge()
        elseif btnp(1) then
            playerState.facing = true
            dodge()
        elseif btn(3) then
            playerState.type = "block"
            playerState.progress = 0
            playerState.duration = -1
        end
    elseif playerState.type == "block" and not btn(3) then
        playerState.type = "idle"
        playerState.progress = 0
        playerState.duration = -1
    end

    if playerState.type == "idle" then
        if playerState.bufferPunch then
            punch()
            playerState.bufferPunch = false
        end
    elseif playerState.duration != -1 and playerState.progress >= playerState.duration then
        playerState.type = "idle"
        playerState.progress = 0
        playerState.duration = -1
    end
    playerState.progress += 1
end

function drawPlayer()
    stateDrawTable[playerState.type]()
    print(playerState.type.." "..playerState.progress, 64, 0, 0)
end