function updateCursor()
    cursorX, cursorY = stat(32), stat(33)

    if btnp(5) then
        local closeEntities = qsort(copy(entities), function(a, b)
          return dist(b.x,b.y,cursorX,cursorY) - dist(a.x,a.y,cursorX,cursorY)
        end)
        for e in all(closeEntities) do 
            if (e.onClick) then
                if dist(e.x,e.y,cursorX,cursorY) < e.r then
                    e:onClick()
                    break
                end
            end
        end
    end
end

function drawCursor()  
    spr(1, cursorX, cursorY)
end
