Enemy = Class:new({
	x = 64,
	y = 64,
	x_velocity = 0,
	id = 0,
	dead = false,
	update = function(_ENV)
		local new_x = x + x_velocity
		if x_velocity ~= 0 then
			local offset = x_velocity > 0 and 4 or -4
			if check_tile_stat(new_x + offset, y, 0) then
			x = x_velocity > 0 and flr((new_x + 4)/8)*8 - 4
										or  flr((new_x - 4)/8 + 1)*8 + 4
			x_velocity = -x_velocity
			elseif not check_tile_stat(new_x + offset, y + 5, 0) then
			x_velocity = -x_velocity
			x += x_velocity
			else
			x = new_x
			end
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
	end
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