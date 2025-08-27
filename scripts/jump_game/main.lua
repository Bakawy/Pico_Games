_G = _ENV
function _init()
	poke(0x5f5c, 255)
	cartdata("jump_game") 
	U=2
    D=3
    L=0
    R=1
    O=4
    X=5
	water_tile_radius = 24
	screen_left = 0
	score = 0
	highscore = dget(0)
	level = 0
	seed = ""
	for i=1,8 do
		seed ..= tostr(randint(0,5))
	end

	init_menu()
	
end

function _update60()
	cls()
	run_tasks()
	if game_state == 0 then
		update_menu()
	elseif game_state == 1 then
		update_score()
		player:move()
		move_tiles()
		move_enemies()
		update_death_wall()
		update_particles()
	elseif game_state == 2 then
		player:move()
		move_tiles()
		update_particles()
	end
end

function _draw()
	if game_state == 0 then
		draw_menu()
	elseif game_state == 1 then
		local player_range = {64, 64}--{24, 48}
		if player.x - screen_left < player_range[1] then
			screen_left = mid(0, player.x - player_range[1], 888)
		elseif player.x - screen_left > player_range[2] then
			screen_left = mid(0, player.x - player_range[2], 888)
		end
		if death_wall then
			screen_left = mid(screen_left, death_wall.x - player_range[1], 888)
		end
		camera(screen_left, 0)
		draw_thrown_tile_effects()
		draw_environment()
		draw_thrown_tiles()
		player:draw()
		draw_enemies()
		draw_death_wall()
		draw_particles()
		draw_hud()
	elseif game_state == 2 then
		draw_thrown_tile_effects()
		draw_environment()
		draw_shop()
		draw_thrown_tiles()
		player:draw()
		draw_particles()
		draw_hud()
	end
	draw_debug()
end