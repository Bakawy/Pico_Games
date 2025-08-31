local playerState = {
    type="idle", 
    progress=0,
    facing=false,
    punchHigh=false,
    bufferPunch=false,
}
local punchDuration = 15
stateDrawTable = {
    idle = drawIdle,
}
function updatePlayer()
    playerState.punchHigh = btn(2)

    if btnp(4) then
        if playerState.type == "idle" then
            playerState.type = "punch"
            playerState.progress = 0
            playerState.facing = not playerState.facing
        elseif playerState.type == "punch" and playerState.progress > punchDuration / 3 then
            playerState.bufferPunch = true
        end
    end

    if playerState.type == "idle" then
        if playerState.bufferPunch then
            playerState.type = "punch"
            playerState.progress = 0
            playerState.bufferPunch = false
            playerState.facing = not playerState.facing
        end
    elseif playerState.type == "punch" and playerState.progress >= punchDuration then
        playerState.type = "idle"
        playerState.progress = 0
    end
    playerState.progress += 1
end

local centerX, centerY = 64, 115
local radius = 30
local outerColor = 0
local innerColor = 7

function drawPlayer()
    stateDrawTable[playerState.type]()
    print(playerState.type.." "..playerState.progress, 64, 0, 0)
end

local function drawIdle()
    local pulse = (playerState.progress % 30) / 30
    local cy = ease(centerY + 5, centerY, pulse, easeOutQuad)
    local handHeight = playerState.punchHigh and 32 or 16

    
    circfill(centerX, cy, radius, outerColor)
    circfill(centerX, cy, radius - 3, innerColor)
    drawCurve({x=centerX - radius, y=cy}, {x=centerX - radius - 16, y=cy}, {x=centerX - radius, y=cy - handHeight}, outerColor, 1.25)
    drawCurve({x=centerX + radius, y=cy}, {x=centerX + radius + 16, y=cy}, {x=centerX + radius, y=cy - handHeight}, outerColor, 1.25)
end

local function drawPunch()
    local progress = playerState.progress / punchDuration
    local cy = ease(centerY - 16, centerY + 5, progress, easeOutQuad)
    local handHeight = playerState.punchHigh and 32 or 16

    circfill(centerX, cy, radius, outerColor)
    circfill(centerX, cy, radius - 3, innerColor)

    local handY = ease(48 - (handHeight - 16), cy - handHeight, progress, easeOutQuad)
    local elbowY = ease((handY + cy) / 2, cy, progress, easeOutQuad)
    if playerState.facing then
        local handX = ease(48, centerX - radius, progress, easeOutQuad)
        local elbowX = ease((handX + (centerX - radius - 16)) / 2, centerX - radius - 16, progress, easeOutQuad)
        drawCurve({x=centerX - radius, y=cy}, {x=elbowX, y=elbowY}, {x=handX, y=handY}, outerColor, 1.25)

        drawCurve({x=centerX + radius, y=cy}, {x=centerX + radius + 16, y=cy}, {x=centerX + radius, y=cy - handHeight}, outerColor, 1.25)
    else
        local handX = ease(80, centerX + radius, progress, easeOutQuad)
        local elbowX = ease((handX + (centerX + radius + 16)) / 2, centerX + radius + 16, progress, easeOutQuad)
        drawCurve({x=centerX + radius, y=cy}, {x=elbowX, y=elbowY}, {x=handX, y=handY}, outerColor, 1.25)

        drawCurve({x=centerX - radius, y=cy}, {x=centerX - radius - 16, y=cy}, {x=centerX - radius, y=cy - handHeight}, outerColor, 1.25)
    end
end

stateDrawTable = {
    idle = drawIdle,
    punch = drawPunch,
}