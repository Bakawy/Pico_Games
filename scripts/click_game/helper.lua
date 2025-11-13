function randDec(min, max)
    return rnd(max - min) + min
end
function numVary(num, range)
    return num + randDec(-range, range)
end
function copy(tbl)
    return pack(unpack(tbl))
end
function to(ax,ay,bx,by) return atan2(bx-ax, by-ay) end
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