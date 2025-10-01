box_price_table = {
	[17] = 2,
	[18] = 2,
	[19] = 2,
	[20] = 2,
	[21] = 2,
	[22] = 2,
	[23] = 2,
	[24] = 2,
	[25] = 2,
	[26] = 2,
	[27] = 2,
	[28] = 2,
}
function normal_hit_floor(self)
	self.y_velocity = 0
	local tx, ty = coordinate_to_tile(self.x, self.y)
	local dir = nearest_axis(self.x) -- -1 left, +1 right
	local tx2 = coordinate_to_tile(self.x + dir*tile_size, self.y)
	if not fget(mget(tx, ty + 1), 0) then tx = tx2 end
	place_tile(tx, ty, self.id)
	self.dead = true
end

function spring_hit_floor(self)
	self.y_velocity *= -0.4
	self.x_velocity *= 0.4
	if abs(self.y_velocity) < 0.15 then
		local tx, ty = coordinate_to_tile(self.x, self.y)
		place_tile(tx, ty, self.id)
		self.dead = true
	end
end

function dash_hit_floor(self)
	self.y_velocity = 0
	self.x_velocity += 2 * sgn(self.x_velocity)
end

function vine_hit_floor(self)
	self.y_velocity = 0
	local tx, ty = coordinate_to_tile(self.x, self.y)
	local dir = nearest_axis(self.x) -- -1 left, +1 right
	local tx2 = coordinate_to_tile(self.x + dir*tile_size, self.y)
	if not fget(mget(tx, ty + 1), 0) then tx = tx2 end
	place_tile(tx, ty, game_state == 2 and 23 or 51)

	for i=ty-1,0,-1 do
		local id=mget(tx, i)
		if fget(id, 0) then break end
		place_tile(tx, i, 50)
	end
	self.dead = true
end

function clone_hit_floor(self)
	self.life = 20
	self.move = clone_move
	self.draw = clone_draw
	self.draw_effect = clone_effect
	self.grounded = true
	self.target_x = player.x
	self.target_y = player.y
	self.target_cd = 0
end

function lootbox_hit_floor(self)
	if not self.from_player then
		normal_hit_floor(self)
		return
	end
	self.dead = true
	spawn_thrown_tile(randint(17, 28), self.x, self.y, 1.5, 0.125, false)
	spawn_thrown_tile(randint(17, 28), self.x, self.y, 1.5, 0.375, false)
end

function sticky_hit_wall(self) --also used for dash
	local tx, ty = coordinate_to_tile(self.x, self.y)
	local dir = nearest_axis(self.y) -- -1 left, +1 right
	local _, ty2 = coordinate_to_tile(self.x, self.y + dir*tile_size)
	if not fget(mget(tx + sgn(self.x_velocity), ty), 0) then ty = ty2 end
	place_tile(tx, ty, self.id)
	self.dead = true
end

function bomb_hit_wall(self)
	explode(self.x, self.y, self.explosion_size)
	self.dead = true
	if game_state == 2 then 
		local mx, my = coordinate_to_tile(self.x, self.y)
		place_tile(mx, my, self.id)
		update_map_tile(mx, my)
	end
end

function sticky_hit_ceiling(self)
	self.y_velocity = 0
	local tx, ty = coordinate_to_tile(self.x, self.y)
	local dir = nearest_axis(self.x)
	local tx2 = coordinate_to_tile(self.x + dir*tile_size, self.y)
	if not fget(mget(tx, ty - 1), 0) then tx = tx2 end
	place_tile(tx, ty, self.id)
	self.dead = true
end

function water_effect(self)
	circfill(self.x, self.y, water_tile_radius, 12)
	circ(self.x, self.y, water_tile_radius, 1)
end

function lasso_effect(self)
	if self.move == normal_move then return end
	line(player.x, player.y, self.x, self.y, 4)
end

function clone_effect(self)
	local _ENV = self
	local base = sqrt(32)
	circfill(x, y, life + base, 2)
	circ(x, y, life + base, 13)
