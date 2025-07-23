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
	if #enemies<flr(2+killcount/10) then spawnenemy() end
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
	if btn(❎) then
		input.x = true
	end
end

function moveplayer()
	local speed = 0.75
	isshoot = input.o
	shootcooldown -= 1
	iframes -= 1

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

	local dx=0
	local dy=0
	if input.r then dx += 1 end
	if input.l then dx -= 1 end
	if input.u then dy += 1 end
	if input.d then dy -= 1 end
	if dx~=0 or dy~=0 then
		local dir=atan2(dx,dy)
		x += speed*cos(dir)
		y -= speed*sin(dir)
	end
end

function playershoot()
	local dx=0
	local dy=0
	local firerate=0.25 --seconds per shot

	if shootcooldown>0 then return
	else shootcooldown=firerate*60 end

	if facing.x=="r" then dx=1
	elseif facing.x=="l" then dx=-1 end
	if facing.y=="u" then dy=1
	elseif facing.y=="d" then dy=-1 end

	shoot(x, y, atan2(dx, dy))
end
-->8
function shoot(x, y, dir)
	sfx(0)
	add(bullets, {
		x=x,
		y=y,
		dir=dir,
	})
end

function movebullets()
	local speed = 2
	for b in all(bullets) do
		b.x += speed * cos(b.dir)
		b.y -= speed * sin(b.dir)

		if b.x>128 or b.x<0 or b.y>128 or b.y<0 then
			del(bullets, b)
		end
	end
end
-->8
function spawnenemy()
	add(enemies, {
		x=rnd({10,118}),
		y=rnd({10,118}),
		hp=1,
	})
end

function moveenemies()
	local speed = 1/3
	for e in all(enemies) do
		local variance = 1/3
		local dir=atan2(x-e.x,y-e.y) + rnd(variance)-variance/2
		e.x += speed * cos(dir)
		e.y += speed * sin(dir)
	end
end
-->8
function collide(a, b)
	return a.x < b.x + b.w and
	       a.x + a.w > b.x and
	       a.y < b.y + b.h and
	       a.y + a.h > b.y
end

function checkcollisions()
	--bullet to enemy
	for b in all(bullets) do
		for e in all(enemies) do
			if collide({x=b.x,y=b.y,w=2,h=2}, {x=e.x,y=e.y,w=8,h=8}) then
				del(bullets, b)
				e.hp -= 1
				if e.hp <= 0 then
					killcount += 1
					sfx(2)
					del(enemies, e)
				end
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
	for e in all(enemies) do
		spr(6, e.x-4, e.y-4)
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
00020000355503555034550335503254032540315302e5302b53025530215201d5201752013510095100051000500005000050000500005000050000500005000050000500005000050000500005000050000500
000200003c0703c0603c0503c0403c0303c0203c01000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
