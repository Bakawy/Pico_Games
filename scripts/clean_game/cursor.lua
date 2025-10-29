do

local x = 64
local y = 64

function updateCursor()
    x = stat(32) + cam.x - 64
    y = stat(33) + cam.y - 64
end

function drawCursor()  
    sprPal(1, x, y, {[1]=0,[2]=7,})
end

function getCursorPos()
    return x, y
end

end