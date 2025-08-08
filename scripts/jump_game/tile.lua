Tile = Class:new({
	id=0,
	x=64,
	y=64,
	x_velocity=0,
	y_velocity=0,
	dead=false,
	move=function(_ENV)
		local explosion_size = 20
		y_velocity += gravity

		local new_y = y + y_velocity
		if y_velocity > 0 and (
			--is_solid_tile(x - 3, new_y + 4) or
			check_tile_stat(x, new_y + 4, 0) --or
			--is_solid_tile(x + 3, new_y + 4)
		) then
			y = flr((new_y + 4) / 8) * 8 - 4
			y_velocity = 0
			local tx, ty = coordinate_to_tile(x, y)
			mset(tx, ty, id)
			dead = true
			if id == 17 then
				explode(x, y, explosion_size)
			end
		elseif y_velocity < 0 and (
			check_tile_stat(x - 3, new_y - 4, 0) or
			check_tile_stat(x, new_y - 4, 0) or
			check_tile_stat(x + 3, new_y - 4, 0) 
		) then
			y = flr((new_y - 4) / 8 + 1) * 8 + 4
			y_velocity = 0
		else
			y = new_y
		end

		local new_x = x + x_velocity
		if x_velocity != 0 then
			local offset = x_velocity > 0 and 4 or -4
			if check_tile_stat(new_x + offset, y, 0) then
				if x_velocity > 0 then
					x = flr((new_x + 4) / 8) * 8 - 4
				else
					x = flr((new_x - 4) / 8 + 1) * 8 + 4
				end
				x_velocity = 0
				if id == 17 then
					explode(x, y, explosion_size)
					dead = true
				end
			else
				x = new_x
			end
		end
	end,
	draw=function(_ENV)
		spr(id, x - 4, y-4)
	end,
})
function spawn_thrown_tile(id, x, y, velocity, direction)
	add(thrown_tiles, Tile:new({
		id=id, 
		x=x, 
		y=y, 
		x_velocity=velocity * cos(direction),
		y_velocity=velocity * sin(direction),
	}))
end

function move_tiles()
	for tile in all(thrown_tiles) do
		tile:move()
		if tile.dead then del(thrown_tiles, tile) end
	end
end

function explode(x, y, radius)
	local explosion_strength = 10
	local dist_from_player = dist(x, y, player.x, player.y)
	for tile in all(get_tiles_in_radius(x, y, radius)) do
		local cx, cy = tile.x * 8 + 4, tile.y * 8 + 4
		if check_tile_stat(cx, cy, 0) and not check_tile_stat(cx, cy, 2) then
			mset(tile.x, tile.y, 0)

			if tile.id == 17 then
				explode(cx, cy, radius)
			else
				local explosion_distance = dist(x, y, cx, cy)
				if explosion_distance > radius/2 then 
					local magnitude = ((radius - explosion_distance)/radius) * explosion_strength
					magnitude = mid(explosion_strength/2, magnitude, explosion_strength)
					local direction = atan2(cx - x, -abs(cy - y))
					spawn_thrown_tile(tile.id, cx, cy, magnitude, direction)
				end
			end
		end
	end

	if dist_from_player < radius then
		local magnitude = ((radius - dist_from_player)/radius) * explosion_strength
		magnitude = mid(explosion_strength/2, magnitude, explosion_strength)
		local direction = atan2(player.x - x, -abs(player.y - y))
		player.x_velocity += cos(direction) * magnitude
		player.y_velocity += sin(direction) * magnitude
	end
end

function draw_thrown_tiles()
	for tile in all(thrown_tiles) do
		tile:draw()
	end
end