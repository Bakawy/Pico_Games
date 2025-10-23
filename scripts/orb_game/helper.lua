do 

function clone(t)
    local copy = {}
    for k,v in pairs(t) do
        if type(v) == "table" then
            copy[k] = clone(v)
        else
            copy[k] = v
        end
    end
    return copy
end


function move_y(x,y,vy,size)
	local collided = false
    local dir = sgn(vy)
    local top, bottom
    local left, right = x - size/2 + 1, x + size/2 - 1
    if dir == -1 then
        top, bottom = y + vy, y - 1
    else
        bottom, top = y + vy, y + 1
    end
    top -= size/2
    bottom += size/2

    local tileLeft, tileRight, tileTop, tileBottom = flr(left/8), flr(right/8), flr(top/8), flr(bottom/8)

    for ty = tileTop, tileBottom do
        for tx = tileLeft, tileRight do
            if fget(mget(tx, ty), 0) then
                collided = mget(tx, ty)
                if dir == 1 then
                    y = ty * 8 - size/2
                else
                    y = (ty + 1) * 8 + size/2
                end
                vy = 0
                return y, vy, collided
            end
        end
    end

	return y + vy, vy, collided
end

function move_x(x,y,vx,size)
	local collided = false
    local dir = sgn(vx)
    local left, right
    local top, bottom = y - size/2 + 1, y + size/2 - 1
    if dir == -1 then
        left, right = x + vx, x - 1
    else
        right, left = x + vx, x + 1
    end
    left -= size/2
    right += size/2

    local tileLeft, tileRight, tileTop, tileBottom = flr(left/8), flr(right/8), flr(top/8), flr(bottom/8)

    for ty = tileTop, tileBottom do
        for tx = tileLeft, tileRight do
            if fget(mget(tx, ty), 0) then
                collided = mget(tx, ty)
                if dir == 1 then
                    x = tx * 8 - size/2
                else
                    x = (tx + 1) * 8 + size/2
                end
                vx = 0
                return x, vx, collided
            end
        end
    end

	return x + vx, vx, collided
end

function bigSpr(sprite, x, y, size, xflip)
    local sx, sy = (sprite % 16) * 8, flr(sprite / 16) * 8
    xflip = xflip or false
    sspr(sx, sy, 8, 8, x, y, size, size, xflip)
end

function dist(x1, y1, x2, y2)
    local dx, dy = x2 - x1, y2 - y1
    return sqrt(dx*dx + dy*dy)
end

function ease(from, to, progress, funct)
    return from + (to - from) * funct(progress)
end

function mirrorY(a)
    return atan2(-cos(a), sin(a))
end


function linear(x) return x end

function centerPrint(text, x, y, col)
    local len = print(text, 0, -12)
    print(text, x - len/2, y - 2, col)
end

function randDec(min, max)
    return rnd(max - min) + min
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

function coordToTile(x, y)
	return flr(x / 8), flr(y / 8)
end
function coordToTiletbl(x, y)
	return {flr(x / 8), flr(y / 8)}
end


-- line of sight with PIXEL inputs
-- returns true if unobstructed
-- uses sprite flag 0 as "solid" (change FLAG_SOLID if needed)

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
      return false
    end

    -- reached target tile?
    if mapx == tx and mapy == ty then
      return true
    end

    -- blocked by solid tile?
    if fget(mget(mapx, mapy), FLAG_SOLID) then
      return false
    end
  end

  return false
end

function trian(a,b,c,d,e,f,g) --https://www.lexaloffle.com/bbs/?pid=tri by dw817
  local h,i=a-c,b-d
  local j,k,l,m=abs(h),abs(i),c,d
  j=max(1,max(j,k))
  for n=0,j do
    line(c,d,e,f,g)
    line(c+1,d,e+1,f)
    c+=h/j d+=i/j
  end
  pset(a,b,8)
  pset(l,m,11)
  pset(e,f,12)
end


end