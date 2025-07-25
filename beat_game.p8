pico-8 cartridge // http://www.pico-8.com
version 42
__lua__

function _init()
    poke(0x5f5c, 255) -- disable auto-repeat
    poke(0x5f5d, 255)
    cls(0)
    music(0)
    
    -- Timing system
    spd = 18
    bpm = 1800/spd
    beatlength = 60/bpm
    maxpulse = 360
    pulse = 360
    last_row = -1
    timing = -1 -- 2=good, 1=ok, 0=bad, -1=nothing
    
    -- Smooth interpolation tracking
    smooth_beat = 0
    last_beat_time = 0
    
    -- Calibration
    calibrating = true
    calib_inputs = {}
    calib_target_beats = {8, 9, 10, 11, 12, 13, 14, 15}
    input_offset = 0
    
    -- Game elements
    expected_inputs = {
        {beat=4, button=❎},
        {beat=6, button=🅾️},
    }
    
    scheduled_sfx = {}
    for i=4,15 do
        add(scheduled_sfx, {beat=i, id=3})
    end
end

function _update60()
    -- Tempo control
    if btnp(⬆️) then spd = max(1, spd-1); setspd(spd) end
    if btnp(⬇️) then spd += 1; setspd(spd) end
    
    -- Core timing (row-based)
    local row = stat(21)
    if row != last_row then
        if row % 4 == 0 then
            pulse = maxpulse
            last_beat_time = time()
        end
        last_row = row
    end
    
    -- Smooth beat progress (time-based)
    smooth_beat = (time() - input_offset) / beatlength
    
    -- Game systems
    if calibrating then
        handle_calibration()
    else 
        timing = checktiming()
    end
    
    if pulse > 0 then
        pulse -= 30 * (bpm/100)
        pulse = max(pulse, 0)
    end
    
    check_scheduled_sfx()
end

function _draw()
    cls()
    print("offset: "..flr(input_offset*1000).."ms", 0, 0, 7)
    
    if calibrating then
        draw_calibration()
    else
        draw_game()
    end
end

-->8
-- Audio System
function setsfxspeed(id, speed)
    local sfx_base = 0x3200
    local sfx_size = 68
    if id < 0 or id > 63 then return end
    local addr = sfx_base + id * sfx_size + 65
    poke(addr, speed)
end

function setspd(spd)
    music(-1)
    setsfxspeed(0, spd)
    setsfxspeed(2, spd)
    bpm = 1800/spd
    beatlength = 60/bpm
    music(0, 0, true)
end

-->8
-- Game Logic
function checktiming()
    local current_beat = smooth_beat
    
    for input in all(expected_inputs) do
        if abs(current_beat - input.beat) <= 1 then
            local beat_time = input.beat * beatlength
            local current_time = time() - input_offset
            
            if btnp(input.button) then
                local time_diff = abs(current_time - beat_time)
                
                if time_diff <= 0.07 then -- ~1/4 note at 120bpm
                    timing = 2 -- Perfect
                    sfx(4)
                    del(expected_inputs, input)
                elseif time_diff <= 0.15 then
                    timing = 1 -- Good
                    sfx(4)
                    del(expected_inputs, input)
                else
                    timing = 0 -- Bad
                end
            end
            
            if current_time > beat_time + 0.15 then
                timing = 0 -- Miss
                del(expected_inputs, input)
            end
        end
    end
    
    return timing
end

-->8
-- Calibration System
function handle_calibration()
    local target_beat = calib_target_beats[1]
    local target_time = target_beat * beatlength
    local current_time = time() - input_offset
    
    if btnp(❎) or btnp(🅾️) then
        local offset = current_time - target_time
        add(calib_inputs, offset)
        deli(calib_target_beats, 1)
		input_offset = average_offset()
    end
	
    if #calib_target_beats == 0 then
        calibrating = false
    end
end

function average_offset()
    local sum = 0
    for o in all(calib_inputs) do sum += o end
    return sum / #calib_inputs
end

function draw_calibration()
    local target_x = 32
    line(target_x, 54, target_x, 74, 7)
    for i=1, #calib_target_beats do
		local target_beat = calib_target_beats[i]
		local target_time = target_beat * beatlength
		local t = target_time - (time() - input_offset)
		local travel_time = 2.0
		
		if t >= -1 and t <= travel_time then
			local progress = 1 - (t / travel_time)
			local x = 128 - progress * (128 - target_x)
			local size = 2 + (8 * (pulse/maxpulse))
			circfill(x, 64, size, 7)
		end
	end
end

-->8
-- Visual Effects
function draw_game()
    -- Pulse effect (smooth size interpolation)
    local pulse_size = 7 + 21 * pulse/maxpulse
    circfill(64, 64, pulse_size, 1)
    
    -- Approach circles (smooth movement)
    for input in all(expected_inputs) do
        local beats_away = input.beat - smooth_beat
        if beats_away > 0 and beats_away < 8 then
            local x = ease_out_quad(1 - (beats_away/8)) * 100 + 28
            local col = input.button == ❎ and 12 or 10
            circfill(x, 64, 5, col)
        end
    end
end

function ease_out_quad(x)
    return 1 - (1 - x) * (1 - x)
end

-->8
-- Audio Scheduling
function check_scheduled_sfx()
    local pattern, row = 0, stat(21)
    for s in all(scheduled_sfx) do
        if pattern == 0 and row == (s.beat * 4) % 64 then
            sfx(s.id)
            del(scheduled_sfx, s)
        end
    end
end

__gfx__
00000000777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700777777070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000777707770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000707777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700700000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__sfx__
911200000b633006003c6000b63330615006050b6330b6000b6000b6000b6333060030615006000b600306000b633006003c6000b63330615006050b633306000b600306000b6333060030615000003060000000
010f0000070500705013050130501205012000100501005010050100500e0500e0500c0500c0500e0500e0500b0500b05013050130501205012000100501005010050100500b0500b05009050090500b0500b050
0112000007070000000700007070070000000007070000000600000000060700000007070000000907000000070700000000000070700000000000060700000000000000000c070000000b070000000907000000
000400003c11015100001001710017100121001210000100101001010000100001000010010100101000010012100121000010013100131000e1000e100001000c1000c100001000010000100001000010000100
00030000145500f5400c5400853003520015100051000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
01010000077500b7500f750157501a7501e750207502575027750287502a7502c7502d7502d7502e7002e7002d7002b7002a7002a7002a7002a7002a7002b7002b70000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__music__
02 00024344