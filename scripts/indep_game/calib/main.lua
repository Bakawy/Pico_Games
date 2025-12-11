beat, lastTriggeredBeat, lastTick, musicLoops, spd, bpm = 0, -1, -1, 0, 0, 0
events = {}
debugText = ""

function _init()
    music(3)
    spd = peek(0x3200 + stat(46) * 68 + 65) --spd of sfx in channel 0
    bpm = 7229.50819/(4*spd)
end

function _update60()
    cls()
    updateBeat()
    updateEvents()

    local angle = beat/-2
    circfill(64 + 40 * cos(angle), 64 + 40 * sin(angle), 8, 8)
    circfill(64, 64, 8, 12)
end

function _draw()
   ? debugText 
end

function addEvent(beat, run, endBeat)
    add(events, {
        beat = beat,
        run = run,
        endBeat = endBeat,
    })
end

function updateBeat()
    local ticks = stat(56)
    local patternBeat = ticks/(32 * spd) * 8

    if (ticks < lastTick) musicLoops += 1
    lastTick = ticks

    beat = max(beat, musicLoops * 8 + patternBeat)
    ? beat
    ? bpm
    if beat >= lastTriggeredBeat + 1 then
        lastTriggeredBeat += 1
        --sfx(63)
    end 
end

function updateEvents()
    for event in all(events) do 
        if beat >= event.beat then 
            event:run()
            if (not event.endBeat or beat >= event.endBeat) del(events, event)
        end
    end
end

function cheackInput(self)
    local inputBeat = (self.beat + self.endBeat) / 2 -- - 17 * (bpm/60000) test offset
    if btnp(4) then
        debugText ..= (inputBeat - beat) * (60000/bpm) .. "ms\n"
        del(events, self)
    end
end

--beat * (min/beat) * (60sec/min) * (1000ms/sec) = ms

addEvent(1, function(self)
    sfx(63)
    addEvent(self.beat + 1, self.run)
end)

--addEvent(2.5, cheackInput, 3.5)
--addEvent(3.5, cheackInput, 4.5)
--addEvent(4.5, cheackInput, 5.5)
--addEvent(5.5, cheackInput, 6.5)