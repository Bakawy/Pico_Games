cursor = {
    x=64,
    y=64
}
function _init()
    poke(0x5f2d, 0x1 + 0x2)
    palt(0, false)
    palt(11, true)
end

function _update60()
    cls(7)
    cursor.x = stat(32)
    cursor.y = stat(33)

    local center = {x=64, y=64}
    local pointAngle = atan2(cursor.x - center.x, cursor.y - center.y)
    local length = 8

    line(center.x, center.y, center.x + length * cos(pointAngle), center.y + length * sin(pointAngle), 0)
end

function _draw()
    spr(1, cursor.x, cursor.y)

    print(flr(stat(1)*100).."% ram", 0, 0, 2)
    print(cursor.x.." "..cursor.y)
    print(tostr(btn(4)).." "..tostr(btn(5)))
end