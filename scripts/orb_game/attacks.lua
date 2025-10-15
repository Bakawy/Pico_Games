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

end