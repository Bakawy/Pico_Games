Class = setmetatable({
	new = function(self, table)
		table = table or {}
		setmetatable(table, {__index = self})
		return table
	end,
},{__index = _ENV})

function init_game(environment)
	gravity = 0.3
	player = Player:new()
	game_state = 1
	thrown_tiles = {}
	enemies = {}
	particles = {}
	load_environment(environment)
	spawn_enemies()
end

function draw_debug()
	print(flr(stat(1)*100).."% ram", 0, 0, 2)
	if game_state == 1 then
		print(player.x_velocity)
		print("tiles: "..#thrown_tiles)
		print("particles: "..#particles)
		print("enemies: "..#enemies)
		if thrown_tiles[1] then
			print(thrown_tiles[1].grounded)
		end
	end
end

function draw_hud()
	local size = 9
	local margin = 2
	rect(128 - margin - size, margin, 128 - margin, margin + size, 7)
	palt(0, false)
	spr(player.stored_tile == -1 and 0 or player.stored_tile, 128 - margin - size + 1, margin + 1)
	palt()
end