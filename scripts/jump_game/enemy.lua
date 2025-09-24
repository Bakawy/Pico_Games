function walker_behavior(self, x_collided, y_collided, xv, yv)
	local _ENV = self
	y_velocity = yv
	if x_collided then
		x_velocity *= -1
	elseif not check_tile_stat(x + half_size * sgn(x_velocity), y + half_size + 1, 0) then
		x_velocity *= -1
		x += x_velocity
	end
end
function flyer_behavior(self, x_collided, y_collided, xv, yv)
	local _ENV = self
	if screen_left + 192 < x then return end
	local frict = speed
	local bounce = 4

	if target.x != 1024 or x > 1000 then
		target = {x=player.x,y=player.y}
	end
	local direction = atan2(target.x - x,target.y - y)
	local frictx, fricty = abs(frict * cos(direction)), abs(frict * sin(direction))

	if x_collided then
		x_velocity += bounce * sgn(-x_velocity)
		y_velocity += bounce * rnd({-0.5, 0.5}) 
	end
	if y_collided then 
		y_velocity += bounce * sgn(-y_velocity) 
		x_velocity += bounce * rnd({-0.5, 0.5}) 
	end

	x_velocity = abs(x_velocity) < frictx and 0 or x_velocity - sgn(x_velocity)*frictx
	y_velocity = abs(y_velocity) < fricty and 0 or y_velocity - sgn(y_velocity)*fricty

	x_velocity += speed * cos(direction)
	y_velocity += speed * sin(direction)
end
function anchor_behavior(self, x_collided, y_collided, xv, yv)
	local _ENV = self
	local dx = x - anchor.x
	local dy = y - anchor.y
	local distance = sqrt(dx*dx + dy*dy)
	local rest_len = 40
	local angle = atan2(dx, dy)

	if distance > rest_len then
		local stretch = distance - rest_len
		local nx = dx / distance
		local ny = dy / distance

		local tension = 0.05 

		--local swing_force = gravity * sin(angle) 
		--print(swing_force, 64, 64, 7)
		--line(64, 64, 64 + swing_force * 30, 64, 2)
		
		local fx = -tension * stretch * nx --- swing_force
		local fy = -tension * stretch * ny
		local max_velocity = 5
		fx = min(fx, max_velocity)
		fy = min(fy, max_velocity)

		x_velocity += fx
		y_velocity += fy
	end

	y_velocity = yv
	x_velocity = abs(x_velocity) < abs(speed) and 0 or x_velocity - sgn(x_velocity)*abs(speed)

	if flr(distance) == flr(rest_len) then
		speed *= -1
	end

	local tx, ty = coordinate_to_tile(anchor.x, anchor.y)
	if mget(tx, ty) == 0 then
		local air_time, height, range = 30, y - anchor.y, anchor.x - x
		local v_x, v_y = range/air_time, -(height/air_time) + -0.5 * gravity * air_time
		dead = {atan2(v_x, v_y), dist(v_x, v_y, 0, 0), true}
	end

	if x_collided and y_collided then
		if not check_tile_stat(x + 8 * sgn(speed), y - 8, 0) then
			y_velocity -= 3
		else
			speed *= -1
		end
	end

	x_velocity += speed
end
function stealer_behavior(self, x_collided, y_collided, xv, yv)
	local _ENV = self--states: 0-wondering 1-chase 2-flee

	y_velocity = yv
	x_velocity = abs(x_velocity) < abs(speed) and 0 or x_velocity - sgn(x_velocity)*abs(speed)

	if state == 0 then
		can_see_player = true
		if abs(y - player.y) > 8 then can_see_player = false end
		for i=x,player.x,8 * sgn(player.x - x) do
			if not can_see_player then break end
			if check_tile_stat(i, y, 0) then
				can_see_player = false
			end
		end

		if x_collided or not check_tile_stat(x + half_size * sgn(speed), y + half_size + 1, 0) then speed *= -1 end

		if can_see_player and player.grabbing != -1 then 
			state = 1 
			speed *= 4
		end
	elseif state == 1 then
		speed = abs(speed) * sgn(player.x - x)
		if player.grabbing == -1 then
			state = 0
			speed = 0.25 * sgn(speed)
			x_velocity = 0
		end
	elseif state == 2 then
		speed = abs(speed) * sgn(x - player.x)
		if x_collided and y_collided then
			y_velocity -= 3
		end
	end

	x_velocity += speed
	if invulnerable > 0 then invulnerable -= 1 end
