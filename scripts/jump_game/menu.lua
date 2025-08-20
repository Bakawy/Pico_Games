function init_menu()
	menu_items = {"play", "shop", "seed"}
    menu_text = {"highscore: "..highscore}
    camera()
    selected = 1
    disableinput = 30
	game_state = 0
end

function update_menu()
    if selected == "seed input" then
        for i=0, 5 do
            if btnp(i) then
                seed ..= i
                break
            end
        end
        if #seed >= 8 then selected = 1 end
        return
    end

    if btnp(2) then -- up
        selected -= 1
    elseif btnp(3) then -- down
        selected += 1
    end

    if selected < 1 then selected = #menu_items end
    if selected > #menu_items then selected = 1 end

    if (btnp(4) or btnp(5)) then
        if menu_items[selected] == "play" then
            init_game(0)
        elseif menu_items[selected] == "shop" then
            init_game(1)
        elseif menu_items[selected] == "seed" then
            selected = "seed input"
            seed = ""
        end
    end
end

function draw_menu()
    for i, item in ipairs(menu_text) do
        print(item, 0, i * 10, 7)
    end

    for i, item in ipairs(menu_items) do
        if item == "seed" then 
            item = "seed: "..num_to_inputs(seed)
        end
        local y = 30 + i * 10
        local x = 32
        if i == selected then
            print("> "..item, x - 8, y, 11)
        else
            print(item, x, y, 6)
        end
    end
end

function old_load_environment(index)
	copy_map(index * 16, 16, 0, 0, 16, 16)
end