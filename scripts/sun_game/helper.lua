do

function dist(x1, y1, x2, y2)
    local dx = (x2 - x1) / 16
    local dy = (y2 - y1) / 16
    return sqrt(dx*dx + dy*dy) * 16
end

local lasty = 0
local lastx = 0
local lastcol = 0

function debugPrint(text, x, y, col)
    x = x or lastx
    y = y or lasty + 6
    col = col or lastcol
    local camx, camy = getCamera()
    setCamera(64, 64)
    print(text, x, y, col)
    print("", 0, 0)
    setCamera(camx, camy)
    lastx, lasty, lastcol = x, y, col
end

end