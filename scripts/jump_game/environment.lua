function load_environment(index)
	copy_map(index * 16, 16, 0, 0, 16, 16)
end

function draw_environment()
	map()
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

function generate_level() --chunks must be on the same column
	local chunks = get_chunks()
	copy_map(24, 16, 0, 0, 5, 16)
	local map_x = 4
	local end_x = 127 - 8
	while map_x < end_x do
		local chunk = rnd(chunks)
		if map_x + chunk.w >= end_x then 
			for i=0, end_x - map_x - 1 do
				mset(map_x, 0, 49)
				mset(map_x, 15, 49)
				map_x += 1
			end
			break
		end
		copy_map(chunk.x, chunk.y, map_x, 0, chunk.w, 16)
		map_x += chunk.w
	end
	copy_map(0, 16, map_x, 0, 8, 16)
	local excluded_sprites = {112, 113}
	for x=0, 127 do
		for y=0, 15 do
			if in_list(mget(x, y), excluded_sprites) then mset(x, y, 0) end
		end
	end
end

function get_chunks()
	local chunks = {} --x, y, w
	local current_chunk = {}
	for col=1,3 do
		local y = col*16
		for row=0,127 do
			local x = row
			if current_chunk.x then --recording
				if mget(x, y + 14) == 113 then
					current_chunk.w = x - current_chunk.x + 1
					add(chunks, current_chunk)
					current_chunk = {}
				end
			else --looking
				if mget(x, y + 14) == 112 then
					current_chunk.x, current_chunk.y = x, y
				end
			end
		end
		assert(not (current_chunk.x or current_chunk.w), "couldnt find end block") 
	end
	assert(#chunks != 0, "no chunks found")
	return chunks
end