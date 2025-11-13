pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
-- martian geography demo
-- simple scrolling height profile

heights = {}
features = {
  {x=4,  name="n polar cap"},
  {x=20, name="vall. marineris"},
  {x=44, name="tharsis rise"},
  {x=80, name="olympus mons"},
  {x=108,name="hellas basin"},
  {x=124,name="s polar cap"}
}

scroll = 0

function gen_heights()
  for x=0,127 do
    -- base rolling terrain
    local h = 70 + sin(x/64)*6

    -- valles marineris: deep canyon
    if x>=16 and x<=28 then
      h = h + 18 -- push ground down
    end

    -- tharsis rise: high plateau
    if x>=38 and x<=56 then
      h = h - 12
    end

    -- olympus mons: very tall volcano
    if x>=74 and x<=86 then
      h = h - 24
    end

    -- hellas basin: deep impact basin
    if x>=104 and x<=116 then
      h = h + 14
    end

    -- poles: slightly higher ice caps
    if x<8 or x>120 then
      h = h - 6
    end

    heights[x] = mid(30, h, 100)
  end
end

function _init()
  gen_heights()
end

function _update()
  scroll = (scroll + 0.25) % 128
end

function draw_background()
  -- dark sky
  cls(0)
  -- faint stars
  for i=1,60 do
    local sx = (i*11) % 128
    local sy = (i*7) % 64
    pset(sx, sy, 5)
  end
end

function draw_ground()
  for sx=0,127 do
    local mapx = (sx + flr(scroll)) % 128
    local h = heights[mapx]

    -- color bands by depth
    for y=h,127 do
      local depth = y - h
      local c
      if depth < 2 then
        c = 8   -- bright ridge
      elseif depth < 8 then
        c = 9   -- dusty slope
      elseif depth < 20 then
        c = 4   -- darker lowland
      else
        c = 2   -- deepest
      end
      pset(sx, y, c)
    end

    -- thin horizon line
    pset(sx, h-1, 7)
  end
end

function draw_labels()
		local i = 0
  for f in all(features) do
    for sx=0,127 do
      local mapx = (sx + flr(scroll)) % 128
      if mapx == f.x then
        -- small marker at surface
        local h = heights[mapx]
        line(sx, h-6, sx, h-1, 7)
        -- name above
        print("\#0"..f.name, sx-#f.name*2, h-12, 7)
      end
    end
    i += 1
  end
end

function draw_hud()
  rectfill(0,0,127,7,0)
  print("mars surface profile", 4, 1, 7)
  print("features: volcano, canyon, basin", 1, 118, 6)
end

function _draw()
  draw_background()
  draw_ground()
  draw_labels()
  draw_hud()
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
