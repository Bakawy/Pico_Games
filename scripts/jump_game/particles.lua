Particles = Class:new({
    x=64,
    y=64,
    x_velocity=0,
    y_velocity=0,
    frames=0,
    sprite_id=0,
    size=8,
    delta_size=0, --change in size over time
    dead=false,
    update=function(_ENV)
        frames -= 1
        if frames <= -1 then dead=true end
        x += x_velocity
        y += y_velocity
        size += delta_size
    end,
    draw=function(_ENV)
        local rx, ry = x - size/2, y - size/2
        local sx, sy = (sprite_id % 16) * 8, flr(sprite_id / 16) * 8
        if size == 8 then
            spr(sprite_id, rx, ry)
        else
            sspr(sx, sy, 8, 8, rx, ry, size, size)
        end
    end,
})

function update_particles()
	for particle in all(particles) do
		particle:update()
		if particle.dead then del(particles, particle) end
	end
end

function draw_particles()
    for particle in all(particles) do
		particle:draw()
	end
end