function init_menu()
	menu_items = {"platforming test", "bomb test", "grapple test", "enemy test", "spring test", "sticky test"}
    menu_text = {}
    selected = 1
    disableinput = 30
	game_state = 0
end

function update_menu()
    if disableinput > 0 then disableinput -= 1 end
    if btnp(2) then -- up
        selected -= 1
    elseif btnp(3) then -- down
        selected += 1
    end

    if selected < 1 then selected = #menu_items end
    if selected > #menu_items then selected = 1 end

    if (btnp(4) or btnp(5)) and disableinput <= 0 then
        if menu_items[selected] == "platforming test" then
            init_game(0)
		elseif menu_items[selected] == "bomb test" then
            init_game(1)
		elseif menu_items[selected] == "grapple test" then
            init_game(2)
		elseif menu_items[selected] == "enemy test" then
            init_game(3)
        elseif menu_items[selected] == "spring test" then
            init_game(4)
        elseif menu_items[selected] == "sticky test" then
            init_game(5)
		end
    end
end

function draw_menu()
    cls()
    
    for i, item in ipairs(menu_text) do
        print(item, 0, i * 10, 7)
    end

    for i, item in ipairs(menu_items) do
        local y = 40 + i * 10
        if i == selected then
            print("> "..item, 36, y, 11)
        else
            print(item, 44, y, 6)
        end
    end
end