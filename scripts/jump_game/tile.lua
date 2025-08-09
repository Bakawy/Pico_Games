function normal_hit_floor(self)
	self.y_velocity = 0
	local tx, ty = coordinate_to_tile(self.x, self.y)
	local tx2 = coordinate_to_tile(
		(self.x % 8 >= 4) and (self.x + tile_size) or (self.x - tile_size),
		self.y
	)
	if not fget(mget(tx, ty + 1), 0) then tx = tx2 end
	mset(tx, ty, self.id)
	self.dead = true
end

function bomb_hit_floor(self)
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

function sticky_hit_wall(self)
	local _ = 0
	local dir = sgn(self.x_velocity)
	self.x_velocity = 0

	local tx, ty = coordinate_to_tile(self.x, self.y)
	local _, ty2 = coordinate_to_tile(
		self.x,
		(self.y % 8 >= 4) and (self.y + tile_size) or (self.y - tile_size)
	)
	if not fget(mget(tx + dir, ty), 0) then ty = ty2 end
	mset(tx, ty, self.id)
	self.dead = true
end

function bomb_hit_wall(self)
	explode(self.x, self.y, self.explosion_size)
	self.dead = true
end

function normal_hit_ceiling(self)
	self.y_velocity = 0
end

function sticky_hit_ceiling(self)
	self.y_velocity = 0
	local tx, ty = coordinate_to_tile(self.x, self.y)
	local tx2 = coordinate_to_tile(
		(self.x % 8 >= 4) and (self.x + tile_size) or (self.x - tile_size),
		self.y
	)
	if not fget(mget(tx, ty - 1), 0) then tx = tx2 end
	mset(tx, ty, self.id)
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

		local collided = false
		local _ = 0
		if abs(y_velocity) < speed_sweep_threshold then
			y, _, collided = simple_move_y(x, y, y_velocity)
		else
			y, y_velocity, collided = sweep_move_y(x, y, y_velocity)
		end

		if y_velocity > 0 and collided then
			local tx, ty = coordinate_to_tile(x, y)
			if mget(tx, ty + 1) == 19 and y_velocity > 0.15 then
				y_velocity *= -1
			else
				hit_floor(_ENV)
				if dead then return end
			end
		elseif y_velocity < 0 and collided then
			local tx, ty = coordinate_to_tile(x, y)
			local tx2 = coordinate_to_tile(
				(x % 8 >= 4) and (x + tile_size) or (x - tile_size),
				y
			)
			if not fget(mget(tx, ty - 1), 0) then tx = tx2 end
			if mget(tx, ty - 1) == 20 then
				mset(tx, ty, id)
				dead = true
				return
			else
				hit_ceiling(_ENV)
				if dead then return end
			end
		end

		collided = false
		if abs(x_velocity) < speed_sweep_threshold then
			x, _, collided = simple_move_x(x, y, x_velocity)
		else
			x, _, collided = sweep_move_x(x, y, x_velocity)
		end

		if collided then
			local tx, ty = coordinate_to_tile(x, y)
			local _ = 0
			local _, ty2 = coordinate_to_tile(
				x,
				(y % 8 >= 4) and (y + tile_size) or (y - tile_size)
			)
			if not fget(mget(tx + sgn(x_velocity), ty), 0) then ty = ty2 end
			if mget(tx + sgn(x_velocity), ty) == 20 then
				mset(tx, ty, id)
				dead = true
				return
			else
				hit_wall(_ENV)
				if dead then return end
			end
		end
	end,
	draw=function(_ENV)
		spr(id, x - 4, y-4)
	end,
	hit_floor=normal_hit_floor,
	hit_wall=normal_hit_wall,
	hit_ceiling=normal_hit_ceiling,
})
tile_behaviors = {
    [17] = {hit_floor=bomb_hit_floor, explosion_size=20, hit_wall=bomb_hit_wall},
	[19] = {hit_floor=spring_hit_floor},
	[20] = {hit_wall=sticky_hit_wall, hit_ceiling=sticky_hit_ceiling},
}

function spawn_thrown_tile(id, x, y, velocity, direction)
    local tile = Tile:new({
        id = id,
        x = x,
        y = y,
        x_velocity = velocity * cos(direction),
        y_velocity = velocity * sin(direction),
    })
	while check_tile_stat(tile.x, tile.y, 0) do
		tile:move()
	end

    local behavior = tile_behaviors[id]
    if behavior then
        for k, v in pairs(behavior) do
            tile[k] = v
        end
    end

    add(thrown_tiles, tile)
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
			update_surrounding(tile.x, tile.y)
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

	add(particles, Particles:new({x=x, y=y, size=radius * 2, delta_size=-2, frames=radius, sprite_id=64}))
end

function draw_thrown_tiles()
	for tile in all(thrown_tiles) do
		tile:draw()
	end
end

function update_map_tile(tx, ty)
	local tile_id = mget(tx, ty)
	if tile_id == 0 then return end
	local px, py = tx * 8 + 4, ty * 8 + 4
	local did_update = false

	--check if flying
	if not fget(mget(tx, ty + 1), 0) and not fget(tile_id, 3) then
		if not is_anchored(tx, ty) then
			spawn_thrown_tile(tile_id, px, py, 0, 0)
			mset(tx, ty, 0)
			did_update = true
		end
	end

	if did_update then
		update_surrounding(tx, ty)
	end
end

function update_surrounding(tx, ty)
	local update_other = {
		{tx - 1, ty},
		{tx + 1, ty},
		{tx, ty - 1},
		{tx, ty + 1},
	}
	for tile in all(update_other) do
		update_map_tile(tile[1], tile[2])
	end
end