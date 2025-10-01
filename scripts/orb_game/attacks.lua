do
local attackCooldown = 0

function updateAttacks() 
    if attackCooldown > 0 then
        attackCooldown -= 1
        return
    end
    if btnp(5) then
        local facing = getPlayerFacing()
        local dir = facing and 1 or -1
        pushPlayer(3, facing and 0.15 or mirrorY(0.15), 10)
        setOrbPath({
            {x=0, y=-16, len=5},
            {x=16 * dir, y=0, len=5},
            {x=0, y=16},
        })
        attackCooldown = 30
    end
end

end