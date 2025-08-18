Class = setmetatable({
	new = function(self, table)
		table = table or {}
		setmetatable(table, {__index = self})
		return table
	end,
},{__index = _ENV})

function init_game(type)
	if game_state == 2 then
		mset(22, 30, mget(14, 14))
		mset(22, 29, mget(14, 13))
		mset(21, 30, mget(13, 14))
		mset(21, 29, mget(13, 13))
	end

	gravity = 0.3
	if player then 
		player = Player:new({x=24, y=119, grabbing=player.grabbing, stored_tile=player.stored_tile})
	else
		player = Player:new({x=24, y=119})
	end
	game_state = type + 1
	thrown_tiles = {}
	enemies = {}
	particles = {}
	death_wall = nil
	screen_left = 0
	memset(0x2000, 0, 128*16)
	if type == 0 then --main game
		--copy_map(0, 16, 0, 0, 8, 16)
		generate_level()
		spawn_enemies()

		local max_speed = 1.25
		local ease_time = 12 --in seconds
		death_wall = {
			x = 0,
			speed = 0,
			acceleration = max_speed/(60*ease_time),
			max_speed = max_speed
		}
	elseif type == 1 then --shop
		level += 1
		update_score()
		copy_map(8, 16, 0, 0, 16, 16)
		mset(7, 14, randint(17, 26))
	end
end

function draw_debug()
	camera()
	print(flr(stat(1)*100).."% ram", 0, 0, 2)
	
	if game_state == 1 then
		print(screen_left)
		print(player.invulnerable)
		print(player.hitstun)
	end
end

function draw_hud()
	camera()
	--stored tile
	local size = 9
	local margin = 2
	rect(128 - margin - size, margin, 128 - margin, margin + size, 7)
	palt(0, false)
	spr(player.stored_tile == -1 and 0 or player.stored_tile, 128 - margin - size + 1, margin + 1)
	palt()

	--score
	local text = "score: "..flr(score)
	print("\#7\f0\-h"..text, 128 - 4 * #text - 1, 13)
end

function update_score()
	score = max(1024 * level + screen_left, score)
end