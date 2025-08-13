Class = setmetatable({
	new = function(self, table)
		table = table or {}
		setmetatable(table, {__index = self})
		return table
	end,
},{__index = _ENV})

function init_game(type)
	gravity = 0.3
	player = Player:new({x=24, y=119})
	game_state = type + 1
	thrown_tiles = {}
	enemies = {}
	particles = {}
	spawn_enemies()
	memset(0x2000, 0, 128*16)
	if type == 0 then --main game
		--copy_map(0, 16, 0, 0, 8, 16)
		generate_level()
	elseif type == 1 then --shop
		copy_map(8, 16, 0, 0, 16, 16)
	end
end

function draw_debug()
	camera()
	print(flr(stat(1)*100).."% ram", 0, 0, 2)
	
	if game_state == 1 then
		print(screen_left)
	end
end

function draw_hud()
	camera()
	local size = 9
	local margin = 2
	rect(128 - margin - size, margin, 128 - margin, margin + size, 7)
	palt(0, false)
	spr(player.stored_tile == -1 and 0 or player.stored_tile, 128 - margin - size + 1, margin + 1)
	palt()
end