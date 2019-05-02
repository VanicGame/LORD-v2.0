--
-- Sounds
--

function lord_base.node_sound_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name = "", gain = 1.0}
	table.dug = table.dug or
			{name = "lord_base_dug_node", gain = 0.25}
	table.place = table.place or
			{name = "lord_base_place_node_hard", gain = 1.0}
	return table
end

function lord_base.node_sound_stone_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name = "lord_base_hard_footstep", gain = 0.3}
	table.dug = table.dug or
			{name = "lord_base_hard_footstep", gain = 1.0}
	lord_base.node_sound_defaults(table)
	return table
end

function lord_base.node_sound_dirt_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name = "lord_base_dirt_footstep", gain = 0.4}
	table.dug = table.dug or
			{name = "lord_base_dirt_footstep", gain = 1.0}
	table.place = table.place or
			{name = "lord_base_place_node", gain = 1.0}
	lord_base.node_sound_defaults(table)
	return table
end

function lord_base.node_sound_sand_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name = "lord_base_sand_footstep", gain = 0.12}
	table.dug = table.dug or
			{name = "lord_base_sand_footstep", gain = 0.24}
	table.place = table.place or
			{name = "lord_base_place_node", gain = 1.0}
	lord_base.node_sound_defaults(table)
	return table
end

function lord_base.node_sound_gravel_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name = "lord_base_gravel_footstep", gain = 0.4}
	table.dug = table.dug or
			{name = "lord_base_gravel_footstep", gain = 1.0}
	table.place = table.place or
			{name = "lord_base_place_node", gain = 1.0}
	lord_base.node_sound_defaults(table)
	return table
end

function lord_base.node_sound_wood_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name = "lord_base_wood_footstep", gain = 0.3}
	table.dug = table.dug or
			{name = "lord_base_wood_footstep", gain = 1.0}
	lord_base.node_sound_defaults(table)
	return table
end

function lord_base.node_sound_leaves_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name = "lord_base_grass_footstep", gain = 0.45}
	table.dug = table.dug or
			{name = "lord_base_grass_footstep", gain = 0.7}
	table.place = table.place or
			{name = "lord_base_place_node", gain = 1.0}
	lord_base.node_sound_defaults(table)
	return table
end

function lord_base.node_sound_glass_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name = "lord_base_glass_footstep", gain = 0.3}
	table.dig = table.dig or
			{name = "lord_base_glass_footstep", gain = 0.5}
	table.dug = table.dug or
			{name = "lord_base_break_glass", gain = 1.0}
	lord_base.node_sound_defaults(table)
	return table
end

function lord_base.node_sound_metal_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name = "lord_base_metal_footstep", gain = 0.4}
	table.dig = table.dig or
			{name = "lord_base_dig_metal", gain = 0.5}
	table.dug = table.dug or
			{name = "lord_base_dug_metal", gain = 0.5}
	table.place = table.place or
			{name = "lord_base_place_node_metal", gain = 0.5}
	lord_base.node_sound_defaults(table)
	return table
end

function lord_base.node_sound_water_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name = "lord_base_water_footstep", gain = 0.2}
	lord_base.node_sound_defaults(table)
	return table
end

function lord_base.node_sound_snow_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name = "lord_base_snow_footstep", gain = 0.2}
	table.dig = table.dig or
			{name = "lord_base_snow_footstep", gain = 0.3}
	table.dug = table.dug or
			{name = "lord_base_snow_footstep", gain = 0.3}
	table.place = table.place or
			{name = "lord_base_place_node", gain = 1.0}
	lord_base.node_sound_defaults(table)
	return table
end


--
-- Lavacooling
--

lord_base.cool_lava = function(pos, node)
	if node.name == "lord_base:lava_source" then
		minetest.set_node(pos, {name = "lord_base:obsidian"})
	else -- Lava flowing
		minetest.set_node(pos, {name = "lord_base:stone"})
	end
	minetest.sound_play("lord_base_cool_lava",
		{pos = pos, max_hear_distance = 16, gain = 0.25})
end

if minetest.settings:get_bool("enable_lavacooling") ~= false then
	minetest.register_abm({
		label = "Lava cooling",
		nodenames = {"lord_base:lava_source", "lord_base:lava_flowing"},
		neighbors = {"group:cools_lava", "group:water"},
		interval = 2,
		chance = 2,
		catch_up = false,
		action = function(...)
			lord_base.cool_lava(...)
		end,
	})
