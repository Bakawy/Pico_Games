beat, second, lastTriggeredBeat, lastTick, musicLoops, spd, bpm, offsetSec, fps = 0, 0, -1, -1, 0, 0, 0, 0, 60
debugText = ""

function _init()
    music(4)
    cls()
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

    pal({
        [3]=7,
        [4]=-15,
        [5]=1,
        [6]=-4,
        [7]=12,
    }, 1)
    pal({
        [4]=3,
        [5]=-5,
        [6]=11,
        [7]=-6,
    }, 2)
    poke(0x5f5f, 0x10)
    poke(0x5f2c, 135)
    --poke(0x5f2e, 0x1)
    memset(0x5f78, 0xff, 8)
end

function _update60()
    cls(7)
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
    
    clip(0, 0, 64, 128)
    rectfill(0, 0, 128, 128, 1)
    clip(64, 0, 64, 128)
    rectfill(0, 0, 128, 128, 2)
    clip(0, 0, 128, 128)
    rectfill(62, 0, 66, 128, 0)
    ]]

    drawImage(1, 32, 32)

    line(56, 8, 72, 8, 5)
    for input in all(activeInputs) do --3C4281818181423C 181818FFFF181818
        local y = interpolate(120, 8, 1 - (input.second + offsetSec - second)/lookAheadSec, easeInQuad)
        circfill(64, y, 5, 4)
        spr(input.type and 3 or 2, 60, y-4)
    end

    rectfill(0, 62, 128, 66, 0)

    --[[
    local height = interpolate(16, 32, beat % 1, easeOutExpo)
    scaleSprite(1, 64, 64 - height, 32, height)
    ]]

    --drawDebug()
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
    ? "", 1, -5, 3
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