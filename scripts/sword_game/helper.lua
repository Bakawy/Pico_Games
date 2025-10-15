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

function round(num, nearest)
    nearest = nearest or 1
    num *= nearest
    if (num % 1 >= 0.5) return ceil(num)/nearest
    return flr(num)/nearest
end

function mirrorX(a)
    return atan2(-cos(a), sin(a))
end

function mirrorY(a)
    return atan2(cos(a), -sin(a))
end

function pow(x, y) --only works when y is an int > 0
    local num = 1
    for i=0, y do 
        num *= x
    end
    return num
end

function wait(frames)
    for i=1,frames do
        yield()
    end
end


end