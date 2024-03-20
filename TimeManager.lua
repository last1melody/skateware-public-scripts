local speed = 0
local lastPosition = nil
local startTime = nil
local ingore_list = {"pendant", "jineng0", "_box0", "page0", "_page.gim", "note", "cocoon","yidhra_d_bobao", "yidhra_d_bobao", "yidhra_ghost", "yidhra_xintu_ghost", "girl_ghost", "gallows", "_stone_yulan.gim"}
local chest = {"scene_prop_01", "halloweenbox", "christmasbox"}

local function contains(table, val)
	for i=1, #table do
		if string.find(val, table[i]) then 
			return true
		end
	end
	return false
end

function calculate_speed_and_time()
    local timestamp = utils.timestamp_ms()
    local currentPosition = world.get_local_pos()

    if currentPosition then
        if lastPosition then
            local deltaTime = timestamp - startTime
            local distance = currentPosition:dist(lastPosition)
            speed = (distance / deltaTime)*1000
            --cheat.add_event(string.format("Speed: %.2f units/second", speed))
        end
        lastPosition = currentPosition
        startTime = timestamp
    end
end

function paint()
    local currentTime = utils.timestamp_ms()
    local currentPosition = world.get_local_pos()
    if not startTime or currentTime - startTime >= 1000 then
        calculate_speed_and_time()
        --cheat.add_event(tostring(speed))
    end
    for cas = 0, world.get_entity_count() do
        local ent = world.get_entity(cas)
        local ent_model_name = ent:get_model_name()
        local ent_size = ent:get_size()
        if ent_size.x == 1 then
            local ent_type = ent:get_type()
            if (ent_type == 1 or ent_type == 2) and not contains(ingore_list, ent_model_name) and ent:get_head_pos().y ~= 100000 and ent:is_initialized() then
                local pos = ent:get_hidden_pos()
                local timeToReachTarget = math.floor(currentPosition:dist(pos) / speed)
                local screen = world.world_to_screen(pos)
                local speed_text = "" .. timeToReachTarget .. " seconds"
                if timeToReachTarget == math.huge or timeToReachTarget < 0 then
                    speed_text = "never"
                end
                local color = color.new(239, 88, 89)
                if timeToReachTarget < 10 then
                    color = color.new(102, 255, 134)
                elseif timeToReachTarget < 20 then
                    color = color.new(253, 212, 95)
                elseif timeToReachTarget < 30 then
                    color = color.new(242, 148, 63)
                end
                if screen.x > 0 and screen.y > 0 and timeToReachTarget ~= 0 then
                    local text_size = render.get_text_size(speed_text, 16)
                    render.draw_text(screen.x - text_size.x / 2, screen.y - text_size.y, color, 16, speed_text)
                end
            end
        end
    end
end

cheat.set_event_callback("on_paint", paint)