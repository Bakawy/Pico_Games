beat, second, lastTriggeredBeat, lastTick, musicLoops, spd, bpm, offsetSec, fps, state, updateData, offsetBeat = 0, 0, -1, -1, 0, 0, 0, 0, 60, 0, true, 0
debugText = ""
x, y, slot, score = 64, 64, 0, 0

function _init()
    music(4)
    cls()

    spd = peek(0x3200 + stat(46) * 68 + 65)
    --spd of sfx in channel 0
    bpm = 7229.50819 / (4 * spd)

    --[[
    for i=4,14 do
        addInput(i * 2, i % 2 == 1)
    end
    ]]
    for i = 4, 19 do
        addInput(i)
    end
    for i = 0, 3 do
        addSound(i, 63)
    end

    --poke(0x5f5f, 0x10)
    --poke(0x5f2c, 135)
    --poke(0x5f2e, 0x1)
    --memset(0x5f78, 0xff, 8)
    poke(0x5f5c, 255)
end

function _update60()
    fps = stat(7)

    if updateData then
        spd = peek(0x3200 + stat(46) * 68 + 65)
        --spd of sfx in channel 0
        bpm = 7229.50819 / (4 * spd)

        offsetBeat = offsetSec * bpm / 60
        updateData = false
    end

    updateBeat()
    updateSounds()

    if state == 0 then
        updateCalibInputs()

        if beat > 20 then
            state = 1
            initGame()
            setMusic(5)
        end
    elseif state == 1 then
        updateInput()
        updateTime()
    end
end

function _draw()
    if state == 0 then
        drawCalib()
    end
    if state == 1 then
        drawGame()
    end
    if state == 2 then
        cls(0)
        ?"time out :(", 64, 64, 7
        ?"score: " .. score
    end
end

function updateBeat()
    local ticks = stat(56)
    local patternBeat = ticks / (32 * spd) * 8

    if (ticks < lastTick) musicLoops += 1
    lastTick = ticks

    beat = max(beat, musicLoops * 8 + patternBeat)
    second = 60 / bpm * beat
    if beat >= lastTriggeredBeat + 1 then
        lastTriggeredBeat += 1
        --sfx(63)
    end
end