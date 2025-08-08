function normal_hit_floor(self)
	self.y_velocity = 0
	local tx, ty = coordinate_to_tile(self.x, self.y)
	mset(tx, ty, self.id)
	self.dead = true
end

function bomb_hit_floor(self)
	local tx, ty = coordinate_to_tile(self.x, self.y)
	mset(tx, ty, self.id)
	self.dead = true
	explode(self.x, self.y, self.explosion_size)
end

function spring_hit_floor(self)
	self.y_velocity *= -0.4
	self.x_velocity *= 0.4
	if abs(self.y_velocity) < 0.15 then
		local tx, ty = coordinate_to_tile(self.x, self.y)
		mset(tx, ty, self.id)
		self.dead = true
	end
end

function normal_hit_wall(self)
	self.x_velocity = 0
end

function bomb_hit_wall(self)
	explode(self.x, self.y, self.explosion_size)
	self.dead = true
end

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
			local tx, ty = coordinate_to_tile(x, y)
			if mget(tx, ty + 1) == 19 and y_velocity > 0.15 then
				y_velocity *= -1
			else
				hit_floor(_ENV)
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
				hit_wall(_ENV)
			else
				x = new_x
			end
		end
	end,
	draw=function(_ENV)
		spr(id, x - 4, y-4)
	end,
	hit_floor=normal_hit_floor,
	hit_wall=normal_hit_wall,
})
tile_behaviors = {
    [17] = {hit_floor=bomb_hit_floor, explosion_size=20, hit_wall=bomb_hit_wall},
	[19] = {hit_floor=spring_hit_floor}
}

function spawn_thrown_tile(id, x, y, velocity, direction)
    local tile = {
        id = id,
        x = x,
        y = y,
        x_velocity = velocity * cos(direction),
        y_velocity = velocity * sin(direction),
    }

    local behavior = tile_behaviors[id]
    if behavior then
        for k, v in pairs(behavior) do
            tile[k] = v
        end
    end

    add(thrown_tiles, Tile:new(tile))
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

	for enemy in all(enemies) do
		if dist(enemy.x, enemy.y, x, y) < radius then
			del(enemies, enemy)
		end
	end
end

function draw_thrown_tiles()
	for tile in all(thrown_tiles) do
		tile:draw()
	end
end