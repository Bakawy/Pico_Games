Enemy = Class:new({
	x = 64,
	y = 64,
	x_velocity = 0,
	y_velocity = 0,
	id = 0,
	dead = false,
	update = function(_ENV)
		local _ = 0
		local collided = false

		if abs(x_velocity) < speed_sweep_threshold then
			x, _, collided = simple_move_x(x, y, x_velocity)
		else
			x, _, collided = sweep_move_x(x, y, x_velocity)
		end

		if collided then
			x_velocity *= -1
		elseif not check_tile_stat(x + half_size * sgn(x_velocity), y + half_size + 1, 0) then
			x_velocity *= -1
			x += x_velocity
		end

		y_velocity += gravity
		if abs(y_velocity) < speed_sweep_threshold then
			y, y_velocity, collided = simple_move_y(x, y, y_velocity)
		else
			y, y_velocity, collided = sweep_move_y(x, y, y_velocity)
		end

		-- player collision
		if is_collide(x, y, player.x, player.y) then
			player:damage()
		end

		-- tile collisions (e.g., bombs)
		for tile in all(thrown_tiles) do
			if is_collide(x, y, tile.x, tile.y) then
			dead = true
			break
			end
		end
	end,
	draw = function(_ENV)
		spr(id, x - 4, y - 4)
	end,
})


function spawn_enemies()
	for x=0, 15 do
		for y=0, 15 do 
			local tile_id = mget(x, y)
			if tile_id == 2 then
				add(enemies, Enemy:new({x=x*8+4, y=y*8+4, id=2, x_velocity=0.25}))
				mset(x, y, 0)
			end
		end
	end
end

function move_enemies()
	for i = #enemies, 1, -1 do
		local e = enemies[i]
		e:update()
		if e.dead then deli(enemies, i) end
	end
end

function draw_enemies()
	for e in all(enemies) do
		e:draw()
	end
end