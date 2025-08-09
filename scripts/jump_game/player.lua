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
	standing_on = {},
	move = function(_ENV)	
		local frict = 1.5
		local max_cayote_time = 5
		local grounded = false

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
		local old_y_velocity = y_velocity
		local collided = false
		if abs(y_velocity) < speed_sweep_threshold then
			y, y_velocity, collided = simple_move_y(x, y, y_velocity)
		else
			y, y_velocity, collided = sweep_move_y(x, y, y_velocity)
		end

		if old_y_velocity > 0 and collided then
			grounded = true
			cayote_time = max_cayote_time
		end

		if abs(x_velocity) < speed_sweep_threshold then
			x, x_velocity = simple_move_x(x, y, x_velocity)
		else
			x, x_velocity = sweep_move_x(x, y, x_velocity)
		end
		
		if hitstun <= 0 then
			x_velocity = abs(x_velocity) < frict and 0 or x_velocity - sgn(x_velocity)*frict
		end
		if not grounded and cayote_time > 0 then cayote_time -= 1 end
		if hitstun > 0 then hitstun -= 1 end
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
		if flr(hitstun / 3) % 2 == 0 then
			spr(1, x - 4, y - 4)
		end

		if grabbing != -1 then
			spr(grabbing, x - 4, y - 12)
		end

		if grappling and hook then
			line(x, y - 8, hook.x, hook.y, 7)
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
	damage = function(_ENV)
		local direction = 0.375
		local magnitude = 5
		x_velocity += cos(direction) * magnitude
		y_velocity += sin(direction) * magnitude
		hitstun = 10
	end,
	apply_inputs = function(_ENV)
		local speed = 1.5
		local jump_strength = 4
		if hitstun > 0 then return end

		if btn(L) then
			x_velocity -= speed
			facing = L
		elseif btn(R) then
			x_velocity += speed
			facing = R
		end

		if btnp(O) and (
			check_tile_stat(x - 3, y+5, 0) or
			check_tile_stat(x, y+5, 0) or
			check_tile_stat(x + 3, y+5, 0) or
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

		if btnp(X) then
			if btn(D) and grabbing == -1 then
				grabbable_tiles = {
					{state=check_tile_stat(x, y+5, 1), x=x, y=y+5},
					{state=check_tile_stat(x-3, y+5, 1), x=x-3, y=y+5},
					{state=check_tile_stat(x+3, y+5, 1), x=x+3, y=y+5},
				}
				for tile in all(grabbable_tiles) do
					if tile.state then
						local tx, ty = coordinate_to_tile(tile.x, tile.y)
						local tile_id = mget(tx, ty)
						mset(tx, ty, 0)
						grabbing = tile_id
						update_surrounding(tx, ty)
						break
					end
				end
			elseif btn(D) and grabbing != -1 then
				spawn_thrown_tile(grabbing, x, y - 8, 1, 0.75)
				grabbing = -1
				y_velocity = - jump_strength
				if grappling then
					grappling = false
					hook = nil
				end
			elseif btn(U) and grabbing != -1 then
				if grabbing == 18 then
					if not hook then
						fire_grapple(_ENV)
						grabbing = 16
					else
						grappling = false
						hook = nil
					end
				end
			elseif grabbing != -1 then
				spawn_thrown_tile(grabbing, x, y - 8, 3, facing == L and 0.375 or 0.125)
				grabbing = -1
				if grappling then
					grappling = false
					hook = nil
				end
			end
		end
	end,
})