end

function normal_move(self)
	local _ENV = self
	y_velocity += gravity

	for tile in all(thrown_tiles) do
		if tile.id == 24 then
			if dist(x, y, tile.x, tile.y) < water_tile_radius then
				if y_velocity > 0 then y_velocity *= 0.2 end
				x_velocity *= 0.95
			end
		end
	end

	local collided = false
	y, _, collided = move_y(x, y, y_velocity)

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
		local dir = nearest_axis(x) -- -1 left, +1 right
		local tx2 = coordinate_to_tile(x + dir*tile_size, y)
		if not fget(mget(tx, ty - 1), 0) then tx = tx2 end
		if mget(tx, ty - 1) == 20 then
			place_tile(tx, ty, id)
			dead = true
			return
		else
			hit_ceiling(_ENV)
			if dead then return end
		end
	end

	collided = false
	x, _, collided = move_x(x, y, x_velocity)

	if collided then
		local tx, ty = coordinate_to_tile(x, y)
		local dir = nearest_axis(y) -- -1 left, +1 right
		local _, ty2 = coordinate_to_tile(x, y + dir*tile_size)
		if not fget(mget(tx + sgn(x_velocity), ty), 0) then ty = ty2 end
		if mget(tx + sgn(x_velocity), ty) == 20 then
			place_tile(tx, ty, id)
			dead = true
			return
		else
			hit_wall(_ENV)
			if dead then return end
		end
	end
end

function lasso_move(self)
	local _ENV = self
	if not from_player then 
		normal_move(_ENV) 
		return
	end
	y_velocity += gravity

	for tile in all(thrown_tiles) do
		if tile.id == 24 then
			if dist(x, y, tile.x, tile.y) < water_tile_radius then
				if y_velocity > 0 then y_velocity *= 0.2 end
				x_velocity *= 0.95
			end
		end
	end

	x += x_velocity
	y += y_velocity
	if (
		x < screen_left or
		x > screen_left + 128 or
		y < 0 or
		y > 128 
	) then
		if player.grabbing != -1 then
			player:normal_throw()
		end
		dead = true
		player.grabbing = id
	end
end

function clone_move(self)
	local _ENV = self
	local collided = false
	local frict = 1.5
	life -= 20/1200
	if life <= 0 then 
		dead = true
		if game_state == 2 then 
			local mx, my = coordinate_to_tile(self.x, self.y)
			place_tile(mx, my, self.id)
			update_map_tile(mx, my)
		end
		return
	end
	if abs(target_x - x) > 2 then
		x_velocity += 1.5 * sgn(target_x - x)
	end
	if target_y < y and grounded then
		y_velocity = -4
	end
	y_velocity += gravity


	x, x_velocity = move_x(x, y, x_velocity)

	local old_yv = y_velocity
	y, y_velocity, collided = move_y(x, y, y_velocity)
	grounded = false
	if old_yv > 0 and collided then
		grounded = true
	end
	x_velocity = abs(x_velocity) < frict and 0 or x_velocity - sgn(x_velocity)*frict
	if target_cd <= 0 then
		target_cd = 5
		target_x = player.x + rnd(32) - 16
		target_y = player.y
	else
		target_cd -= 1
	end
end

function normal_draw(self)
	local _ENV = self
	spr(id, x - 4, y-4)
end

function clone_draw(self)
	local _ENV = self
	pal({[3]=2})
	spr(1, x - 4, y - 4)
	pal()
end

