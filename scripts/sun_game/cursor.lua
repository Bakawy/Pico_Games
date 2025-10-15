do

local x = 64
local y = 64

function updateCursor()
    local camx, camy = getCamera()
    x = stat(32) + camx - 64
    y = stat(33) + camy - 64
end

function drawCursor()  
    sprPal(1, x, y, {[1]=0})
end

function getCursorPos()
    return x, y
end

end