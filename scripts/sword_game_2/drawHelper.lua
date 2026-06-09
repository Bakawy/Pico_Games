do

function linefill(ax,ay,bx,by,r,c)
    --function by https://www.lexaloffle.com/bbs/?pid=80095
    if r <= 1 then
        line(ax, ay, bx, by, c)
    end
    if(c) color(c)
    local dx,dy=bx-ax,by-ay
    -- avoid overflow
    -- credits: https://www.lexaloffle.com/bbs/?tid=28999
     local d=max(abs(dx),abs(dy))
     local n=min(abs(dx),abs(dy))/d
    d*=sqrt(n*n+1)
    if(d<0.001) return
    local ca,sa=dx/d,-dy/d
   
    -- polygon points
    local s={
     {0,-r},{d,-r},{d,r},{0,r}
    }
    local spans = {}
    local x0,y0=ax+r*sa,ay+r*ca
    for i=1,4 do
        local u,v=s[i][1],s[i][2]
        local x1,y1=ax+u*ca+v*sa,ay-u*sa+v*ca
        local _x1,_y1=x1,y1
        if(y0>y1) x0,y0,x1,y1=x1,y1,x0,y0
        local dx=(x1-x0)/(y1-y0)
        if(y0<0) x0-=y0*dx y0=-1
        local cy0=y0\1+1
        -- sub-pix shift
        x0+=(cy0-y0)*dx
        for y=y0\1+1,min(y1\1,127) do
            -- open span?
            local span=spans[y]
            if span then
                rectfill(x0,y,span,y)
            else
                spans[y]=x0
            end
            x0+=dx
        end
        x0,y0=_x1,_y1
    end
end

function rspr(sx,sy,sw,sh,a,dx,dy,dw,dh)
    local sx,sy,sw,sh,a,dx,dy,dw,dh=
        sx or 0, sy or 0,
        sw or 8, sh or 8,
        a or 0,
        dx or 0, dy or 0,
        dw or 8, dh or 8
    
    dw += 1
    dh += 1
   
    local s1,c1,half_dw,half_dh = 
        sin(a+0.125),cos(a+0.125),
        dw/2,dh/2
    local x1,y1,x2,y2,x3,y3,x4,y4 = 
        half_dw*c1,half_dh*s1,
        half_dw*s1,half_dh*-c1,
        half_dw*-c1,half_dh*-s1,
        half_dw*-s1,half_dh*c1
    
    --rectfill(dx - dw/2, dy - dh/2, dx + dw/2, dy + dh/2, 1)    
    for y=0,dh-1 do
        local ty = y/dh
        local stx,sty,enx,eny = 
            x2+(x3-x2)*ty,y2+(y3-y2)*ty,
            x1+(x4-x1)*ty,y1+(y4-y1)*ty
        for x=0,dw-1 do
            local tx = x/dw
            local col = sget(sx+sw*tx,sy+sh*ty)
            if col ~= 0 then
                local px,py = stx+(enx-stx)*tx,sty+(eny-sty)*tx
                pset(dx+px+0.5,dy+py+0.5,col)--pset(dx+px,dy+py,col)
            end
        end
    end
end

function centerPrint(text, x, y, col)
    local len = print(text, 0, -12)
    print(text, x - len/2, y - 2, col)
end


function sprPal(s, x, y, tbl)
    local trans = {}
    for k,v in pairs(tbl) do
        if v == -1 then
            palt(k, true)
            add(trans, k)
        else
            pal(k, v, 0)
        end
    end
    spr(s, x, y)
    pal(0)
    for col in all(trans) do 
        palt(col, false)
    end
end

end