Tile = Class:new({
	id=0,
	x=64,
	y=64,
	x_velocity=0,
	y_velocity=0,
	dead=false,
	from_player=false,
	move=normal_move,
	draw=normal_draw,
	draw_effect=function()end,
	hit_floor=normal_hit_floor,
	hit_wall=function(self)
		x_velocity = 0
	end,
	hit_ceiling=function(self)
		y_velocity = 0
	end,
})
tile_behaviors = {
    [17] = {hit_floor=bomb_hit_wall, explosion_size=20, hit_wall=bomb_hit_wall, hit_ceiling=bomb_hit_wall},
	[19] = {hit_floor=spring_hit_floor},
	[20] = {hit_wall=sticky_hit_wall, hit_ceiling=sticky_hit_ceiling},
	[22] = {hit_floor=dash_hit_floor, hit_wall=sticky_hit_wall},
	[23] = {hit_floor=vine_hit_floor},
	[24] = {draw_effect=water_effect},
	[25] = {move=lasso_move, draw_effect=lasso_effect},
	[26] = {hit_floor=clone_hit_floor},
	[27] = {hit_floor=lootbox_hit_floor},
}

function spawn_thrown_tile(id, x, y, velocity, direction, from_player)
	from_player = from_player == nil and true or from_player
	if x < 0 or y > 128 then return end
    local tile = Tile:new({
        id = id,
        x = x,
        y = y,
        x_velocity = velocity * cos(direction),
        y_velocity = velocity * sin(direction),
		from_player = from_player
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
		if tile.dead then del(thrown_tiles, tile)
		else
		tile:move()
		if tile.dead then del(thrown_tiles, tile) end end
	end
end

function explode(x, y, radius)
	local explosion_strength = 10
	local dist_from_player = dist(x, y, player.x, player.y)
	for tile in all(get_tiles_in_radius(x, y, radius)) do
		local cx, cy = tile.x * 8 + 4, tile.y * 8 + 4
		if fget(tile.id, 0) and not fget(tile.id, 2) then
			place_tile(tile.x, tile.y, 0)

			if tile.id == 17 then
				explode(cx, cy, radius)
			else
				local explosion_distance = dist(x, y, cx, cy)
				if explosion_distance > radius/2 then 
					local magnitude = ((radius - explosion_distance)/radius) * explosion_strength
					magnitude = mid(explosion_strength/2, magnitude, explosion_strength)
					local direction = atan2(cx - x, -abs(cy - y))
					spawn_thrown_tile(tile.id, cx, cy, magnitude, direction, false)
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

	for tile in all(thrown_tiles) do
		local explosion_distance = dist(x, y, tile.x, tile.y)
		if explosion_distance < radius/2 then
			tile.dead = true
		elseif explosion_distance < radius then
			local magnitude = ((radius - explosion_distance)/radius) * explosion_strength
			magnitude = mid(explosion_strength/2, magnitude, explosion_strength)
			local direction = atan2(tile.x - x, -abs(tile.y - y))
			tile.x_velocity += magnitude * cos(direction)
			tile.y_velocity += magnitude * sin(direction)
		end
	end

	for enemy in all(enemies) do
		if dist(enemy.x, enemy.y, x, y) < radius then
			local direction = atan2(enemy.x - x, -abs(enemy.y - y))
			enemy.dead = {direction, false, true}
		end
	end

	add(particles, Particles:new({x=x, y=y, size=radius * 2, delta_size=-2, frames=radius, sprite_id=64}))
end

function draw_thrown_tile_effects()
	for tile in all(thrown_tiles) do
		tile:draw_effect()
	end
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
			place_tile(tx, ty, 0)
			did_update = true
		end
	end

	if did_update then
		update_surrounding(tx, ty)
	end
end

function update_surrounding(tx, ty)
	update_map_tile(tx-1,ty)
	update_map_tile(tx+1,ty)
	update_map_tile(tx,ty-1)
	update_map_tile(tx,ty+1)
end

function nearest_axis(p) return (p%8>=4) and 1 or -1 end

function place_tile(x, y, id)
	if y > 15 then return end
	if game_state == 2 then
		for sale in all(shop_sales) do
			if x == sale.x and y == sale.y then
				return
			end
		end
	end

	local cx, cy = x * 8 + 4, y * 8 + 4
	if fget(mget(x, y), 5) and id != 0 and mget(x, y) != id then
		spawn_thrown_tile(id, cx, cy, 2, rnd(0.5), false)
	else
		mset(x, y, id)
	end
end