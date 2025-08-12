_G = _ENV
function _init()
	poke(0x5f5c, 255) 
	U=2
    D=3
    L=0
    R=1
    O=4
    X=5
	water_tile_radius = 24

	init_menu()
	
end

function _update60()
	cls()
	run_tasks()
	if game_state == 0 then
		update_menu()
	elseif game_state == 1 then
		player:move()
		move_tiles()
		move_enemies()
		update_particles()
	end
end

function _draw()
	if game_state == 0 then
		draw_menu()
	elseif game_state == 1 then
		draw_thrown_tile_effects()
		draw_environment()
		draw_thrown_tiles()
		player:draw()
		draw_enemies()
		draw_particles()
		draw_hud()
	end
	draw_debug()
end