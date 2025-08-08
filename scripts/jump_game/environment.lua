function load_environment(index)
	copy_map(index * 16, 16, 0, 0, 16, 16)
end

function draw_environment()
	map(0,0,0,0,16,16)
end

function check_tile_stat(x, y, stat)
	local tx, ty = coordinate_to_tile(x, y)
	local tile = mget(tx, ty)
	return fget(tile, stat)
end

function copy_map(sx, sy, dx, dy, w, h)
	local map_w = 128 -- total width of map in tiles
	local src_addr = 0x2000 + sy * map_w + sx
	local dst_addr = 0x2000 + dy * map_w + dx

	for row = 0, h - 1 do
		memcpy(dst_addr + row * map_w, src_addr + row * map_w, w)
	end
end