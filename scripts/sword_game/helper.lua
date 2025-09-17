function dist(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return sqrt(dx*dx + dy*dy)
end
function randDec(min, max)
    return rnd(max - min) + min
end