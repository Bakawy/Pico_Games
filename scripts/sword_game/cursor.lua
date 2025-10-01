do

local x = 64
local y = 64

function updateCursor()
    x = stat(32) + cam.x - 64
    y = stat(33) + cam.y - 64
end

function drawCursor()  
    spr(1, x, y)
end

function getCursorPos()
    return x, y
end

end