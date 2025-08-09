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
end
