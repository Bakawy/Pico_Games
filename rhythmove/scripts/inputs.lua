inputs, activeInputs, lookAheadSec, offsets, nextInputIndex = {}, {}, 0.5, {}, 1

--[[
    type: false - L, true - R
]]
function addInput(beat)
    local input = {
        beat = beat,
        second = beatToSec(beat),
        hit = false
    }
    add(inputs, input)
    addSound(beat, 62)
    qsort(inputs, function(a, b) return a.beat - b.beat end)
end

function updateCalibInputs()
    local isPressed = readButtons()

    while nextInputIndex <= #inputs and inputs[nextInputIndex].second <= second + lookAheadSec do
        add(activeInputs, inputs[nextInputIndex])
        nextInputIndex += 1
    end

    for input in all(activeInputs) do
        if second > input.second + lookAheadSec and not input.hit then
            input.remove = true
        end
    end

    if isPressed then
        local best, bestd = nil, 0.2

        for input in all(activeInputs) do
            local d = abs(second - input.second)
            if d < bestd then best, bestd = input, d end
        end

        if #activeInputs > 0 then
            best = activeInputs[1]

            add(offsets, second - best.second)
            qsort(offsets, function(a, b) return a - b end)
            local len = #offsets
            if len % 2 == 0 then
                offsetSec = (offsets[len / 2] + offsets[len / 2 + 1]) / 2
            else
                offsetSec = offsets[(len + 1) / 2]
            end

            best.hit = true
            best.remove = true
            --sfx(61)
        end
    end

    for input in all(activeInputs) do
        if (input.remove) del(activeInputs, input)
    end
end

function updateInput()
    local isPressed = readButtons()
    local adjBeat = beat - offsetBeat

    slot = flr((adjBeat * 2) + 0.5) % 4

    if isPressed then
        local input = (adjBeat * 2) % 4
        local error = input - slot
        if slot == 0 then
            y -= 8
        elseif slot == 1 then
            y += 8
        elseif slot == 2 then
            x += 8
        elseif slot == 3 then
            x -= 8
        end
        x, y = mid(4, x, 124), mid(20, y, 124)

        updateTile(screenToMap(x, y))

        if not started then started = true end

        --debugText = tostr(adjBeat) .. " " .. tostr(slot)
    end
end

function readButtons()
    --local left, right = false

    --if (btnp(4) or btnp(5)) left = true
    --if (btnp(0) or btnp(1) or btnp(2) or btnp(3)) right = true

    return btnp(0) or btnp(1) or btnp(2) or btnp(3) or btnp(4) or btnp(5)
end