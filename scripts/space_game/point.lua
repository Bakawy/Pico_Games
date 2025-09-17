Point = Class:new({
    x  = 64,
    y = 64,
    color = 7,
    draw = function(self)
        circfill(self.x, self.y, 2, self.color)
    end,
})
points = {}

function Point:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    add(points, o)
    return o
end

function getPoints()
    return points
end

function drawPoints()
    local x, y = nil, nil
    for point in all(points) do
        point:draw()
        if x then
            line(x, y, point.x, point.y, point.color)
        end
        x, y = point.x, point.y
    end
end