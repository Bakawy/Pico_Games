local x = 64
local y = 64    

function updateCursor()
    x, y = stat(32), stat(33)
    if btnp(5) then
        Point:new({x=x, y=y})
    end
end

function drawCursor()
    spr(1, x, y)
end