do

local player = getPlayerState()
--[[
local basicAttack = {
    {x=-16, y=0, len=15, damaging=false},
    {x=16, y=-6, len=15, speed = 1.5, damaging=true},
    {x=24, y=0, len=15, speed = 1.5},
    endLag = 30,
}
]]
local basicAttack = {
    targetDist = 32,
    startLag = 30,
    endLag = 15,
    cooldown = 60,
}
local playerPath = {}
local navNodes = {}

local function contains(tbl, n) return count(tbl, n) > 0 end


function find_nearest_node(x, y, near)
    local tx, ty = flr(x/8), flr(y/8)

    -- decide N (how many "best" to consider)
    local N
    if near == true then
        N = 3
    elseif type(near) == "number" then
        N = max(1, flr(near))
    else
        N = 1
    end

    if N == 1 then
        -- original behavior: just the best
        local nearest, bestd = nil, 32767
        for n in all(navNodes) do
            local d = abs(n.tx - tx) + abs(n.ty - ty)
            if d < bestd then
                bestd, nearest = d, n
            end
        end
        return nearest
    end

    -- keep a running list of the top-N closest
    local best = {} -- entries: {n=<node>, d=<dist>}
    for n in all(navNodes) do
        local d = abs(n.tx - tx) + abs(n.ty - ty)
        if #best < N then
            add(best, { n = n, d = d })
        else
            -- find current worst (max d) in best[]
            local wi = 1
            for i = 2, #best do
                if best[i].d > best[wi].d then wi = i end
            end
            if d < best[wi].d then
                best[wi] = { n = n, d = d }
            end
        end
    end

    -- pick a random one among the top-N (if any)
    local pick = rnd(best) -- pico-8 rnd(list) picks a random element
    return pick and pick.n or nil
end


local function heuristic(a,b)
    return abs(a.tx - b.tx) + abs(a.ty - b.ty)
end

local function astar_nodes(start, goal, enemy)
    local open = {start}
    local closed = {}
    start.g = 0
    start.h = heuristic(start, goal)
    start.parent = nil

    local safety = 0 -- safeguard to prevent infinite loops

    while #open > 0 do
        safety += 1
        if safety > 500 then
            -- safeguard: break out if too many iterations
            printh("A* safety stop")
            return nil
        end

        -- find node with lowest f = g + h
        local best_i, current = 1, open[1]
        for i=1,#open do
            local n = open[i]
            if (n.g + n.h) < (current.g + current.h) then
                best_i, current = i, n
            end
        end

        -- reached goal?
        if current == goal then
            local path = {}
            while current do
                add(path, current, 1)
                current = current.parent
            end
            return path
        end

        deli(open, best_i)
        add(closed, current)

        for e in all(current.edges) do
            local n = e.to

            -- skip if already closed
            local skip = false
            for c in all(closed) do
                if c == n then skip = true break end
            end
            if (skip) goto continue

            local tentative_g = current.g + e.cost

            if (e.action == "jump") then
                if (e.minimumJump < enemy.maxJumpVel or abs(e.minimumSpeed) > enemy.speed) goto continue
            end

            local in_open = false
            for o in all(open) do
                if o == n then in_open = true break end
            end

            if (not in_open) or (tentative_g < n.g) then
                n.parent = current
                n.g = tentative_g
                n.h = heuristic(n, goal)
                if (not in_open) add(open, n)
            end
            ::continue::
        end
    end

    return nil -- no path found
end

local function drawNav(nodes)
    nodes = nodes or navNodes
    for n in all(nodes) do
        rectfill(n.tx*8+3, n.ty*8+3, n.tx*8+5, n.ty*8+5, 3)
        for e in all(n.edges) do
            if (contains(nodes, e.to)) line(n.tx*8+4, n.ty*8+4, e.to.tx*8+4, e.to.ty*8+4, e.action=="jump" and 10 or e.action=="fall" and 8 or 5)
        end
    end
