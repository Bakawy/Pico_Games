do

function dist(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return sqrt(dx*dx + dy*dy)
end

function randDec(min, max)
    return rnd(max - min) + min
end

function cycle(tbl, f, offset)
    local offset = offset or 0
    local interval = f * #tbl
    local index = flr(((frame + offset) % interval) / (interval / #tbl)) + 1
    return tbl[index]
end

function round(num)
    if (num % 1 >= 0.5) return ceil(num)
    return flr(num)
end

function sprPal(s, x, y, tbl)
    for k,v in pairs(tbl) do
        pal(k, v, 0)
    end
    spr(s, x, y)
    pal(0)
end

end