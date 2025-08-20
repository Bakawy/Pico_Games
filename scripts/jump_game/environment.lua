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
	srand(seed..level)
	local chunks = get_chunks()
	local last_chunk = 0
	copy_map(24, 16, 0, 0, 5, 16)
	local map_x = 4
	local end_x = 127 - 8
	while map_x < end_x do
		local chunk = 0
		while chunk == last_chunk or chunk == 0 do chunk = rnd(chunks) end
		last_chunk = chunk
		if map_x + chunk.w >= end_x then 
			for i=0, end_x - map_x - 1 do
				mset(map_x, 0, 49)
				mset(map_x, 15, 49)
				if i == end_x - map_x - 1 then
					mset(map_x, 14, 80)
				end
				map_x += 1
			end
			break
		end
		for i=0,randint(0, min(7, end_x - (map_x + chunk.w))) do
			mset(map_x, 0, 49)
			mset(map_x, 15, 49)
			map_x += 1
		end
		copy_map(chunk.x, chunk.y, map_x, 0, chunk.w, 16)
		if rnd(1) < 0.5 then -- add block
			local box_spots = {}
			for x=map_x, map_x + chunk.w do
				for y=1, 15 do
					if mget(x, y) == 48 and mget(x, y - 1) == 0 then
						add(box_spots, {x=x, y=y})
					end
				end
			end
			if #box_spots > 0 then
				local spot = rnd(box_spots)
				mset(spot.x, spot.y, 16)
			end
		end
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

function draw_shop()
	rect(103, 103, 120, 120, 4)
	print("\#1\f4\-hstorage", 98, 96)
	print("\#0\f7\-hseed: "..num_to_inputs(seed), 8, 66)

	for sale in all(shop_sales) do
		local id = mget(sale.x, sale.y)
		local cx, cy = sale.x * 8 + 4, sale.y * 8 + 4
		local text = ""..box_price_table[id]
		local text_len = 4 * #text
		print(text, cx - (text_len + 8)/2, cy - 12, 7)
		spr(65, cx - (text_len + 8)/2 + 4 * #text, cy - 14)
	end
end

function update_death_wall()
	if not death_wall then return end
	death_wall.speed = min(death_wall.speed + death_wall.acceleration, death_wall.max_speed)
	death_wall.x = min(death_wall.x + death_wall.speed, 976)

	if player.invulnerable <= 0 then
		if player.x - 4 < death_wall.x and player.health > 1 then
			player:damage(0.2)
			player.health -= 1
			death_wall.acceleration = death_wall.max_speed/(60 * 3)
			death_wall.speed *= 0.5
			if player.x + 4 < death_wall.x then
				player.x = death_wall.x - 4
			end
		elseif player.x + 4 < death_wall.x then
			dset(0, flr(highscore))
			run()
		end
	end

	for enemy in all(enemies) do
		if enemy.x - 4 < death_wall.x then
			enemy.dead = {1, -1}
		end
	end
end

function draw_death_wall()
	rectfill(0, 0, death_wall.x, 128, 8)
end