end

Enemy = Class:new({
    x = 64,
    y = 64,
    xVel = 0,
    yVel = 0,
    maxJumpVel = -4.5,
    jumpVel = -4.5,
    noInput = 0,
    knocked = 0,
    grounded = false,
    facing = true,
    hitStun = 0,
    dead = false,
    speed = 0.5,
    canSeePlayer = false,
    wallTouch = false,
    kbMult = 1,
    sprState = 0,

    attackCD = 0,
    attackData = basicAttack,
    behavior = "idle",
    currentAttackIndex = 1,
    attackTimer = 0,
    attackDir = 1,
    damaging = false,

    path = {},          -- list of nav nodes to follow
    pathIndex = 1,      -- which node the enemy is moving toward
    pathTimer = 0,      -- timer for when to recompute path
    pathRecalcDelay = 60, -- recompute every 60 frames (~1 sec)

    
    planPathToPlayer = function(_ENV)
        local start = find_nearest_node(x, y)
        local goal = find_nearest_node(player.x, player.y, 3)
        if not start or not goal then
            path = {}
            return
        end
        local newPath = astar_nodes(start, goal, _ENV)
        if newPath then
            path = newPath
            pathIndex = 2 -- first step after start
        else
            path = {}
        end
    end,

    followPath = function(_ENV)
        --drawNav(path)
        if not path or #path < 2 then return end

        local node = path[pathIndex]
        if not node then return end

        -- world coordinates for the current target node
        local wx, wy = node.tx * 8 + 4, node.ty * 8 + 4
        local dx, dy = wx - x, wy - y
        local distToNode = sqrt(dx*dx + dy*dy)

        -- don't skip nodes too early
        if distToNode < 0.5 or distToNode > 48 then
            pathIndex += 1
            pathTimer = 0
            if pathIndex > #path then
                path = {}
                xVel = 0
                return
            end

            jumpVel = 0
            for e in all(node.edges) do
                if e.minimumJump then
                    jumpVel = max(e.minimumJump - sqrt(2 * gravity * 4), maxJumpVel)
                end
            end

            node = path[pathIndex]
            wx, wy = node.tx * 8 + 4, node.ty * 8 + 4
            dx, dy = wx - x, wy - y
        end
        --circfill(wx, wy, 3, 9)

        --centerPrint(temp, wx, wy-6, 9)

        -- always move horizontally toward current node
        local dir = sgn(dx)
        xVel = dir * speed

        -- handle simple jump/fall cases
        if grounded and (wy < y - 4 or jumpVel > 0) then
            -- jump if node is above us
            yVel = jumpVel
        end
        return dir
    end,

    idle = function(_ENV)
        if (canSeePlayer) behavior = "follow"
        sprState = 4
    end,
    follow = function(_ENV)
        pathTimer += 1
        sprState = 0
        local distToPlayer = dist(x, y, player.x, player.y)

        -- Recalculate path if timer expires or player moved far
        if pathTimer > pathRecalcDelay or not path or #path == 0 then
            planPathToPlayer(_ENV)
            pathTimer = 0
        end

        if (distToPlayer >= attackData.targetDist or not canSeePlayer) facing = followPath(_ENV) == 1

        if distToPlayer < attackData.targetDist and grounded and attackCD <= 0 and canSeePlayer then
            behavior = "attack"
            attackTimer = 0
            attackDir = sgn(player.x - x)
        end
    end,
    attack = function(_ENV)
        if attackTimer > attackData.startLag + attackData.endLag then
            behavior = "idle"
            attackCD = attackData.cooldown
        elseif attackTimer == attackData.startLag then
            sprState = 3
            local dir = facing and 1 or -1
            Bullet:new({x=x,y=y,r=2,col=9,dx=dir,range=64}, bullets)
        elseif attackTimer < attackData.startLag then
            facing = player.x > x
            sprState = 2
        end
        attackTimer += 1
    end,
    

    checkPlayerCollison = function (_ENV)
        return dist(x, y, player.x, player.y) < 8
    end,
    checkPlayerSight = function(_ENV)
        canSeePlayer = los(x, y, player.x, player.y)
        --line(x, y, player.x, player.y, canSeePlayer and 11 or 8)
        --centerPrint(tostr(xCol).." "..tostr(yCol), x, y - 20, 7)
    end,
    checkOrb = function(_ENV)
        local ox, oy, oRadius = getOrbPos()
        if dist(x, y, ox, oy) < sqrt(32) + oRadius then
            local isDamaging, knockback, hs = getOrbDamage()
            if isDamaging then
                --circfill(ox, oy, oRadius, 1)
                --circfill(x, y, sqrt(32), 2)
                --stop()
                knockback.mag *= kbMult
                xVel = knockback.mag * cos(knockback.dir)
                yVel = knockback.mag * sin(knockback.dir)
                hitStun = hs
                knocked = 10
                kbMult += 0.05
                damaging = false
                behavior = "idle"
                sprState = 1
            end
        end
    end,
    move = function(_ENV)
        yVel += gravity
        local xv = xVel
        local yv = yVel
        local down, yCol, xCol = yVel > 0
        y, yVel, yCol = move_y(x, y, yVel, 8)
        x, xVel, xCol = move_x(x, y, xVel, 8)

        wallTouch = xCol
        if xCol and fget(xCol, 1) then
            dead = true
            return
        end
        if yCol and fget(yCol, 1) then
            dead = true
            return
        end

        grounded = false
        if (down and yCol) then 
            grounded = true 
        end

        if knocked > 0 and xCol then
            xVel = xv * -1
        end
        if knocked > 0 and yCol then
            yVel = yv * -1
        end

        local friction = 0.5
        if (noInput <= 0 and knocked <= 0) xVel = abs(xVel) < friction and 0 or xVel - sgn(xVel)*friction

        if (noInput > -1) noInput -= 1
        if (knocked > -1) knocked -= 1
        if (attackCD > -1) attackCD -= 1
    end,
    update = function(_ENV)
        if hitStun > 0 then
            hitStun -= 1
            return
        end
        checkOrb(_ENV)
        checkPlayerSight(_ENV)

        if noInput <= 0 and knocked <= 0 then
            _ENV[behavior](_ENV)
        end
        move(_ENV)
    end,
    draw = function(_ENV)
        local dx, dy = x, y
        if hitStun > 0 then
            dx += randDec(-1.5, 1.5)
            dy += randDec(-1.5, 1.5)
        end
        centerPrint("\#0"..flr((kbMult - 1) * 100).."%", dx, dy - 8, 7)
        if damaging then
            rect(x - 5, y - 5, x + 4, y + 4, 9)
        end
        spr(15 + 16 * sprState, x - 4, y - 4, 1, 1, not facing)

        --centerPrint(dist(xVel, yVel, 0, 0), x, y - 10, 7)
        --centerPrint(behavior, x, y - 16, 7)
        --circfill(target.x, target.y, 2, 12)
        --centerPrint(jumpVel, x, y-24, 7)
    end,
})
enemies = {}

