Enemy = Class:new({
	x = 64,
	y = 64,
	x_velocity = 0,
	y_velocity = 0,
	id = 0,
	dead = false,
	update = function(_ENV)
		local collided = false

		x, _, collided = move_x(x, y, x_velocity)

		if collided then
			x_velocity *= -1
		elseif not check_tile_stat(x + half_size * sgn(x_velocity), y + half_size + 1, 0) then
			x_velocity *= -1
			x += x_velocity
		end

		y_velocity += gravity
		y, y_velocity = move_y(x, y, y_velocity)

		-- player collision
		if is_collide(x, y, player.x, player.y) then
			player:damage()
		end

		-- tile collisions (e.g., bombs)
		for tile in all(thrown_tiles) do
			if is_collide(x, y, tile.x, tile.y) then
			local direction = atan2(x - tile.x, -abs(y - tile.y))
			dead = {cos(direction), sin(direction)}

			if tile.id == 25 and tile.from_player then
				dead = "dont show"
				tile.dead = true
				player.x = x
				player.y = y
				player.x_velocity += tile.x_velocity + tile.y_velocity
				if player.grabbing != -1 then player:normal_throw() end
				player.grabbing = id + 16
			end

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
			if tile_id == 80 then
				add(enemies, Enemy:new({x=x*8+4, y=y*8+4, id=tile_id, x_velocity=0.25}))
				mset(x, y, 0)
			end
		end
	end
end

function move_enemies()
	for i = #enemies, 1, -1 do
		local e = enemies[i]
		e:update()
		if e.dead then
			local speed = 4
			if e.dead != "dont show" then
				add(particles, Particles:new({
					x=e.x, 
					y=e.y,
					x_velocity=e.dead[1] * speed,
					y_velocity=e.dead[2] * speed,
					y_acceleration=0.5,
					frames=60,
					sprite_id=e.id + 16,
				}))
			end
			deli(enemies, i) 
		end
	end
end

function draw_enemies()
	for e in all(enemies) do
		e:draw()
	end
end