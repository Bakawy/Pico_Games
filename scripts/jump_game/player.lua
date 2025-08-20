Player = Class:new({
    x = 64,
    y = 64,
    x_velocity = 0,
    y_velocity = 0,
    cayote_time = 0,
    grabbing = -1,
    facing = L,
    grappling = false,
    hook = nil,
    hitstun = 0,
	invulnerable = 0,
	standing_on = {},
	grounded = false,
	stored_tile = -1,
	status = {}, --speed: speed multiplier,
	throwing = nil,
	health = 3,
	money = 0,
	move = function(_ENV)	
		local frict = 1.5
		local max_cayote_time = 5
		local gravity_multiplier = 1


		apply_inputs(_ENV)
		
		if grappling and hook and not hook.attached then
			local h = hook
			h.x += h.dx
			h.y += h.dy

			if check_tile_stat(h.x, h.y, 0) then
				h.attached = true
			end
		end

		apply_grapple_force(_ENV)
		
		y_velocity += gravity
		if grabbing == 21 then 
			y_velocity = min(y_velocity, 1)
		end
		if (
			mget(coordinate_to_tile(x - 3, y)) == 50 or
			mget(coordinate_to_tile(x, y)) == 50 or
			mget(coordinate_to_tile(x + 3, y)) == 50
		) then
			if y_velocity > 0 then y_velocity *= 0.7 end
			cayote_time = max_cayote_time
		end
		for tile in all(thrown_tiles) do
			if tile.id == 24 then
				if dist(x, y, tile.x, tile.y) < water_tile_radius then
					if y_velocity > 0 then y_velocity *= 0.4 end
					x_velocity *= 0.95
					cayote_time = max_cayote_time
				end
			elseif tile.id == 26 and tile.life then
				if dist(x, y, tile.x, tile.y) < tile.life + sqrt(32) then
					if stored_tile == -1 then stored_tile = 16 end
				end
			end
		end


		local old_y_velocity = y_velocity
		local collided = false
		y, y_velocity, collided = move_y(x, y, y_velocity)

		grounded = false
		if old_y_velocity > 0 and collided then
			if mget(coordinate_to_tile(x, y + 5)) == 58 then
				damage(_ENV)
			end
			grounded = true
			cayote_time = max_cayote_time
		end

		x, x_velocity = move_x(x, y, x_velocity)
		
		for s in all(status) do
			if s.length <= 0 then
				del(status, s)
			end
			s.length -= 1
		end
		if status.speed then frict *= status.speed.magnitude end
		if hitstun <= 0 then
			x_velocity = abs(x_velocity) < frict and 0 or x_velocity - sgn(x_velocity)*frict
		end
		if not grounded and cayote_time > 0 then cayote_time -= 1 end
		if hitstun > 0 then hitstun -= 1 end
		if invulnerable > 0 then invulnerable -= 1 end
		local tx, ty = coordinate_to_tile(x, y+5)
		standing_on = {
			mget(tx - 1, ty),
			mget(tx, ty),
			mget(tx + 1, ty),
		}
	end,
	apply_grapple_force = function(_ENV)
		if not grappling or not hook or not hook.attached then return end

		local dx = x - hook.x
		local dy = y - hook.y
		local dist = sqrt(dx*dx + dy*dy)
		local rest_len = 40

		if dist > rest_len then
			local stretch = dist - rest_len
			local nx = dx / dist
			local ny = dy / dist

			local tension = 0.05 

			local angle = atan2(dy, dx)
			local swing_force = gravity * sin(angle) 
			--print(swing_force, 64, 64, 7)
			--line(64, 64, 64 + swing_force * 30, 64, 2)
			
			local fx = -tension * stretch * nx - swing_force
			local fy = -tension * stretch * ny
			local max_velocity = 5
			fx = min(fx, max_velocity)
			fy = min(fy, max_velocity)

			x_velocity += fx
			y_velocity += fy
		end
	end,
	draw = function(_ENV)
		if flr(invulnerable / 3) % 2 == 0 then
			spr(1, x - 4, y - 4)
		end

		if grabbing != -1 then
			spr(grabbing, x - 4, y - 12)
		end

		if grappling and hook then
			line(x, y - 8, hook.x, hook.y, 7)
		end
		if throwing then
			local throw_power = 2 + 2 * throwing/100
			local throw_angle = 0.125
			throw_angle = facing == L and 0.5 - throw_angle or throw_angle
			local xv = throw_power * cos(throw_angle)
			local yv = throw_power * sin(throw_angle)
			local tx = x
			local ty = y - 8
			for i=1,6 do
				for j=1, 3 do
					yv += gravity
					tx += xv
					ty += yv
				end
				circfill(tx, ty, 1, 8)
			end
		end
	end,
	fire_grapple = function(_ENV)
		local hook_x = x
		local hook_y = y - 8
		local angle = 0.25 - (1/10)
		local speed = 5
		local hook_dx = cos(angle) * speed
		local hook_dy = sin(angle) * speed

		grappling = true
		hook = {
			x = hook_x,
			y = hook_y,
			dx = hook_dx,
			dy = hook_dy,
			attached = false
		}
	end,
	damage = function(_ENV, direction, magnitude)
		if invulnerable > 0 then return end
		direction = direction and direction or 0.375
		magnitude = magnitude and magnitude or 5
		x_velocity += cos(direction) * magnitude
		y_velocity += sin(direction) * magnitude
		hitstun = 10
		invulnerable = 30
	end,
	apply_inputs = function(_ENV)
		local speed = 1.5
		local jump_strength = 4
		if hitstun > 0 then return end

		if status.speed then speed *= status.speed.magnitude end
		if btn(L) then
			x_velocity -= speed
			facing = L
		elseif btn(R) then
			x_velocity += speed
			facing = R
		end	

		if btnp(U) and check_tile_stat(x, y, 4) then
			init_game(game_state % 2)
		end


		if false then
			--add(particles, Particles:new({x=64, y=64, size=10 * 2, delta_size=-2, frames=10, sprite_id=64}))
			local temp = stored_tile
			stored_tile = grabbing
			grabbing = temp
			return
		end

		if btn(O) and btnp(U) and (grabbing != -1 or stored_tile != -1) then
			local temp = stored_tile
			stored_tile = grabbing
			grabbing = temp	
			if grappling then
				grappling = false
				hook = nil
			end	
		end

		if btnp(O) then 
			if btn(U) and (grabbing != -1 or stored_tile != -1) then
				local temp = stored_tile
				stored_tile = grabbing
				grabbing = temp	
				if grappling then
					grappling = false
					hook = nil
				end
			elseif (
			on_ground(x, y) or
			cayote_time > 0 or
			grappling
			) then
				local tx, ty = coordinate_to_tile(x, y+5)
				local jump_strength_multiplier = 1
				if in_list(19, standing_on) then
					jump_strength_multiplier = 1.5
				end
				y_velocity = - jump_strength * jump_strength_multiplier
				if grappling then
					grappling = false
					hook = nil
				end
			end
		end

		if btnp(X) then
			if btn(D) and grabbing == -1 then
				local tx, ty = false, false
				if check_tile_stat(x, y+5, 1) then
					tx,ty=coordinate_to_tile(x, y+5)
				elseif check_tile_stat(x-3, y+5,1) then
					tx,ty=coordinate_to_tile(x-3, y+5)
				elseif check_tile_stat(x+3, y+5,1) then
					tx,ty=coordinate_to_tile(x+3, y+5)
				end
				if tx then
					local tile_id=mget(tx,ty)
					mset(tx,ty,0)
					grabbing=tile_id
					update_surrounding(tx,ty)
				end
				
				if game_state == 2 then
					for sale in all(shop_sales) do
						if sale.x == tx and sale.y == ty then
							if money >= box_price_table[grabbing] then
								money -= box_price_table[grabbing]
								del(shop_sales, sale)
							else
								mset(tx,ty,grabbing)
								grabbing = -1
							end
						end
					end
				end
			elseif btn(D) and grabbing != -1 then
				spawn_thrown_tile(grabbing, x, y - 8, 1, 0.75)
				if grabbing == 25 then
					thrown_tiles[#thrown_tiles].move = normal_move
				end

				y_velocity = - jump_strength * (grabbing == 19 and 1.25 or 1)
				grabbing = -1
				if grappling then
					grappling = false
					hook = nil
				end
			elseif btn(U) and grabbing != -1 then
				if grabbing == 18 then
					if not hook then
						fire_grapple(_ENV)
						if game_state != 2 then grabbing = 16 end
					else
						grappling = false
						hook = nil
					end
				elseif grabbing == 22 then
					local speed = 15
					x_velocity += speed * (facing == R and 1 or -1)
					if game_state != 2 then grabbing = 16 end
				elseif grabbing == 28 then
					health += 1
					grabbing = 16
				end
			elseif grabbing != -1 then
				--normal_throw(_ENV)
				throwing = 0
			end
		end

		if throwing then
			if btn(X) then
				throwing = min(throwing + 10, 100)
			else
				normal_throw(_ENV)
				throwing = nil
			end
		end
	end,
	normal_throw = function(_ENV)
		local throw_power = 2 + 2 * throwing/100
		local throw_angle  = 0.125

		spawn_thrown_tile(grabbing, x, y - 8, throw_power, facing == L and 0.5 - throw_angle or throw_angle)
		grabbing = -1
		if grappling then
			grappling = false
			hook = nil
		end
	end
})