local function tile_is_solid(x,y) return fget(mget(x, y), 0) and not fget(mget(x, y), 1) end

function updateEnemies()
    player = getPlayerState() 
    for e in all(enemies) do 
        e:update() 
        if e.dead then 
            del(enemies, e) 
        end 
    end 
end

function drawEnemies()
    --drawNav()
    for e in all(enemies) do 
        e:draw() 
    end 
end

local function build_nav_nodes()
    local nodes = {}
    for tx=0,15 do -- adjust to your map width
        for ty=0,15 do
            if tile_is_solid(tx, ty+1) and not tile_is_solid(tx, ty) then
                add(nodes, {tx=tx, ty=ty, edges={}})
            end
        end
    end
    return nodes
end


local function connect_walk_edges(nodes)
    for node in all(nodes) do
        for other in all(nodes) do
            if node ~= other and node.ty == other.ty and abs(node.tx - other.tx) == 1 then
                add(node.edges, {to=other, action="walk", cost=1})
            end
        end
    end
end

local function find_node(nodes, tx, ty)
    for n in all(nodes) do
        if n.tx==tx and n.ty==ty then return n end
    end
end

-- simulate a jump with real pixel physics and step ~Npx along arc
-- returns true if the arc is clear; optionally fills out_pts with {x,y} samples
local function can_jump_between(tx1, ty1, tx2, ty2)
    --cls()
    -- convert tiles -> pixels (tile center)
    local x1, y1 = tx1*8 + 4, ty1*8 + 4
    local x2, y2 = tx2*8 + 4, ty2*8 + 4
    local dx, dy = x2 - x1, y2 - y1
    local vyi = -sqrt(-2*gravity*dy)
    if (vyi >= 0) return

    local time = (-vyi + sqrt(vyi*vyi + 2*gravity*dy)) / gravity
    local vx = dx / time

    --circfill(x1, y1, 2, 1)
    --circfill(x2, y2, 2, 2)
    for t = 0, time, 1 do
        local x = x1 + vx * t
        local y = y1 + vyi * t + 0.5 * gravity * t * t
        --circfill(x, y, 1, 3)
        local tx, ty = flr(x/8), flr(y/8)
        if (tile_is_solid(tx, ty)) return false
    end
    --stop(vyi)
    return true, vyi, vx/time
