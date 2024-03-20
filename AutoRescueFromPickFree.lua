local screenWidth = render.get_screen_size().x
local screenHeight = render.get_screen_size().y

local center = screenWidth / 2

local version = "0.0.8"
local status = "false"
local rescuefrompick_delay = 0
local delay = 0
local timestamp = 0
local press_delay = 0

local ingore_list = {"jineng0", "qiutu_box0", "page0", "note", "_cocoon", "yidhra_ghost", "yidhra_xintu_ghost", "_mirror.gim", "_cat.gim", "_trap.gim", "_wheel.gim", "_jiazi.gim", "_camera.gim", "_console.gim", "_wall.gim", "skill_hudie", "_sprig.gim", "_bomb.gim", "_explode.gim", "chuanhuo", "_statue", "_yucha", "_bird", "_tiaoban", "_baoguo", "_huajia.gim", "_puppy", "frozen_wax", "lod.gim", "shadow_01.gim"}

local hunter_pos = vec3_t.new(0, 0, 0)
local closest = nil

local function contains(table, val)
	for i=1, #table do
		if string.find(val, table[i]) then 
			return true
		end
	end
	return false
end

local function isKeyDown(vKey)
    if menu.is_key_holding(vKey) then
        if key_released and press_delay <= timestamp then
            press_delay = timestamp + 75
            key_released = false  -- 按键被按下，更新状态
            return true
        end
    else
        key_released = true  -- 按键被释放，更新状态
    end
    return false
end

function paint()
	if menu.get_bool("autorescuepick_enable") then
		timestamp = utils.timestamp_ms()
		--if menu.is_key_pressed(menu.get_keybind("autorescuepick_bind"):get_key()) then
		if isKeyDown(menu.get_keybind("autorescuepick_bind"):get_key()) then
			--if status ~= "attack" then
				--status = "true"
			--end
		--else
			--status = "false"
			if status == "true" then
				status = "false"
				print("[AutoRescueFromPick] Disabled")
			elseif status == "attack" then
				status = "false"
				print("[AutoRescueFromPick] Terminated")
			else
				status = "true"
				print("[AutoRescueFromPick] Enabled")
			end
		end
		if status == "true" then

			local text = "AutoRescuePick Enabled" 
			if hunter_name ~= "None" then
				text = "AutoRescuePick Enabled: " .. hunter_name
			end
			local text_size = render.get_text_size(text, 22)
			render.draw_text(center - text_size.x / 2, 230, color.new(2, 232, 5, 200), 22, text)
		elseif status == "attack" then
			local text = "AutoRescuePick: Waiting for the opportunity..."
			local text_size = render.get_text_size(text, 22)
			render.draw_text(center - text_size.x / 2, 230, color.new(2, 232, 5, 200), 22, text)
		end
		if world.get_entity_count() > 0 then
			l_pos = world.get_local_pos()
			local offset = menu.get_int("autorescuepick_offset")
			if closestEntity ~= nil then
				lastClosest = closestEntity
			end
			if lastClosest ~= nil then
				closest = lastClosest
				hunter_pos = closest:get_hidden_pos()
				hunter_name = closest:get_name()
				local screen = world.world_to_screen(hunter_pos)
				local text = "{Target Hunter}"
				local text_size = render.get_text_size(text, 18)
				render.draw_text(screen.x - text_size.x / 2, screen.y - 50, color.new(2, 232, 5, 200), 18, text)
			end
			local closestDistance = math.huge
			for cas = 0, world.get_entity_count() do
				if cas == world.get_entity_count() then break end
				local ent = world.get_entity(cas)
				local ent_modelname = ent:get_model_name()
				if not contains(ingore_list, ent_modelname) and ent:get_size().x ~= 0 then
					ent_pos = ent:get_hidden_pos()
					if ent:get_type() == 2 then
						local screenPosition = world.world_to_screen(ent_pos)
						if screenPosition.x > 0 and screenPosition.y > 0 and screenPosition.x < screenWidth and screenPosition.y < screenHeight then
							local distance = ent_pos:dist(l_pos)
							if distance < closestDistance then
								closestEntity = ent
								closestDistance = distance
							end
						end
					elseif ent:get_type() == 1 and (status == "true" or status == "attack") and closest ~= nil then
						local distance = ent_pos:dist(hunter_pos)
						if status == "true" and distance == 0 then
							if menu.get_bool("autorescuepick_delay") then
								delay = timestamp+offset
								status = "attack"
								cheat.add_event("AutoRescueFromPick: Waiting for the opportunity...")
							else
								rescue_from_pick()
							end
						elseif status == "attack" then
							if delay <= timestamp then
								rescue_from_pick()
							end
						end
					end
				end
			end
		end
	end
end

function rescue_from_pick()
	cheat.add_event("AutoRescueFromPick: Use skill now!")
	timestamp = utils.timestamp_ms()
	if rescuefrompick_delay == 0 or rescuefrompick_delay <= timestamp then
		if menu.get_keybind("autorescuepick_key"):get_key() == 0x01 or menu.get_keybind("autorescuepick_key"):get_key() == 0x02 then
			utils.send_mouse_click_bypass(menu.get_keybind("autorescuepick_key"):get_key())
		else
			utils.send_key(menu.get_keybind("autorescuepick_key"):get_key())
		end
		rescuefrompick_delay = timestamp+math.random(350, 750)
	end
	delay = 0
	status = "false"
end


menu.checkbox("Automatic Rescue From Pick", "autorescuepick_enable", true)
menu.keybind("Bind", "autorescuepick_bind", Keybind.new(0x79, 0))
menu.checkbox("Delay", "autorescuepick_delay", true)
menu.slider_int("Delay Offset", "autorescuepick_offset", 0, 5000, 420)
menu.keybind("Skill Key", "autorescuepick_key", Keybind.new(0x31, 1))


print("[AutoRescueFromPick-FREE] Loaded - V" .. version)
cheat.add_event("[AutoRescueFromPick-FREE] Loaded - V" .. version)

cheat.set_event_callback("on_paint", paint)