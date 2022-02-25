
cold = {}

COLD_TICK = 8		-- time in seconds after that 1 cold point is taken
COLD_TICK_MIN = 1		-- cold ticks won't reduce cold below this level
COLD_HEALTH_TICK = 4		-- time in seconds after player gets healed/damaged

COLD_HEAL = 1		-- number of HP player gets healed after cold_HEALTH_TICK
COLD_HEAL_LVL = 5		-- lower level of saturation needed to get healed
COLD_STARVE = 1		-- number of HP player gets damaged by cold after cold_HEALTH_TICK
COLD_STARVE_LVL = 3		-- level of staturation that causes starving

COLD_VISUAL_MAX = 20		-- hud bar extends only to 20

local function get_int_attribute(player, key)
	local level = player:get_attribute(key)
	if level then
		return tonumber(level)
	else
		return nil
	end
end

local function cold_update_level(player, level)
	local old = get_int_attribute(player, "cold:level")

	if level == old then  -- To suppress HUD update
		return
	end
	
	if old > COLD_VISUAL_MAX then
		player:set_attribute("cold:level", COLD_VISUAL_MAX)
		return
	else
		player:set_attribute("cold:level", level)
	end
	player:hud_change(player:get_attribute("cold:hud_id"), "number", math.min(COLD_VISUAL_MAX, level))
end

--[[
local function cold_get_freezing(player)
	return get_int_attribute(player, "cold:freezing")
end
]]--

-- global function for mods to amend cold level
cold.change = function(player, change)
	local name = player:get_player_name()
	if not name or not change or change == 0 then
		return false
	end
	local level = get_int_attribute(player, "cold:level") + change
	if level < 0 then level = 0 end
	if level > COLD_VISUAL_MAX then level = COLD_VISUAL_MAX end
	cold_update_level(player, level)
	return true
end

-- Sprint settings and function
local enable_sprint = minetest.setting_getbool("sprint") ~= true
local enable_sprint_particles = minetest.setting_getbool("sprint_particles") ~= false
local armor_mod = minetest.get_modpath("3d_armor")

--[[
function set_sprinting(name, sprinting)
	local player = minetest.get_player_by_name(name)
	local def = {}
	-- Get player physics from 3d_armor mod
	if armor_mod and armor and armor.def then
		def.speed = armor.def[name].speed
		def.jump = armor.def[name].jump
		def.gravity = armor.def[name].gravity
	end

	def.speed = def.speed or 1
	def.jump = def.jump or 1
	def.gravity = def.gravity or 1

	if sprinting == true then

		def.speed = def.speed + SPRINT_SPEED
		def.jump = def.jump + SPRINT_JUMP
	end

	player:set_physics_override({
		speed = def.speed,
		jump = def.jump,
		gravity = def.gravity
	})
end
]]--

-- Time based cold functions
local cold_timer = 0
local health_timer = 0

local function cold_globaltimer(dtime)
	cold_timer = cold_timer + dtime
	health_timer = health_timer + dtime

	-- lower saturation by 1 point after cold_TICK second(s)
	if cold_timer > COLD_TICK then
		for _,player in ipairs(minetest.get_connected_players()) do
			local h = get_int_attribute(player, "cold:level")
			local controls = player:get_player_control()
			if h > COLD_TICK_MIN then		
			-- Determine if the player is walking
				if controls.up or controls.down or controls.left or controls.right then
					cold_update_level(player, h + 0.5)
				else
					cold_update_level(player, h - 2)
				end
			end
		end
		cold_timer = 0
	end

	-- heal or damage player, depending on saturation
	if health_timer > COLD_HEALTH_TICK then
		for _,player in ipairs(minetest.get_connected_players()) do
			local hp = player:get_hp()

			-- or damage player by 1 hp if saturation is < 2 (of 30)
			if get_int_attribute(player, "cold:level") < COLD_STARVE_LVL then
				player:set_hp(hp - COLD_STARVE)
			end
		end

		health_timer = 0
	end
end

-- cold is disabled if damage is disabled
if minetest.setting_getbool("enable_damage") and minetest.is_yes(minetest.setting_get("enable_cold") or "1") then
	minetest.register_on_joinplayer(function(player)
		local level = COLD_VISUAL_MAX -- TODO
		if get_int_attribute(player, "cold:level") then
			level = math.min(get_int_attribute(player, "cold:level"), COLD_VISUAL_MAX)
		else
			player:set_attribute("cold:level", level)
		end
		local id = player:hud_add({
			name = "cold",
			hud_elem_type = "statbar",
			position = {x = 0.5, y = 1},
			size = {x = 24, y = 24},
			text = "warm_hud_point.png",
			number = level,
			alignment = {x = -1, y = -1},
			offset = {x = -266, y = -134},
			max = 0,
		})
		player:set_attribute("cold:hud_id", id)
	end)

	minetest.register_globalstep(cold_globaltimer)

--[[
	minetest.register_on_placenode(function(pos, oldnode, player, ext)
		freeze_player(player, COLD_EXHAUST_PLACE)
	end)
	minetest.register_on_dignode(function(pos, oldnode, player, ext)
		freeze_player(player, COLD_EXHAUST_DIG)
	end)
	minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
		freeze_player(player, COLD_EXHAUST_CRAFT)
	end)
	minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
		freeze_player(hitter, COLD_EXHAUST_PUNCH)
	end)
	]]--

	minetest.register_on_respawnplayer(function(player)
		cold_update_level(player, COLD_VISUAL_MAX)
	end)
end
