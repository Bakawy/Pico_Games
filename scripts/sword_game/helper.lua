do

function dist(x1, y1, x2, y2)
    local dx, dy = x2 - x1, y2 - y1
    return sqrt(dx*dx + dy*dy)
end

function randDec(min, max)
    return rnd(max - min) + min
end

function cycle(tbl, f, offset)
    local offset, interval = offset or 0, f * #tbl
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

function within(x,min,max) return min<=x and x<=max end
function to(ax,ay,bx,by) return atan2(bx-ax, by-ay) end
function mdir(m,d) return {mag=m,dir=d} end
function outxy(x,y,s) return x~=mid(s,x,128-s) or y~=mid(s,y,128-s) end

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

function dot(a1, a2)
  return cos(a1)*cos(a2) + sin(a1)*sin(a2)
end

routines = {}

function addRoutine(fn)
    local co = cocreate(fn)
    add(routines, co)
end

function runRoutines()
    for r in all(routines) do
        local ok, done = coresume(r)
        if not ok or costatus(r) == "dead" then
            del(routines, r)
        end
    end
end

function playerHasMoved()
    local px, py = getPlayerPos()
    return px != 64 or py != 64 or #enemies != 0
end

end