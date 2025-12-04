function randDec(min, max) return rnd(max - min) + min end
function numVary(num, range) return num + randDec(-range, range) end
function copy(tbl) return pack(unpack(tbl)) end
function to(ax,ay,bx,by) return atan2(bx-ax, by-ay) end
--function dot(a1, a2) return cos(a1)*cos(a2) + sin(a1)*sin(a2) end
--function mirrorX(a) return atan2(-cos(a), sin(a)) end
--function mirrorY(a) return atan2(cos(a), -sin(a)) end
function within(min,x,max) return min<=x and x<=max end
function lerp(a, b, t) return a + (b - a) * mid(0, t, 1) end

--[[
t table
cmp function that returns a number sorted from lowest to highest output
i first element default 1
j last element default #t
]]
function qsort(t, cmp, i, j)
 i = i or 1
 j = j or #t
 if i < j then
  local p = i
  for k = i, j - 1 do
   if cmp(t[k], t[j]) <= 0 then
    t[p], t[k] = t[k], t[p]
    p = p + 1
   end
  end
  t[p], t[j] = t[j], t[p]
  qsort(t, cmp, i, p - 1)
  qsort(t, cmp, p + 1, j)  
 end
 return t
end
function dist(x1, y1, x2, y2)
    local dx, dy = x2 - x1, y2 - y1
    return sqrt(dx*dx + dy*dy)
end

function rspr(sx,sy,sw,sh,a,dx,dy,dw,dh)
    local sx,sy,sw,sh,a,dx,dy,dw,dh=
        sx or 0, sy or 0,
        sw or 8, sh or 8,
        a or 0,
        dx or 0, dy or 0,
        dw or 8, dh or 8
   
    local s1,c1,half_dw,half_dh = 
        sin(a+0.125),cos(a+0.125),
        dw/2,dh/2
    local x1,y1,x2,y2,x3,y3,x4,y4 = 
        half_dw*c1,half_dh*s1,
        half_dw*s1,half_dh*-c1,
        half_dw*-c1,half_dh*-s1,
        half_dw*-s1,half_dh*c1
   
    for y=0,dh-1 do
        local ty = y/dh
        local stx,sty,enx,eny = 
            x2+(x3-x2)*ty,y2+(y3-y2)*ty,
            x1+(x4-x1)*ty,y1+(y4-y1)*ty
        for x=0,dw-1 do
            local tx = x/dw
            local col = sget(sx+sw*tx,sy+sh*ty)
            if col ~= 0 then
                local px,py = stx+(enx-stx)*tx,sty+(eny-sty)*tx
                pset(dx+px,dy+py,col)
            end
        end
    end
end

function getClosestEntities(x, y)
    return qsort(copy(entities), function(a, b)
          return dist(a.x,a.y,x,y) - dist(b.x,b.y,x,y)
        end)
end