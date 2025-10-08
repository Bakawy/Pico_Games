do

local x = 64
local y = 64

function updateCursor()
    local camx, camy = getCamera()
    x = stat(32) + camx - 64
    y = stat(33) + camy - 64
end

function drawCursor()  
    spr(1, x, y)
end

function getCursorPos()
    return x, y
end

end