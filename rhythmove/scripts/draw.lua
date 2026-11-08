function drawGame()
    cls(0)
    drawDebug()
    map(0, 0, 0, 16, 16, 14)

    ?debugText, 1, 0, 7
    if slot == 0 then
        line(x, y, x, y - 8, 1)
    elseif slot == 1 then
        line(x, y, x, y + 8, 1)
    elseif slot == 2 then
        line(x, y, x + 8, y, 1)
    elseif slot == 3 then
        line(x, y, x - 8, y, 1)
    end
    spr(1, x - 4, y - 4)

    ?"\#7score: " .. score, 32, 0, 0
    ?"\#7time left: " .. flr(endTime - beat), 32, 8, 0
end

function drawCalib()
    cls(7)
    drawDebug()
    ?"calibration", 32, 32

    line(8, 56, 8, 72, 5)
    for input in all(activeInputs) do
        --3C4281818181423C 181818FFFF181818
        local x = lerp(120, 8, 1 - (input.second + offsetSec - second) / lookAheadSec, easeInQuad)
        circfill(x, 64, 5, 4)
        --spr(input.type and 3 or 2, x - 6, )
    end
end

function drawDebug()
    ?"", 1, -5, 3
    ?"beat: " .. beat
    ?"time: " .. second
    ?"", 64, -5, 3
    ?"bpm: " .. bpm
    ?"offset ms: " .. (offsetSec * 1000)
    --[[
    for offset in all(offsets) do
        ? offset * 1000
    end
    ]]
end