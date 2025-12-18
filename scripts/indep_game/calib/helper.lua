function scaleSprite(s, x, y, w, h)
    sspr((s % 16) * 8, flr(s / 16) * 8, 8, 8, x, y, w, h)
end

function interpolate(a, b, t, func)
    return a + (b - a) * func(mid(0, t, 1))
end

function linear(x) return x end
function easeInQuad(x) return x * x end

function easeOutQuad(x)
    return 1 - (1 - x) * (1 - x)
end

function easeOutExpo(x)
    return x == 1 and 1 or 1 - (2 ^ (-10 * x))
end

function beatToSec(beat)
    return beat * 60/bpm
end

function secToBeat(sec)
    return sec * bpm/60
end

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