beat, second, lastTriggeredBeat, lastTick, musicLoops, spd, bpm, offsetSec, fps = 0, 0, -1, -1, 0, 0, 0, 0, 60
debugText = ""

function _init()
    music(4)
    spd = peek(0x3200 + stat(46) * 68 + 65) --spd of sfx in channel 0
    bpm = 7229.50819/(4*spd)
    

    --[[
    for i=4,14 do
        addInput(i * 2, i % 2 == 1)
    end
    ]]
    for i=4,19 do
        addInput(i, i % 2 == 1)
    end
    for i=0,3 do 
        addSound(i, 63)
    end
end

function _update60()
    cls()
    fps = stat(7)
    updateBeat()
    updateInputs()
    updateSounds()
end

function _draw()

   --[[
   local angle = beat/-2
    circfill(64 + 40 * cos(angle), 64 + 40 * sin(angle), 8, 8)
    circfill(64, 64, 8, 12)
    ]]
    clip(0, 0, 64, 128)
    rectfill(0, 0, 128, 128, 1)
    clip(64, 0, 64, 128)
    rectfill(0, 0, 128, 128, 2)
    clip(0, 0, 128, 128)
    rectfill(62, 0, 66, 128, 0)

    --[[
    local height = interpolate(16, 32, beat % 1, easeOutExpo)
    scaleSprite(1, 64, 64 - height, 32, height)
    ]]

    line(8, 56, 8, 72, 0)
    for input in all(activeInputs) do 
        local x = interpolate(120, 8, 1 - (input.second + offsetSec - second)/lookAheadSec, easeInQuad)
        circfill(x, 64, 5, input.type and 14 or 12)
    end

    drawDebug()
end

function updateBeat()
    local ticks = stat(56)
    local patternBeat = ticks/(32 * spd) * 8

    if (ticks < lastTick) musicLoops += 1
    lastTick = ticks

    beat = max(beat, musicLoops * 8 + patternBeat)
    second = 60/bpm * beat
    if beat >= lastTriggeredBeat + 1 then
        lastTriggeredBeat += 1
        --sfx(63)
    end 
end

function drawDebug()
    ? "", 1, -5, 7
    ? "beat: "..beat
    ? "time: "..second
    ? "bpm: "..bpm
    ? "offset ms: "..(offsetSec * 1000)
    --[[
    for offset in all(offsets) do 
        ? offset * 1000
    end
    ]]
end