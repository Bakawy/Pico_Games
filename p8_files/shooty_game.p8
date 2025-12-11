pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
function _init()
	x=64
	y=64
	hp=3
	facing={x="n",y="n"}
	input={
		l=false,
		r=false,
		u=false,
		d=false,
		o=false,
		x=false
	}
	isshoot=false
	isdead=false
	shootcooldown=0
	iframes=0
	killcount=0
	weapon=1

	typetable = {
		{hp=1, speed=0.35},
		{hp=3, speed=0.15},
		{hp=1, speed=0.55},
		{hp=2, speed=0.1},
	}
	weapontable = {
		{speed=2, range=64, shots=1, dmg=1, firerate=0.25},
		{speed=1.5, range=32, shots=3, dmg=0.5, firerate=0.5},
	}

	bullets={}
	enemies={}
end

function _update60()
	checkinput()
	if not isdead then
		moveplayer() 
		if isshoot then playershoot() end
	end
	moveenemies()
	movebullets()
	if #enemies<flr(2+killcount/15) then spawnenemy() end
	checkcollisions()
end

function _draw()
	cls()
	drawbullets()
	drawenemies()
	if not isdead then drawplayer() end
	print("hp: "..hp)
	print("score: "..killcount)
	--drawdebug()
end
-->8
function getinputvector()
	local dx = (input.r and 1 or 0) - (input.l and 1 or 0)
	local dy = (input.u and 1 or 0) - (input.d and 1 or 0)
	return dx, dy
end

function checkinput()
	input={
		l=false,
		r=false,
		u=false,
		d=false,
		o=false,
		x=false
	}
	if btn(➡️) then
		input.r = true
	end
	if btn(⬅️) then
		input.l = true
	end
	if btn(⬆️) then
		input.u = true
	end
	if btn(⬇️) then
		input.d = true
	end
	if btn(🅾️) then
		input.o = true
	end
	if btnp(❎) then
		input.x = true
	end
end

