function dist(x1, y1, x2, y2)
    local dx, dy = x2 - x1, y2 - y1
    return sqrt(dx*dx + dy*dy)
end

function randDec(min, max)
    return rnd(max - min) + min
end

function round(num, nearest)
    nearest = nearest or 1
    num *= nearest
    if (num % 1 >= 0.5) return ceil(num)/nearest
    return flr(num)/nearest
end

function within(x,min,max) return min<=x and x<=max end
function to(ax,ay,bx,by) return atan2(bx-ax, by-ay) end
function mdir(m,d) return {mag=m,dir=d} end
function dxdy(mag, dir) return mag * cos(dir), mag * sin(dir) end

function dot(a1, a2)
  return cos(a1)*cos(a2) + sin(a1)*sin(a2)
end

function vnorm(x,y)
    local m = sqrt(x*x + y*y)
    if (m < 0.0001) return 0,0,0
    return x/m, y/m, m
end

function angleDiff(a1, a2)
    return abs((a1 - a2 + 0.5) % 1 - 0.5)
end

--[[
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

function wait(frames)
    for i=1,frames do
        yield()
    end
end
]]

--[[
function castRay(sx, sy, angle, maxDistance)
    local distance, dx, dy, tileX, tileY = 0, cos(angle), sin(angle), flr(sx / 8), flr(sy / 8)
    local stepX, stepY, sideDistX, sideDistY, deltaDistX, deltaDistY = (dx>0) and 1 or (dx<0) and -1 or 0, (dy>0) and 1 or (dy<0) and -1 or 0
    maxDistance = maxDistance or 181

    if dx > 0 then
        deltaDistX = 8 / dx
        sideDistX = ((tileX + 1) * 8 - sx) / dx
    elseif dx < 0 then
        deltaDistX = -8 / dx
        sideDistX = (sx - tileX * 8) / -dx
    else
        sideDistX, deltaDistX = INFINITY, INFINITY
        stepX = 0
    end
    if dy > 0 then
        deltaDistY = 8 / dy
        sideDistY = ((tileY + 1) * 8 - sy) / dy
    elseif dy < 0 then
        deltaDistY = -8 / dy
        sideDistY = (sy - tileY * 8) / -dy
    else 
        sideDistY, deltaDistY = INFINITY, INFINITY
        stepY = 0
    end


    while distance < maxDistance do
        local stepDir = false --false x true y
        if sideDistX < sideDistY then
            tileX += stepX
            distance = sideDistX
            sideDistX += deltaDistX
        else
            tileY += stepY
            distance = sideDistY
            sideDistY += deltaDistY

            stepDir = true
        end
        local tile = mget(tileX + 1, tileY + 1)
        if fget(tile, 0) then
            distance = min(distance, maxDistance)
            return {x=sx + dx * distance, y=sy + dy * distance, distance=distance, angle=angle, hit=tile, isHit=true}
        end
    end
    distance = min(distance, maxDistance)
    return {x=sx + dx * distance, y=sy + dy * distance, distance=distance, angle=angle, hit=0, isHit=false}
end
]]

function solid_tile(tx,ty)
  local t=mget(tx + 1,ty + 1)
  return t and fget(t,0)
end

function hit(x1,y1,w1,h1, x2,y2,w2,h2, goalx, goaly) --https://github.com/kikito/hit.p8
  -- minkowsky difference between 2 aabbs, which is another aabb
  local x,y,w,h=x2-x1-w1,y2-y1-h1,w1+w2,h1+h2
  local dx,dy=goalx-x1,goaly-y1

  local t,nx,ny,tx,ty
  -- if diff contains point 0,0, there's intersection between first and second aabb
  local intersect = x<0 and x+w>0 and y<0 and y+h>0

  -- degenerate case: intersecting and not moving - use minimum displacement vector
  -- which is the nearest corner to 0,0 in the minkowsky diff
  if intersect and dx==0 and dy==0 then
    local px=abs(x)<abs(x+w) and x or x+w -- abs(x) can be bigger than abs(x+w)
    local py=abs(y)<abs(y+h) and y or y+h
    if abs(px)<abs(py) then
      py=0
      t= -abs(px)/w
    else
      px=0
      t= -abs(py)/h
    end
    nx=px>0 and 1 or px<0 and -1 or 0
    ny=py>0 and 1 or py<0 and -1 or 0
    tx,ty=x1+px,y1+py
    return t,nx,ny,tx,ty,true
  end

  -- no intersection, or intersection with movement
  -- calculate the clipping between the minkowsky diff aabb with the displacement vector dx,dy
  -- this is a modified version of the liang-barky line-clipping algorithm with normals added
  local t1,t2=-32768,32767 -- -huge,+huge
  local nx1,ny1,nx2,ny2=0,0,0,0
  local p,q,r

  for side = 1,4 do
    if     side==1 then nx,ny,p,q= -1, 0,-dx, -x -- left
    elseif side==2 then nx,ny,p,q=  1, 0, dx,x+w -- right
    elseif side==3 then nx,ny,p,q=  0,-1,-dy, -y -- top
    else                nx,ny,p,q=  0, 1, dy,y+h -- bottom
    end

    if p==0 then
      if q<=0 then return nil end
    else
      r=q/p
      if p<0 then
        if     r>t2 then return nil
        elseif r>t1 then t1,nx1,ny1=r,nx,ny
        end
      else
        if     r<t1 then return nil
        elseif r<t2 then t2,nx2,ny2=r,nx,ny
        end
      end
    end
  end

  if intersect then
    -- aabb1 goes though aabb2, in the direction (forwards or backwards)
    -- select the smallest displacement
    if abs(t1)<=abs(t2) then
      t,nx,ny=t1,nx1,ny1
    else
      t,nx,ny=t2,nx2,ny2
    end
  elseif 0<=t1 and t1<=1 then
    t,nx,ny=t1,nx1,ny1
  else
    return nil
  end

  -- x1+dx*t alone will be inaccurate because of floating point
  -- use a more direct number for the "touch points" when possible
  tx=nx<0 and x2-w1 or nx>0 and x2+w2 or x1+dx*t
  ty=ny<0 and y2-h1 or ny>0 and y2+h2 or y1+dy*t

  return t,nx,ny,tx,ty,intersect
end

function colMove(x, y, l, mag, dir)
    local r = l/2
    local dx, dy, mint, nx, ny = 
        mag * cos(dir),
        mag * sin(dir),
        1,
        0,
        0

    for pass=1,2 do
        local minx, miny =
            x-r,
            y-r
        local goalx, goaly, ex, ey =
            minx + dx,
            miny + dy

        for ty=flr((min(miny, goaly))/8),flr(max(miny + l, goaly + l)/8) do 
        for tx=flr((min(minx, goalx))/8),flr(max(minx + l, goalx + l)/8) do 
        if solid_tile(tx,ty) then 
            local t, a, b, c, d = hit(minx, miny, l, l, tx*8, ty*8, 8, 8, goalx, goaly)
            if t and t < mint then
                mint, ex, ey = t, c, d
                if (dx != 0) nx = a
                if (dy != 0) ny = b
            end
        end
        end
        end

        if ex == nil then
            x += dx
            y += dy
            break
        end

        local rem = 1-mint 
        dx*=rem 
        dy*=rem 
        if (nx~=0) dx=0 
        if (ny~=0) dy=0
        if (dx==0 and dy==0) break
        x, y = ex + r, ey + r
    end

    return x, y, nx, ny
end