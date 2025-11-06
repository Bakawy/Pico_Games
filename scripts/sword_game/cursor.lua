do

local x, y = 64, 64

function updateCursor()
    x, y = stat(32), stat(33)
end

function drawCursor()  
    spr(1, x, y)
end

function getCursorPos()
    return x, y
end

end