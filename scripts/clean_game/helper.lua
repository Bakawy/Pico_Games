do

L = {5, 1}
R = {3, 1}
U = {4, 1}
D = {0, 1}
O = {4, 0}
X = {5, 0}
function ttn(input)--table btn
    return btn(input[1], input[2])
end
function ttnp(input) return btnp(input[1], input[2]) end

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

function sprPal(s, x, y, tbl)
    local trans = {}
    for k,v in pairs(tbl) do
        if v == -1 then
            palt(k, true)
            add(trans, k)
        else
            pal(k, v, 0)
        end
    end
    spr(s, x, y)
    pal(0)
    for col in all(trans) do 
        palt(col, false)
    end
end

function dist(x1, y1, x2, y2)
    local dx = (x2 - x1) / 16
    local dy = (y2 - y1) / 16
    return sqrt(dx*dx + dy*dy) * 16
end

function circleLine(cx, cy, r, x1, y1, x2, y2)
    local ABx, ABy, ACx, ACy = x2 - x1, y2 - y1, cx - x1, cy - y1
    local ab2 = ABx^2 + ABy^2
    local t = mid(0, (ACx * ABx + ACy * ABy) / ab2, 1)
    local Px, Py = x1 + t * ABx, y1 + t * ABy
    local dx, dy = cx - Px, cy - Py
    return dx*dx + dy*dy <= r*r
end

local TILE_SIZE = 8
local MAP_W_TILES = 128
local MAP_H_TILES = 64
local FLAG_SOLID = 0
local HUGE = 32767

function los(x1_px, y1_px, x2_px, y2_px)
  -- convert to tile coords (floating)
  local x1 = x1_px / TILE_SIZE
  local y1 = y1_px / TILE_SIZE
  local x2 = x2_px / TILE_SIZE
  local y2 = y2_px / TILE_SIZE

  local sx, sy = flr(x1), flr(y1)
  local tx, ty = flr(x2), flr(y2)

  -- same-tile early out
  if sx == tx and sy == ty then return true end

  local dx = x2 - x1
  local dy = y2 - y1
  local stepx = (dx > 0) and 1 or -1
  local stepy = (dy > 0) and 1 or -1

  local mapx, mapy = sx, sy

  -- DDA "time" per tile step along x/y
  local delta_dist_x = (dx == 0) and HUGE or abs(1 / dx)
  local delta_dist_y = (dy == 0) and HUGE or abs(1 / dy)

  -- distance to first grid boundary
  local side_dist_x = (dx > 0) and ((sx + 1 - x1) * delta_dist_x)
                               or  ((x1 - sx)     * delta_dist_x)
  local side_dist_y = (dy > 0) and ((sy + 1 - y1) * delta_dist_y)
                               or  ((y1 - sy)     * delta_dist_y)

  for i=1, 256 do
    -- step to next tile boundary
    if side_dist_x < side_dist_y then
      side_dist_x += delta_dist_x
      mapx += stepx
    else
      side_dist_y += delta_dist_y
      mapy += stepy
    end

    -- bounds (no wrap)
    if mapx < 0 or mapy < 0 or mapx >= MAP_W_TILES or mapy >= MAP_H_TILES then
      return true--false
    end

    -- reached target tile?
    if mapx == tx and mapy == ty then
      return true
    end

    -- blocked by solid tile?
    if fget(mget(mapx, mapy), FLAG_SOLID) then
      return false, mapx, mapy
    end
  end

    stop()
    return false, mapx, mapy
end

function lerp(a, b, t)
    return a * (1 - t) + b * t
end

function wait(frames)
    for i=1,frames do
        yield()
    end
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

end