sounds, activeSounds, nextSoundIndex = {}, {}, 1

--[[
    type: false - L, true - R
]]
function addSound(beat, id) 
    local sound = {
        beat = beat,
        second = beatToSec(beat),
        id = id,
    }
    add(sounds, sound)
    qsort(sounds, function(a, b) return a.beat - b.beat end)
end

function updateSounds()
    
    while nextSoundIndex <= #sounds and sounds[nextSoundIndex].second <= second + lookAheadSec do
        add(activeSounds, sounds[nextSoundIndex])
        nextSoundIndex += 1
    end

    for sound in all(activeSounds) do
        if sound.id and beat >= sound.beat then
            sfx(sound.id)
            sound.id = nil
        end
        if (not sound.id) del(activeSounds, sound)
    end
end