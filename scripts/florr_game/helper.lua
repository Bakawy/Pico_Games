function lerp(a, b, t)
    return a + (b - a) * t
end

--[[
function lerpAngle(a, b, t)
    diff = (b - a) % 1
    shortDiff = (2 * diff) % 1 - diff
    return a + shortDiff * t
end
]]