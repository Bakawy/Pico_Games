function updateCursor()
    cursorX, cursorY = stat(32), stat(33)
    leftMouseDown = btn(5)
    rightMouseDown = btn(4)
    if btnp(5) then
        for e in all(getClosestEntities(cursorX, cursorY)) do 
            if (e.onClick) then
                if dist(e.x,e.y,cursorX,cursorY) < e.r then
                    e:onClick()
                    break
                end
            end
        end
    end

    if btnp(4) then
        for e in all(getClosestEntities(cursorX, cursorY)) do 
            if (e.onRightClick) then
                if dist(e.x,e.y,cursorX,cursorY) < e.r then
                    e:onRightClick()
                    break
                end
            end
        end
    end
end

function drawCursor()  
    spr(1 + ((leftMouseDown or rightMouseDown) and 16 or 0), cursorX, cursorY)
end
