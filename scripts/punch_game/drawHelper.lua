local function control_for_mid(s, m, e)
    return {
        x = 2*m.x - 0.5*(s.x + e.x),
        y = 2*m.y - 0.5*(s.y + e.y)
    }
end

local function qbez_point(s, c, e, t)
    local ax = s.x + (c.x - s.x)*t
    local ay = s.y + (c.y - s.y)*t
    local bx = c.x + (e.x - c.x)*t
    local by = c.y + (e.y - c.y)*t
    return ax + (bx - ax)*t, ay + (by - ay)*t
end

function drawCurve(s, m, e, col, w)
    local c = control_for_mid(s, m, e)
    local step = 0.1
    local lastx, lasty = s.x, s.y
    for t=step,1,step do
        local x, y = qbez_point(s, c, e, t)
        linefill(lastx, lasty, x, y, w, col)
        lastx, lasty = x, y
    end
end

function linefill(ax,ay,bx,by,r,c)
    --function by https://www.lexaloffle.com/bbs/?pid=80095
    if r <= 1 then
        line(ax, ay, bx, by, c)
    end
    if(c) color(c)
    local dx,dy=bx-ax,by-ay
    -- avoid overflow
    -- credits: https://www.lexaloffle.com/bbs/?tid=28999
     local d=max(abs(dx),abs(dy))
     local n=min(abs(dx),abs(dy))/d
    d*=sqrt(n*n+1)
    if(d<0.001) return
    local ca,sa=dx/d,-dy/d
   
    -- polygon points
    local s={
     {0,-r},{d,-r},{d,r},{0,r}
    }
    local u,v,spans=s[4][1],s[4][2],{}
    local x0,y0=ax+u*ca+v*sa,ay-u*sa+v*ca
    for i=1,4 do
        local u,v=s[i][1],s[i][2]
        local x1,y1=ax+u*ca+v*sa,ay-u*sa+v*ca
        local _x1,_y1=x1,y1
        if(y0>y1) x0,y0,x1,y1=x1,y1,x0,y0
        local dx=(x1-x0)/(y1-y0)
        if(y0<0) x0-=y0*dx y0=-1
        local cy0=y0\1+1
        -- sub-pix shift
        x0+=(cy0-y0)*dx
        for y=y0\1+1,min(y1\1,127) do
            -- open span?
            local span=spans[y]
            if span then
                rectfill(x0,y,span,y)
            else
                spans[y]=x0
            end
            x0+=dx
        end
        x0,y0=_x1,_y1
    end
end


--[[
    @param from number start value
    @param to number end value
    @param progress number 0-1 
    @param funct function easing function
]]
function ease(from, to, progress, funct)
    return from + (to - from) * funct(progress)
end

function easeOutQuad(x) return 1 - (1 - x) * (1 - x) end
function easeOutCubic(x) return 1 - (1 - x) * (1 - x) * (1 - x) end
function easeInCubic(x) return x * x * x end