end
function shooter_behavior(self, x_collided, y_collided, xv, yv)
	local _ENV = self
	y_velocity = yv

	if reload <= 0 then
		reload = 60/fire_rate
		--y_velocity -= 3
		add(enemies, Enemy:new({
			x=x,
			y=y,
			id=87,
			apply_behavior=function(self, x_collided, y_collided, xv, yv)
				if x_collided or y_collided then
					self.dead = {0}
				end
			end,
			x_velocity = -0.75,
			gravity = 0,
		}))
	end
	reload -= 1
end
function flasher_behavior(self, x_collided, y_collided, xv, yv)
	local _ENV = self
	y_velocity = yv
	x_velocity = xv
	if state == 0 then
		x_velocity = speed * sgn(player.x - x)
		progress += 100/60
		if x_collided and y_collided then
			y_velocity -= 4
		end
	elseif state == 1 then
		progress += 100/120
		if progress >= 100 then
			state = 2
			progress = 0
		end
	elseif state == 2 then
		x_velocity = speed/2 * sgn(player.x - x)
		if x_collided and y_collided then
			y_velocity -= 4
		end

		progress += 100/300
		if progress >= 100 then
			state = 0
			progress = 0
		end
	end
end

function normal_enemy_draw(self)
	local _ENV = self
	if id == 82 then
		line(x, y, anchor.x, anchor.y, 5)
	end
	enemy_draw(_ENV, id, false)
end
function stealer_draw(self)
	local _ENV = self
	local sprite = id
	local x_flip = not (speed > 0) 
	if state == 0 then
		sprite = can_see_player and sgn(player.x - x) != sgn(speed) and 67 or 83
	elseif state == 1 then
		sprite = 68
	elseif state == 2 then
		sprite = 66
		spr(grabbing, x - 4, y - 12)
	end

	enemy_draw(_ENV, sprite, x_flip)
end
function hider_draw(self)
	local _ENV = self
	local sprite = 48
	local x_flip = player.x > x
	
	if dist(x, y, player.x, player.y) < 20 then
		sprite = id
	end
	
	enemy_draw(_ENV, sprite, x_flip)
end
function flasher_draw(self)
	local _ENV = self
	local sprite = 0
	local x_flip = player.x > x
	if state == 1 then 
		sprite = id
		if flr(progress % 3) != 0 then return end
	elseif state == 2 then 
		sprite = 70 
	else
		return
	end
	enemy_draw(_ENV, sprite, x_flip)
end
Enemy = Class:new({
	x = 64,
	y = 64,
	x_velocity = 0,
	y_velocity = 0,
	id = 0,
	dead = false,
	update = function(_ENV)
		local x_collided, y_collided = false, false
		local xv, yv = 0, 0

		x, xv, x_collided = sweep_move_x(x, y, x_velocity)

		y_velocity += gravity
		y, yv, y_collided = sweep_move_y(x, y, y_velocity)


		apply_behavior(_ENV, x_collided, y_collided, xv, yv)

		-- player collision
		if id == 87 then
			if player.x - 4 < x and x < player.x + 4 and player.y - 4 < y and y < player.y + 4 then
				dead = {0}
				player.status.speed = {magnitude = 0.75, length = 60}
			end
		elseif is_collide(x, y, player.x, player.y) then
			if id == 81 then
				player:damage()
				target = {x=1024, y=64}
				speed = 1
			elseif state == 2 and id == 83 and invulnerable <= 0 then
				dead = {x > player.x and 0.125 or 0.375, false, true}
				if player.grabbing != -1 then spawn_thrown_tile(x, y + 8, 3 * sgn(player.x_velocity), 0.125)
				else player.grabbing = grabbing end
			elseif id == 85 then
				dead = {x > player.x and 0.125 or 0.375, false, true}
			elseif id == 86 then
				if state == 0 and progress >= 100 then
					state = 1
					progress = 0
					x_velocity = 0
				elseif state == 2 then
					player:damage()
				end
			else
				player:damage()
			end
			if id == 83 and state == 1 then
				grabbing = player.grabbing
				player.grabbing = -1
				state = 2
				speed /= -2
				y_velocity -= 5
				invulnerable = 10
			end
		end

		-- tile collisions (e.g., bombs)
		for tile in all(thrown_tiles) do
			if is_collide(x, y, tile.x, tile.y) then
				local direction = atan2(x - tile.x, -abs(y - tile.y))
				dead = {direction, false, tile.from_player}

				if tile.id == 25 and tile.from_player then
					dead = "dont show"
					tile.dead = true
					player.x = x
					player.y = y
					player.x_velocity += tile.x_velocity + tile.y_velocity
					if player.grabbing != -1 then player:normal_throw() end
					player.grabbing = id + 16
				elseif id == 82 then
					dead = false
					tile.x_velocity *= 0.7
					tile.y_velocity = -abs(tile.y_velocity) * 0.7
				elseif id == 83 and fget(tile.id, 1) then
					dead = false
					tile.dead = true
					speed = 0.5
					state = 2
					grabbing = tile.id
				elseif id == 86 and state != 1 then
					dead = false
				elseif id == 87 then
					dead[3] = false
				end

				break
			end
		end
	end,
	draw = normal_enemy_draw,
	apply_behavior = walker_behavior,
})



