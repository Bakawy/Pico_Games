do 

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
                collided = true
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
                collided = true
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

end