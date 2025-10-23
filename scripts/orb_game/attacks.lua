do
local attackCooldown = 0

local attackTable = {
    format = {
        path = {
            {x=0, y=0, len=0},
            {x=0, y=0},
        },
        kb = {mag=0, dir=0},
        hs = 0,
        push = {mag=0, dir=0},--optional
        endLag = 0,--optional
        freefall = false,--optionl
    },
    jab = {
        path = {
            {x=4, y=0, len=3},
            {x=8, y=0}
        },
        endLag = 0,
        kb = {mag=0.5, dir=0.125},
        hs = 5,
    },
    slash = {
        path = {
            {x=-4, y=-8, len=5},
            {x=8, y=0, len=5},
            {x=-4, y=8}
        },
        endLag = 5,
        push = {mag=2, dir=0.125},
        kb = {mag=5, dir=0.15},
        hs = 15,
    },
    upSlash = {
        path = {
            {x=-8, y=0, len=5},
            {x=0, y=-8, len=5},
            {x=8, y=0}
        },
        endLag = 10,
        kb = {mag=4, dir=0.25},
        hs = 5,
    },
    downSlash = {
        path = {
            {x=-8, y=0, len=5},
            {x=0, y=12, len=5},
            {x=8, y=0}
        },
        endLag = 5,
        kb = {mag=4, dir=0.75},
        push = {mag=2, dir=0.25},
        hs = 10,
    },
    circleSlice = {
        path = {
            {x=0, y=-8, len=3},
            {x=8, y=0, len=3},
            {x=0, y=8, len=3},
            {x=-8, y=0, len=3},
            {x=0, y=-8},
        },
        kb = {mag=4, dir=0.225},
        endLag = 5,
        hs = 5,
    },
    enlarge = {
        path = {
            {x=0, y=0, len=15},
            {x=0, y=0},
        },
        kb = {mag=4, dir=0.225},
        endLag = 5,
        hs = 10,
        size = 8,
    },
    stab = {
        path = {
            {x=0, y=0, len=10},
            {x=20, y=0}
        },
        endLag = 10,
        kb = {mag=3, dir=0.15},
        hs = 5,
    },
    drop = {
        path = {
            {x=0, y=0, len=10},
            {x=0, y=64},
        },
        push = {mag=4, dir=0.25},
        kb = {mag=1, dir=0.75},
        freefall = true,
        hs = 5,
    },
    rise = {
        path = {
            {x=0, y=4, len=20},
            {x=0, y=4},
        },
        push = {mag=4, dir=0.25},
        kb = {mag=4, dir=0.25},
        freefall = true,
        hs = 5,
    },
    trip = {
        path = {
            {x=8, y=8, len=10},
            {x=8, y=-4},
        },
        kb = {mag=2, dir=0.25},
        hs = 10,
        endLag = 10,
    },
}
local ng = "jab"
local sg = "stab"
local ug = "upSlash"
local dg = "trip"
local na = "enlarge"
local sa = "slash"
local ua = "rise"
local da = "downSlash"
local attack = nil

function doAttack(grounded)
    local playerState = getPlayerState()
    grounded = grounded != nil and grounded or playerState.grounded

    if grounded and playerState.jumpBuffer <= 0 then
        attack = ng
        if (btn(0) ~= btn(1)) attack = sg
        if (btn(2)) attack = ug
        if (btn(3)) attack = dg
    else
        attack = na
        if (btn(0) ~= btn(1)) attack = sa
        if (btn(2)) attack = ua
        if (btn(3)) attack = da
    end

    local facing = playerState.facing
    local dir = facing and 1 or -1
    local attackData = attackTable[attack]


    if playerState.jumpBuffer > 0 then
        playerJump()
    end
    if attackData.push then
        local p = attackData.push
        pushPlayer(p.mag, facing and p.dir or mirrorY(p.dir))
    end

    setOrbPath(attackData.path, attackData.size)

    local totalLen = 0
    for p in all(attackData.path) do
        totalLen += p.len or 0
    end
    if (attackData.endLag) totalLen += attackData.endLag
    attackCooldown = totalLen
    setNoInput(totalLen)
    if (attackData.kb) setOrbKB(attackData.kb)
    if (attackData.hs) setOrbHS(attackData.hs)
    if (attackData.freefall) setFreefall(true)
end

function updateAttacks() 
    if attackCooldown > 0 then
        attackCooldown -= 1
        return
    end
    local playerState = getPlayerState()
    if btnp(5) and not playerState.freefall and playerState.noInput <= 0 and playerState.knocked <= 0 then
        doAttack()
    end
end