function spawn_enemies()
	for x=0, 127 do
		for y=0, 15 do 
			local tile_id = mget(x, y)
			if tile_id == 115 then
				tile_id = rnd({80, 81, 82, 83, 84, 86})
			end

			if tile_id == 80 then
				add(enemies, Enemy:new({x=x*8+4, y=y*8+4, id=tile_id, x_velocity=0.25}))
				mset(x, y, 0)
			elseif tile_id == 81 then
				add(enemies, Enemy:new({
					x=x*8+4, 
					y=y*8+4, 
					id=tile_id, 
					apply_behavior=flyer_behavior, 
					gravity=0,
					speed=0.3,
					target={x=player.x, y=player.y}
				}))
				mset(x, y, 0)
			elseif tile_id == 82 then
				add(enemies, Enemy:new({
					x=x*8+4, 
					y=y*8-4, 
					id=tile_id, 
					apply_behavior=anchor_behavior, 
					speed=0.6,
					anchor={x=x*8+4, y=y*8+4}
				}))
				mset(x, y, 59)
			elseif tile_id == 83 then
				add(enemies, Enemy:new({
					x=x*8+4, 
					y=y*8+4, 
					id=tile_id, 
					apply_behavior=stealer_behavior, 
					draw=stealer_draw,
					speed=0.25,
					state=0,
					invulnerable=0,
				}))
				mset(x, y, 0)
			elseif tile_id == 84 then
				add(enemies, Enemy:new({
					x=x*8+4, 
					y=y*8+4, 
					id=tile_id, 
					apply_behavior=shooter_behavior, 
					fire_rate=0.75,
					reload=0,
				}))
				mset(x, y, 0)
			elseif tile_id == 85 then
				add(enemies, Enemy:new({
					x=x*8+4, 
					y=y*8+4, 
					id=tile_id, 
					apply_behavior=function(_ENV)end, 
					gravity = 0,
					draw=hider_draw,
				}))
				mset(x, y, 0)
			elseif tile_id == 86 then
				add(enemies, Enemy:new({
					x=x*8+4, 
					y=y*8+4, 
					id=tile_id, 
					apply_behavior=flasher_behavior,
					state=0,
					progress=0,
					draw=flasher_draw,
					speed=2
				}))
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
			local speed = e.dead[2] and e.dead[2] or 4
			if e.dead != "dont show" then
				add(particles, Particles:new({
					x=e.x, 
					y=e.y,
					x_velocity=cos(e.dead[1]) * speed,
					y_velocity=sin(e.dead[1]) * speed,
					y_acceleration=0.5,
					frames=60,
					sprite_id=e.id + 16,
				}))
			end

			if e.dead[3] or e.dead == "dont show" and e.id != 87 then
				player.money += 1
				add(particles, Particles:new({
					x=e.x, 
					y=e.y,
					y_velocity=-2,
					y_acceleration=2/15,
					frames=15,
					sprite_id=65,
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

function enemy_draw(self, sprite, flip)
	spr(sprite or self.id, self.x-4, self.y-4, 1, 1, flip)
end