end



local function connect_jump_edges(nodes)
    local max_jump_height = 8
    local max_jump_dist = 8

    for node in all(nodes) do
        local tx, ty = node.tx, node.ty

        -- only allow jumps starting from ground
        if tile_is_solid(tx, ty+1) and not tile_is_solid(tx, ty) then
            for dx=-max_jump_dist, max_jump_dist do
                for dy=-max_jump_height, max_jump_height do
                    if abs(dx) <= max_jump_dist and abs(dy) <= max_jump_height then
                        local lx, ly = tx+dx, ty+dy
                        if not tile_is_solid(lx, ly) and tile_is_solid(lx, ly+1) then
                            -- ensure realistic jump distances
                            --if abs(dy) > 3 or abs(dx) > 4 then goto continue end
                            local target = find_node(nodes, lx, ly)
                            local canJump, minJ, minS = can_jump_between(tx, ty, lx, ly)
                            if target and canJump then
                                add(node.edges, {to=target, action="jump", cost=3 + abs(dx), minimumJump=minJ, minimumSpeed=minS})

                            end
                        end
                    end
                    ::continue::
                end
            end
        end
    end
end


local function find_ground_below(nodes, tx, ty)
    for dy=1,8 do
        if tile_is_solid(tx, ty+dy+1) and not tile_is_solid(tx, ty+dy) then
            for n in all(nodes) do
                if n.tx==tx and n.ty==ty+dy then return n end
            end
        end
    end
end

local function connect_fall_edges(nodes)
    for node in all(nodes) do
        local tx, ty = node.tx, node.ty
        -- Check left edge
        if not tile_is_solid(tx-1, ty+1) then
            local dest = find_ground_below(nodes, tx-1, ty)
            if dest then add(node.edges, {to=dest, action="fall", cost=3}) end
        end
        -- Check right edge
        if not tile_is_solid(tx+1, ty+1) then
            local dest = find_ground_below(nodes, tx+1, ty)
            if dest then add(node.edges, {to=dest, action="fall", cost=3}) end
        end
    end
end


function initNav()
    navNodes = build_nav_nodes()
    connect_walk_edges(navNodes)
    connect_fall_edges(navNodes)
    connect_jump_edges(navNodes)
    for n in all(navNodes) do
        for i=#n.edges,1,-1 do
            if n.edges[i].to == n then
                deli(n.edges, i)
            end
        end
    end
end

end