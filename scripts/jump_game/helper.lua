function coordinate_to_tile(x, y)
	return flr(x / 8), flr(y / 8)
end

function dist(x1, y1, x2, y2)
	return sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

function is_collide(x1, y1, x2, y2)
    local half = 4 -- half of 8
    return abs(x1 - x2) < 8 and abs(y1 - y2) < 8
end

function get_tiles_in_radius(cx, cy, radius)
	local tiles = {}
	local r2 = radius * radius

	local tx = flr(cx / 8)
	local ty = flr(cy / 8)
	local tr = ceil(radius / 8)

	for y = ty - tr, ty + tr do
		for x = tx - tr, tx + tr do
			local px = x * 8 + 4
			local py = y * 8 + 4
			if (px - cx)^2 + (py - cy)^2 <= r2 then
				add(tiles, {x = x, y = y, id=mget(x, y)})
			end
		end
	end

	return tiles
end