end


--
-- Optimized helper to put all items in an inventory into a drops list
--

function lord_base.get_inventory_drops(pos, inventory, drops)
	local inv = minetest.get_meta(pos):get_inventory()
	local n = #drops
	for i = 1, inv:get_size(inventory) do
		local stack = inv:get_stack(inventory, i)
		if stack:get_count() > 0 then
			drops[n+1] = stack:to_table()
			n = n + 1
		end
	end
end


--
-- Papyrus and cactus growing
--

-- Wrapping the functions in ABM action is necessary to make overriding them possible

function lord_base.grow_cactus(pos, node)
	if node.param2 >= 4 then
		return
	end
	pos.y = pos.y - 1
	if minetest.get_item_group(minetest.get_node(pos).name, "sand") == 0 then
		return
	end
	pos.y = pos.y + 1
	local height = 0
	while node.name == "lord_base:cactus" and height < 4 do
		height = height + 1
		pos.y = pos.y + 1
		node = minetest.get_node(pos)
	end
	if height == 4 or node.name ~= "air" then
		return
	end
	if minetest.get_node_light(pos) < 13 then
		return
	end
	minetest.set_node(pos, {name = "lord_base:cactus"})
	return true
end

function lord_base.grow_papyrus(pos, node)
	pos.y = pos.y - 1
	local name = minetest.get_node(pos).name
	if name ~= "lord_base:dirt_with_grass" and name ~= "lord_base:dirt" then
		return
	end
	if not minetest.find_node_near(pos, 3, {"group:water"}) then
		return
	end
	pos.y = pos.y + 1
	local height = 0
	while node.name == "lord_base:papyrus" and height < 4 do
		height = height + 1
		pos.y = pos.y + 1
		node = minetest.get_node(pos)
	end
	if height == 4 or node.name ~= "air" then
		return
	end
	if minetest.get_node_light(pos) < 13 then
		return
	end
	minetest.set_node(pos, {name = "lord_base:papyrus"})
	return true
end

minetest.register_abm({
	label = "Grow cactus",
	nodenames = {"lord_base:cactus"},
	neighbors = {"group:sand"},
	interval = 12,
	chance = 83,
	action = function(...)
		lord_base.grow_cactus(...)
	end
})

minetest.register_abm({
	label = "Grow papyrus",
	nodenames = {"lord_base:papyrus"},
	neighbors = {"lord_base:dirt", "lord_base:dirt_with_grass"},
	interval = 14,
	chance = 71,
	action = function(...)
		lord_base.grow_papyrus(...)
	end
})


--
-- Dig upwards
--

function lord_base.dig_up(pos, node, digger)
	if digger == nil then return end
	local np = {x = pos.x, y = pos.y + 1, z = pos.z}
	local nn = minetest.get_node(np)
	if nn.name == node.name then
		minetest.node_dig(np, nn, digger)
	end
end


--
-- Fence registration helper
--

function lord_base.register_fence(name, def)
	minetest.register_craft({
		output = name .. " 4",
		recipe = {
			{ def.material, 'group:stick', def.material },
			{ def.material, 'group:stick', def.material },
		}
	})

	local fence_texture = "lord_base_fence_overlay.png^" .. def.texture ..
			"^lord_base_fence_overlay.png^[makealpha:255,126,126"
	-- Allow almost everything to be overridden
	local lord_base_fields = {
		paramtype = "light",
		drawtype = "nodebox",
		node_box = {
			type = "connected",
			fixed = {{-1/8, -1/2, -1/8, 1/8, 1/2, 1/8}},
			-- connect_top =
			-- connect_bottom =
			connect_front = {{-1/16,3/16,-1/2,1/16,5/16,-1/8},
				{-1/16,-5/16,-1/2,1/16,-3/16,-1/8}},
			connect_left = {{-1/2,3/16,-1/16,-1/8,5/16,1/16},
				{-1/2,-5/16,-1/16,-1/8,-3/16,1/16}},
			connect_back = {{-1/16,3/16,1/8,1/16,5/16,1/2},
				{-1/16,-5/16,1/8,1/16,-3/16,1/2}},
			connect_right = {{1/8,3/16,-1/16,1/2,5/16,1/16},
				{1/8,-5/16,-1/16,1/2,-3/16,1/16}},
		},
		connects_to = {"group:fence", "group:wood", "group:tree", "group:wall"},
		inventory_image = fence_texture,
		wield_image = fence_texture,
		tiles = {def.texture},
		sunlight_propagates = true,
		is_ground_content = false,
		groups = {},
	}
	for k, v in pairs(lord_base_fields) do
		if def[k] == nil then
			def[k] = v
		end
	end

	-- Always add to the fence group, even if no group provided
	def.groups.fence = 1

	def.texture = nil
	def.material = nil

	minetest.register_node(name, def)
