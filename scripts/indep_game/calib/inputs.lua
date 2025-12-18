inputs, activeInputs, lookAheadSec, offsets, nextInputIndex = {}, {}, 0.5, {}, 1

--[[
    type: false - L, true - R
]]
function addInput(beat, type) 
    local input = {
        beat = beat,
        second = beatToSec(beat),
        type = type,
        hit = false,
    }
    add(inputs, input)
    addSound(beat, 62)
    qsort(inputs, function(a, b) return a.beat - b.beat end)
end

function updateInputs()
    local buttons = readButtons()
    
    while nextInputIndex <= #inputs and inputs[nextInputIndex].second <= second + lookAheadSec do
        add(activeInputs, inputs[nextInputIndex])
        nextInputIndex += 1
    end

    for input in all(activeInputs) do 
        if second > input.second + lookAheadSec and not input.hit then
            input.remove = true
        end
    end

    for button in all(buttons) do 
        local type, pressed = unpack(button)
        if (not pressed) goto continue

        local best
        for input in all(activeInputs) do 
            if input.type == type then
                best = input
                break
            end
        end

        if best then
            add(offsets, second - best.second)
            qsort(offsets, function(a, b) return a - b end)
            local len = #offsets
            if len % 2 == 0 then
                offsetSec = (offsets[len/2] + offsets[len/2 + 1])/2
            else
                offsetSec = offsets[(len + 1)/2]
            end

            best.hit = true
            best.remove = true
            --sfx(61)
        end

        ::continue::
    end

    for input in all(activeInputs) do
        if (input.remove) del(activeInputs, input)
    end
end

function readButtons()
    local left, right = false
   
    if (btnp(4) or btnp(5)) left = true
    if (btnp(0) or btnp(1) or btnp(2) or btnp(3)) right = true

   return {{false, left}, {true, right}}
end