function moveplayer()
	local speed = 0.75
	isshoot = input.o
	shootcooldown -= 1
	iframes -= 1

	if input.x then
		weapon = (weapon % #weapontable) + 1 
		sfx(4)
	end

	if isshoot and facing.x=="n" and facing.y=="n" then facing={x="r",y="n"} end

	if not isshoot then
		facing={x="n",y="n"}
		if input.r then
			facing.x = "r"
		elseif input.l then
			facing.x = "l"
		end
		if input.u then
			facing.y = "u"
		elseif input.d then
			facing.y = "d"
		end
	end

	local dx, dy = getinputvector()
	if dx~=0 or dy~=0 then
		local dir=atan2(dx,dy)
		x += speed*cos(dir)
		y -= speed*sin(dir)
	end
end

function playershoot()
	local dx = 0
	local dy = 0

	local speed=weapontable[weapon].speed
	local range=weapontable[weapon].range
	local shots=weapontable[weapon].shots
	local dmg=weapontable[weapon].dmg
	local firerate=weapontable[weapon].firerate

	if shootcooldown>0 then return
	else shootcooldown=firerate*60 end

	if facing.x=="r" then dx=1
	elseif facing.x=="l" then dx=-1 end
	if facing.y=="u" then dy=1
	elseif facing.y=="d" then dy=-1 end

	if shots == 1 then
		shoot(x, y, atan2(dx, dy), range, speed, dmg)
	else
		local dir = atan2(dx, dy)
		local spread = 0.1

		for i = 0, shots - 1 do
			local offset = -spread / 2 + (i / (shots - 1)) * spread
			shoot(x, y, dir + offset, range, speed, dmg)
		end
	end
end
-->8
function shoot(x, y, dir, range, speed, dmg)
	sfx(0)
	add(bullets, {
		x=x,
		y=y,
		startx=x,
		starty=y,
		dir=dir,
		range=range*range,
		speed=speed,
		dmg=dmg,
	})
end

function movebullets()
	for b in all(bullets) do
		b.x += b.speed * cos(b.dir)
		b.y -= b.speed * sin(b.dir)

		local dx = b.x - b.startx
		local dy = b.y - b.starty
		local dist_sq = dx*dx + dy*dy

		if dist_sq > b.range then
			del(bullets, b)
		end
	end
end
-->8
function pickenemytype()
	local weights = {}
	local max_type = #typetable

	for i = 1, max_type do
		local base = (max_type - i + 1)^2 * 20
		local scaling = flr(sqrt(killcount)) * (i - 1)^1.2
		weights[i] = base + scaling
	end

	local total = 0
	for i=1,max_type do
		total += weights[i]
	end

	local roll = rnd(total)
	local sum = 0
	for i=1,max_type do
		sum += weights[i]
		if roll < sum then return i end
	end
end




function spawnenemy(t, x, y)
	local type = t and t or pickenemytype()
	local data = typetable[type]

	local enemy = {
		x = x and x or rnd({10, 118}),
		y = y and y or rnd({10, 118}),
		type = type
	}

	-- merge in the type-specific data
	for k,v in pairs(data) do
		enemy[k] = v
	end

	add(enemies, enemy)
end

function moveenemies()
	for e in all(enemies) do
		local variance = 1/3
		local dir=atan2(x-e.x,y-e.y) + rnd(variance)-variance/2
		e.x += e.speed * cos(dir)
		e.y += e.speed * sin(dir)
	end
end
-->8
function collide(a, b)
	local a_left   = a.x - a.w / 2
	local a_right  = a.x + a.w / 2
	local a_top    = a.y - a.h / 2
	local a_bottom = a.y + a.h / 2

	local b_left   = b.x - b.w / 2
	local b_right  = b.x + b.w / 2
	local b_top    = b.y - b.h / 2
	local b_bottom = b.y + b.h / 2

	return a_right > b_left and
	       a_left < b_right and
	       a_bottom > b_top and
	       a_top < b_bottom
end


function checkcollisions()
	--bullet to enemy
	for b in all(bullets) do
		for e in all(enemies) do
			if collide({x=b.x,y=b.y,w=2,h=2}, {x=e.x,y=e.y,w=8,h=8}) then
				e.hp -= b.speed
				sfx(3)
				del(bullets, b)
				if e.hp <= 0 then
					killcount += 1
					sfx(2)
					del(enemies, e)
					if e.type == 4 then
						spawnenemy(1, e.x-5, e.y)
						spawnenemy(1, e.x+5, e.y)
					end
				end
				break
			end
		end
	end
	if isdead or iframes > 0 then return end
	--enemy to player
	for e in all(enemies) do
		if collide({x=e.x,y=e.y,w=8,h=8}, {x=x,y=y,w=8,h=8}) then
			hp -= 1
			iframes = 60
			if hp <= 0 then isdead = true end
			sfx(1)
		end
	end
end
-->8
function drawplayer()
	local spr_id = 4         -- idle
	local flip_x = false
	local flip_y = false

	-- diagonal check comes first
	if facing.x ~= "n" and facing.y ~= "n" then
		spr_id = 3
		flip_x = (facing.x == "l")
		flip_y = (facing.y == "d")

	elseif facing.x == "r" then
		spr_id = 1
	elseif facing.x == "l" then
		spr_id = 1
		flip_x = true
	elseif facing.y == "u" then
		spr_id = 2
	elseif facing.y == "d" then
		spr_id = 2
		flip_y = true
	end

	if iframes>0 then pal({[7]=10}) end

	spr(spr_id, x-4, y-4, 1, 1, flip_x, flip_y)
	pal()
end

function drawenemies()
	local colortable = {
		{},
		{[8]=12},
		{[8]=10},
		{[8]=15},
	}
	for e in all(enemies) do
		pal(colortable[e.type])
		spr(6, e.x-4, e.y-4)
		pal()
	end
end

function drawbullets()
	for b in all(bullets) do
		spr(5, b.x-4, b.y-4)
	end
end

function drawdebug()
	for i,b in pairs(input) do
		print(""..i..": "..tostring(b))
	end
	print(facing.x..facing.y)
end
__gfx__
00000000007777000077770000777700007777000000000000888800000000000000000000000000000000000000000000000000000000000000000000000000
00000000077777700777777007770770077777700000000008888880000000000000000000000000000000000000000000000000000000000000000000000000
00700700777770777707707777777777777777770000000087888878000000000000000000000000000000000000000000000000000000000000000000000000
0007700077777777777777777777770777077077000aa00087788778000000000000000000000000000000000000000000000000000000000000000000000000
0007700077777777777777777777777777777777000aa00088888888000000000000000000000000000000000000000000000000000000000000000000000000
00700700777770777777777777777777777777770000000088777788000000000000000000000000000000000000000000000000000000000000000000000000
00000000077777700777777007777770077777700000000008788780000000000000000000000000000000000000000000000000000000000000000000000000
00000000007777000077770000777700007777000000000000888800000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
02010000156501565015640156401463012620106200d6100a6100461002610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01020000355503555034550335503254032540315302e5302b53025530215201d5201752013510095100051000500005000050000500005000050000500005000050000500005000050000500005000050000500
000200003c0703c0603c0503c0403c0303c0203c01000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000100001d7501d7501c7501b7501a7401a7401973016730137300d73009720057200b70007700097000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
030200003864038630386203861000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