end


--
-- Fence rail registration helper
--

function lord_base.register_fence_rail(name, def)
	minetest.register_craft({
		output = name .. " 16",
		recipe = {
			{ def.material, def.material },
			{ "", ""},
			{ def.material, def.material },
		}
	})

	local fence_rail_texture = "lord_base_fence_rail_overlay.png^" .. def.texture ..
			"^lord_base_fence_rail_overlay.png^[makealpha:255,126,126"
	-- Allow almost everything to be overridden
	local lord_base_fields = {
		paramtype = "light",
		drawtype = "nodebox",
		node_box = {
			type = "connected",
			fixed = {
				{-1/16,  3/16, -1/16, 1/16,  5/16, 1/16},
				{-1/16, -3/16, -1/16, 1/16, -5/16, 1/16}
			},
			-- connect_top =
			-- connect_bottom =
			connect_front = {
				{-1/16,  3/16, -1/2, 1/16,  5/16, -1/16},
				{-1/16, -5/16, -1/2, 1/16, -3/16, -1/16}},
			connect_left = {
				{-1/2,  3/16, -1/16, -1/16,  5/16, 1/16},
				{-1/2, -5/16, -1/16, -1/16, -3/16, 1/16}},
			connect_back = {
				{-1/16,  3/16, 1/16, 1/16,  5/16, 1/2},
				{-1/16, -5/16, 1/16, 1/16, -3/16, 1/2}},
			connect_right = {
				{1/16,  3/16, -1/16, 1/2,  5/16, 1/16},
				{1/16, -5/16, -1/16, 1/2, -3/16, 1/16}},
		},
		connects_to = {"group:fence", "group:wall"},
		inventory_image = fence_rail_texture,
		wield_image = fence_rail_texture,
		tiles = {def.texture},
		sunlight_propagates = true,
		is_ground_content = false,
		groups = {},
	}
	for k, v in pairs(lord_base_fields) do
		if def[k] == nil then
			def[k] = v
		end
	end

	-- Always add to the fence group, even if no group provided
	def.groups.fence = 1

	def.texture = nil
	def.material = nil

	minetest.register_node(name, def)
end


--
-- Leafdecay
--

-- Prevent decay of placed leaves

lord_base.after_place_leaves = function(pos, placer, itemstack, pointed_thing)
	if placer and placer:is_player() and not placer:get_player_control().sneak then
		local node = minetest.get_node(pos)
		node.param2 = 1
		minetest.set_node(pos, node)
	end
end

-- Leafdecay
local function leafdecay_after_destruct(pos, oldnode, def)
	for _, v in pairs(minetest.find_nodes_in_area(vector.subtract(pos, def.radius),
			vector.add(pos, def.radius), def.leaves)) do
		local node = minetest.get_node(v)
		local timer = minetest.get_node_timer(v)
		if node.param2 == 0 and not timer:is_started() then
			timer:start(math.random(20, 120) / 10)
		end
	end
end

local function leafdecay_on_timer(pos, def)
	if minetest.find_node_near(pos, def.radius, def.trunks) then
		return false
	end

	local node = minetest.get_node(pos)
	local drops = minetest.get_node_drops(node.name)
	for _, item in ipairs(drops) do
		local is_leaf
		for _, v in pairs(def.leaves) do
			if v == item then
				is_leaf = true
			end
		end
		if minetest.get_item_group(item, "leafdecay_drop") ~= 0 or
				not is_leaf then
			minetest.add_item({
				x = pos.x - 0.5 + math.random(),
				y = pos.y - 0.5 + math.random(),
				z = pos.z - 0.5 + math.random(),
			}, item)
		end
	end

	minetest.remove_node(pos)
	minetest.check_for_falling(pos)
end