--attack card draw-er
--[[
----------------------------------------
-- helpers
----------------------------------------
local function _lerp(a,b,t) return a+(b-a)*t end
local function _mix2(ax,ay,bx,by,t) return _lerp(ax,bx,t), _lerp(ay,by,t) end

-- faint polyline of the path
local function draw_path_poly(pts, map_fn, col)
  if #pts<2 then return end
  local x1,y1 = map_fn(pts[1].x, pts[1].y)
  for i=2,#pts do
    local x2,y2 = map_fn(pts[i].x, pts[i].y)
    line(x1,y1,x2,y2,col)
    x1,y1=x2,y2
  end
end

----------------------------------------
-- path cache builder
-- * ABSOLUTE points
-- * segment len taken from ARRIVAL node's .len
----------------------------------------
local function build_path_cache(atk)
  if atk._cache then return atk._cache end

  -- absolute points straight from atk.path
  local pts={}
  for i=1,#atk.path do
    local p=atk.path[i]
    add(pts,{x=(p.x or 0), y=(p.y or 0), len=p.len})
  end
  -- edge case: empty path → dummy single point at origin
  if #pts==0 then pts={{x=0,y=0}} end

  -- segment frames between consecutive points
  local seg_frames={}
  for i=1,#pts-1 do
    local a,b = pts[i], pts[i+1]
    local dx,dy = b.x-a.x, b.y-a.y
    local dist=max(1, sqrt(dx*dx+dy*dy))
    -- len lives on ARRIVAL node (b)
    local declared = b.len
    add(seg_frames, declared or max(1, flr(dist/2)))
  end

  local move_frames=0
  for i=1,#seg_frames do move_frames+=seg_frames[i] end
  local wrap_frames = max(0, atk.endLag or 0)

  atk._cache={
    pts=pts,               -- absolute points
    seg_frames=seg_frames, -- # = pts-1
    move_frames=move_frames,
    wrap_frames=0,--wrap_frames,
    total_frames=max(1, move_frames + wrap_frames)
  }
  return atk._cache
end

----------------------------------------
-- mapper: keep (0,0) at card center, scale to fit with margin
----------------------------------------
local function make_mapper_origin_centered(pts, x, y, w, h)
  local margin=3
  local iw=max(1, w-2*margin)
  local ih=max(1, h-2*margin)

  -- extents relative to origin
  local maxabsx, maxabsy = 1, 1
  for i=1,#pts do
    local p=pts[i]
    maxabsx=max(maxabsx, abs(p.x))
    maxabsy=max(maxabsy, abs(p.y))
  end

  -- uniform scale
  local sx = iw / (2*maxabsx)
  local sy = ih / (2*maxabsy)
  local s = min(sx, sy)

  local cx = x + w/2
  local cy = y + h/2

  return function(px,py)
    return cx + px*s, cy + py*s
  end, s
end

----------------------------------------
-- sampler: position along path at frame f
-- movement over segments, then wrap last→first over endLag
----------------------------------------
local function path_pos_at(cache, f)
  local mf, wf = cache.move_frames, cache.wrap_frames
  local total = max(1, mf + wf)
  local t = f % total

  -- traverse moving segments
  if t < mf and #cache.pts > 1 then
    local acc=0
    for i=1,#cache.seg_frames do
      local seg=cache.seg_frames[i]
      if t < acc+seg then
        local u=(t-acc)/max(1,seg)
        local a,b=cache.pts[i], cache.pts[i+1]
        return a.x+(b.x-a.x)*u, a.y+(b.y-a.y)*u
      end
      acc+=seg
    end
    -- safety: return last point
    local last=cache.pts[#cache.pts]
    return last.x,last.y
  else
    -- wrap (or snap) last→first
    local first=cache.pts[1]
    local last =cache.pts[#cache.pts]
    if wf<=0 then return first.x, first.y end
    local alpha=(t-mf)/wf
    return last.x+(first.x-last.x)*alpha,
           last.y+(first.y-last.y)*alpha
  end
end

----------------------------------------
-- main renderer
-- - (0,0) is visual center
-- - starts at first path point
-- - half-speed playback (2× real time)
----------------------------------------
function draw_attack_card(atk, x, y, w, h)
  -- panel
  rect(x,y,x+w,y+h,1)

  local cache = build_path_cache(atk)
  local map_fn = make_mapper_origin_centered(cache.pts, x, y, w, h)

  -- half-speed playback
  local f_anim = flr(frame/2)

  -- path
  draw_path_poly(cache.pts, map_fn, 5)

  -- simple trail ghosts
  for i=1,4 do
    local gx,gy = path_pos_at(cache, max(0, f_anim - i*2))
    local tx,ty = map_fn(gx,gy)
    circfill(tx,ty, 2, 13)
  end

  -- marble
  local px,py = path_pos_at(cache, f_anim)
  local sx,sy = map_fn(px,py)
  circfill(sx,sy, 2, 7)

  -- optional: show origin (0,0) for reference
  local ox,oy = map_fn(0,0)
  pset(ox,oy, 12)
end

----------------------------------------
-- demo grid (_draw)
-- uses your existing attackTable; if absent, builds a tiny demo
----------------------------------------
if not attackTable then
  attackTable = {
    jab = { path={{x=4,y=0,len=6},{x=8,y=0,len=6}}, endLag=6 },
    circle = { path={{x=0,y=-8,len=8},{x=8,y=0,len=8},{x=0,y=8,len=8},{x=-8,y=0,len=8}}, endLag=8 },
    diag = { path={{x=-8,y=-8,len=10},{x=8,y=8,len=10}}, endLag=8 },
  }
end
]]
end