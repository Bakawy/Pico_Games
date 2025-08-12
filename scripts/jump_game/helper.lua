function coordinate_to_tile(x, y)
	return flr(x / 8), flr(y / 8)
end

function dist(x1, y1, x2, y2)
	return sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

function is_collide(x1, y1, x2, y2)
    return abs(x1 - x2) < 8 and abs(y1 - y2) < 8
end

function get_tiles_in_radius(cx, cy, radius)
	local tiles = {}
	local r2 = radius * radius

	local tx = flr(cx / 8)
	local ty = flr(cy / 8)
	local tr = ceil(radius / 8)

	for y = ty - tr, ty + tr do
		for x = tx - tr, tx + tr do
			local px = x * 8 + 4
			local py = y * 8 + 4
			if (px - cx)^2 + (py - cy)^2 <= r2 then
				add(tiles, {x = x, y = y, id=mget(x, y)})
			end
		end
	end

	return tiles
end

function in_list(val, list)
    for item in all(list) do
        if item == val then
            return true
        end
    end
    return false
end

tile_size = 8
half_size = 4
speed_sweep_threshold = 8

function snap_edge(p, dir) -- snap to tile boundary given center p, half-size hs, dir
 if dir>0 then return flr((p+half_size)/tile_size)*tile_size-half_size else return flr((p-half_size)/tile_size+1)*tile_size+half_size end
end

function dist_to_seam(edge, dir)
  local r = edge % tile_size
  if dir > 0 then
    return (r == 0) and tile_size or (tile_size - r)
  else
    return (r == 0) and tile_size or r
  end
end

function solid_down(x,y)
  return check_tile_stat(x-3, y+half_size, 0)
      or check_tile_stat(x,   y+half_size, 0)
      or check_tile_stat(x+3, y+half_size, 0)
end

function solid_up(x,y)
  return check_tile_stat(x-3, y-half_size, 0)
      or check_tile_stat(x,   y-half_size, 0)
      or check_tile_stat(x+3, y-half_size, 0)
end

-- dir = +1 (right) or -1 (left)
function solid_side(x,y,dir)
  local off = (dir>0) and half_size or -half_size
  return check_tile_stat(x+off, y-3, 0)
      or check_tile_stat(x+off, y,   0)
      or check_tile_stat(x+off, y+3, 0)
end

function simple_move_y(x,y,vy)
	local new_y = y + vy
	local collided = false
	y = snap_edge(new_y, sgn(vy))
	if vy > 0 and solid_down(x, new_y) then
		vy = 0
		collided = true
	elseif vy < 0 and solid_up(x, new_y) then
		vy = 0
		collided = true
	else
		y = new_y
	end
	return y, vy, collided
end

function sweep_move_y(x,y,vy)
	local rem = vy
	local collided = false
	while rem ~= 0 do
		local dir  = sgn(rem)           
		local edge = y + dir*half_size
		local step = min(abs(rem), dist_to_seam(edge, dir))
		local ny   = y + dir*step

		y = snap_edge(ny, dir)
		if dir > 0 then
			if solid_down(x, ny) then
				vy = 0
				collided = true
				break
			else
				y = ny
				rem -= dir*step
			end
		else
			if solid_up(x, ny) then
				vy = 0
				break
			else
				y = ny
				rem -= dir*step
			end
		end
	end
	return y, vy, collided
end

function simple_move_x(x,y,vx)
	local new_x = x + vx
	local collided = false
	if vx != 0 then
		local offset = vx > 0 and 4 or -4
		if solid_side(new_x, y, sgn(vx)) then
			x = snap_edge(new_x, sgn(vx))
			vx = 0
			collided = true
		else
			x = new_x
		end
	end
	return x, vx, collided
end

function sweep_move_x(x,y,vx)
	local rem = vx
	local collided = false
	while rem ~= 0 do
		local dir  = sgn(rem)              -- +1 right, -1 left
		local edge = x + dir*half_size
		local step = min(abs(rem), dist_to_seam(edge, dir))
		local nx   = x + dir*step

		if solid_side(nx, y, dir) then
			-- snap to wall seam and stop
			x = snap_edge(nx, dir)
			vx = 0
			collided = true
			break
		else
			x = nx
			rem -= dir*step
		end
	end
	return x, vx, collided
end

function is_anchored(tx, ty, dir)
	dir = dir or "none"
	id = mget(tx, ty)
	if not fget(id, 0) then return false end
	if fget(id, 3) then return true end
	if id == 20 then
		if dir ~= "r" then if fget(mget(tx + 1, ty), 3) and fget(mget(tx + 1, ty), 0) then return true end end
		if dir ~= "l" then if fget(mget(tx - 1, ty), 3) and fget(mget(tx - 1, ty), 0) then return true end end
		if dir ~= "d" then if fget(mget(tx, ty + 1), 3) and fget(mget(tx, ty + 1), 0) then return true end end
		if dir ~= "u" then if fget(mget(tx, ty - 1), 3) and fget(mget(tx, ty - 1), 0) then return true end end
	end
	if dir ~= "r" then if is_anchored(tx + 1, ty, "l") then return true end end
	if dir ~= "l" then if is_anchored(tx - 1, ty, "r") then return true end end
	if dir ~= "d" then if is_anchored(tx, ty + 1, "u") then return true end end
	if dir ~= "u" then if is_anchored(tx, ty - 1, "d") then return true end end
	return false
end

function on_ground(x,y)
 return check_tile_stat(x-3,y+5,0) or check_tile_stat(x,y+5,0) or check_tile_stat(x+3,y+5,0)
end

function move_y(x,y,vy)
	if abs(vy)<speed_sweep_threshold then
		return simple_move_y(x,y,vy)
 	else
  		return sweep_move_y(x,y,vy)
	end
end
function move_x(x,y,vx)
	if abs(vx)<speed_sweep_threshold then
  		return simple_move_x(x,y,vx)
	else
  		return sweep_move_x(x,y,vx)
	 end
end

local _yield = yield

tasks = {}

function go(f)
  add(tasks, cocreate(f))
end

function wait_f(n)
  for i=1,n do _yield() end
end

function run_tasks()
  for co in all(tasks) do
    if costatus(co) == "dead" then
      del(tasks, co)
    else
      local ok, err = coresume(co)
      assert(ok, err) -- surfaces errors from inside the coroutine
    end
  end
end