function lord_base.register_leafdecay(def)
	assert(def.leaves)
	assert(def.trunks)
	assert(def.radius)
	for _, v in pairs(def.trunks) do
		minetest.override_item(v, {
			after_destruct = function(pos, oldnode)
				leafdecay_after_destruct(pos, oldnode, def)
			end,
		})
	end
	for _, v in pairs(def.leaves) do
		minetest.override_item(v, {
			on_timer = function(pos)
				leafdecay_on_timer(pos, def)
			end,
		})
	end
end


--
-- Convert dirt to something that fits the environment
--

minetest.register_abm({
	label = "Grass spread",
	nodenames = {"lord_base:dirt"},
	neighbors = {
		"air",
		"group:grass",
		"group:dry_grass",
		"lord_base:snow",
	},
	interval = 6,
	chance = 50,
	catch_up = false,
	action = function(pos, node)
		-- Check for darkness: night, shadow or under a light-blocking node
		-- Returns if ignore above
		local above = {x = pos.x, y = pos.y + 1, z = pos.z}
		if (minetest.get_node_light(above) or 0) < 13 then
			return
		end

		-- Look for spreading dirt-type neighbours
		local p2 = minetest.find_node_near(pos, 1, "group:spreading_dirt_type")
		if p2 then
			local n3 = minetest.get_node(p2)
			minetest.set_node(pos, {name = n3.name})
			return
		end

		-- Else, any seeding nodes on top?
		local name = minetest.get_node(above).name
		-- Snow check is cheapest, so comes first
		if name == "lord_base:snow" then
			minetest.set_node(pos, {name = "lord_base:dirt_with_snow"})
		-- Most likely case first
		elseif minetest.get_item_group(name, "grass") ~= 0 then
			minetest.set_node(pos, {name = "lord_base:dirt_with_grass"})
		elseif minetest.get_item_group(name, "dry_grass") ~= 0 then
			minetest.set_node(pos, {name = "lord_base:dirt_with_dry_grass"})
		end
	end
})


--
-- Grass and dry grass removed in darkness
--

minetest.register_abm({
	label = "Grass covered",
	nodenames = {"group:spreading_dirt_type"},
	interval = 8,
	chance = 50,
	catch_up = false,
	action = function(pos, node)
		local above = {x = pos.x, y = pos.y + 1, z = pos.z}
		local name = minetest.get_node(above).name
		local nodedef = minetest.registered_nodes[name]
		if name ~= "ignore" and nodedef and not ((nodedef.sunlight_propagates or
				nodedef.paramtype == "light") and
				nodedef.liquidtype == "none") then
			minetest.set_node(pos, {name = "lord_base:dirt"})
		end
	end
})


--
-- Moss growth on cobble near water
--

local moss_correspondences = {
	["lord_base:cobble"] = "lord_base:mossycobble",
	["stairs:slab_cobble"] = "stairs:slab_mossycobble",
	["stairs:stair_cobble"] = "stairs:stair_mossycobble",
	["stairs:stair_inner_cobble"] = "stairs:stair_inner_mossycobble",
	["stairs:stair_outer_cobble"] = "stairs:stair_outer_mossycobble",
	["walls:cobble"] = "walls:mossycobble",
}
minetest.register_abm({
	label = "Moss growth",
	nodenames = {"lord_base:cobble", "stairs:slab_cobble", "stairs:stair_cobble",
		"stairs:stair_inner_cobble", "stairs:stair_outer_cobble",
		"walls:cobble"},
	neighbors = {"group:water"},
	interval = 16,
	chance = 200,
	catch_up = false,
	action = function(pos, node)
		node.name = moss_correspondences[node.name]
		minetest.set_node(pos, node)
	end
})


--
-- NOTICE: This method is not an official part of the API yet.
-- This method may change in future.
--

function lord_base.can_interact_with_node(player, pos)
	if player then
		if minetest.check_player_privs(player, "protection_bypass") then
			return true
		end
	else
		return false
	end

	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner")

	if not owner or owner == "" or owner == player:get_player_name() then
		return true
	end

	-- Is player wielding the right key?
	local item = player:get_wielded_item()
	if item:get_name() == "lord_base:key" then
		local key_meta = item:get_meta()

		if key_meta:get_string("secret") == "" then
			local key_oldmeta = item:get_metadata()
			if key_oldmeta == "" or not minetest.parse_json(key_oldmeta) then
				return false
			end

			key_meta:set_string("secret", minetest.parse_json(key_oldmeta).secret)
			item:set_metadata("")
		end

		return meta:get_string("key_lock_secret") == key_meta:get_string("secret")
	end

	return false
end
