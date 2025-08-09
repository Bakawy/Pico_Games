function _init()
	U=2
    D=3
    L=0
    R=1
    O=4
    X=5

	init_menu()
	
end

function _update60()
	cls()
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
		draw_environment()
		draw_thrown_tiles()
		player:draw()
		draw_enemies()
		draw_particles()
	end
	draw_debug()
end