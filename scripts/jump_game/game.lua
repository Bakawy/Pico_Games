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
		player.x = 24
		player.y = 116
	else
		player = Player:new({x=24, y=116})
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

		local max_speed = min(1.15 + (0.03 * level), 1.5)
		local ease_time = max(12 - 3 * level, 2) --in seconds
		death_wall = {
			x = -16,
			speed = 0,
			acceleration = max_speed/(60*ease_time),
			max_speed = max_speed
		}
	elseif type == 1 then --shop
		level += 1
		update_score()
		copy_map(8, 16, 0, 0, 16, 16)
		mset(6, 14, randint(17, 28))
		mset(9, 14, randint(17, 28))
		shop_sales = {
			{x=6, y=14},
			{x=9, y=14},
		}
	end
end

function draw_debug()
	camera()
	print(flr(stat(1)*100).."% ram", 0, 0, 2)
	
	if game_state == 1 then
		print(count(player.status))
		foreach(player.status, print)
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
	--health
	text = "hp: "..player.health
	print("\#7\f0\-h"..text, 128 - 4 * #text - 1, 20)
	--money
	text = ""..player.money
	rectfill(106 - #text * 4, 2, 116, 11, 7)
	spr(65, 108, 3)
	print(text, 107 - #text * 4, 5, 0)
	--deathwall indicator
	if death_wall then
		if death_wall.x < screen_left then
			circfill(16, 64, 7, 8)
			spr(114, 5, 57)
			spr(114, 5, 64, 1, 1, false, true)
			local text = ""..flr(screen_left - death_wall.x)
			print(text, 16 - 2 * #text + 1, 62, 7)
		end
	end
end

function update_score()
	score = max(1024 * level + screen_left, score)
	highscore = max(score, highscore)
end