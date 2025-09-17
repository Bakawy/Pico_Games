local x = 64
local y = 64    

function getCursorPos()
    return x, y
end

function updateCursor()
    x, y = stat(32), stat(33)
    if btnp(5) then
        moons = getMoons()
        for moon in all(moons) do
            if dist(x, y, moon.x, moon.y) < moon.accuracyRadius + moon.size/2 then
                score += 1
                Point:new({x=x, y=y})
                break
            end
        end
    end
end

function drawCursor()
    spr(1, x, y)
end