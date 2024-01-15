local version = "1.0.0"

local function contains(table, val)
	for i=1, #table do
		if string.find(val, table[i]) then
			return true
		end
	end
	return false
end

function paint()
	if world.get_entity_count() > 0 then
        if menu.get_bool("crowesp_enable") then
            for q = 0, world.get_entity_count() do
                if q == world.get_entity_count() then break end
                --print(cas .. ":" .. world.get_entity_count())
                local ent = world.get_entity(q)
                local ent_model_name = ent:get_model_name()
                if string.find(ent_model_name, "crow") or string.find(ent_model_name, "halloweenbat") then
                    local ent_pos = ent:get_pos()
                    local ent_foot = ent:get_foot_pos()
                    local screen = world.world_to_screen(ent_pos)
                    if screen.x > 0 and screen.y > 0 and screen.x < render.get_screen_size().x and screen.y < render.get_screen_size().y then
                        if ent_foot:dist(ent_pos) >= 15 then
                            local text = "{Scared}"
                            local text_size = render.get_text_size(text, 22)
                            render.draw_text(screen.x - text_size.x / 2, screen.y - text_size.y, color.new(255, 136, 236, 255), 22, text)
                            local ftscreen = world.world_to_screen(ent_foot)
                            local text = "Crow"
                            local text_size = render.get_text_size(text, 12)
                            render.draw_text(ftscreen.x - text_size.x / 2, ftscreen.y - text_size.y, color.new(255, 136, 236, 255), 12, text)
                            render.draw_line(screen.x, screen.y, ftscreen.x - screen.x, ftscreen.y - screen.y, color.new(255, 136, 236, 255))
                        else
                            local text = "Crow"
                            local text_size = render.get_text_size(text, 12)
                            render.draw_text(screen.x - text_size.x / 2, screen.y - text_size.y, color.new(255, 136, 236, 255), 12, text)
                        end
                    end
                end
            end
        end
    end
end

menu.checkbox("Enable", "crowesp_enable", true)

print("[CrowESP] Loaded - V" .. version)
cheat.add_event("CrowESP: Loaded - V" .. version)

cheat.set_event_callback("on_paint", paint)