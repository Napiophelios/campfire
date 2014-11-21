--[[
CampFire mod by Doc
[modified by Napiophelios-rev006]

Depends: default, fire

For Minetest 0.4.10 development build (commit d2219171 or later)

License of code : WTFPL

]]

campfire = {}

function default.get_hotbar_bg(x,y)
local out = ""
for i=0,7,1 do
out = out .."image["..x+i..","..y..";1,1;gui_hb_bg.png]"
end
return out
end

function campfire.campfire_active(pos, percent, item_percent)
local formspec =
"size[8,6.75]"..
"bgcolor[#080808BB;true]"..
"background[5,5;1,1;campfire_inv.png;true]"..
"listcolors[#00000069;#5A5A5A;#141318;#30434C;#FFF]"..
"label[2,0;The Campfire is Now Active: "..percent.."%]"..
"label[1,1.75;< Add More Wood]"..
"list[current_name;fuel;0,1.75;1,1;]"..
"list[current_name;src;4,1.75;1,1;]"..
"image[5,1.75;1,1;gui_furnace_arrow_bg.png^[transformR270]"..
"list[current_name;dst;6,1.75;2,1;]"..
"list[current_player;main;0,3;8,1;]"..
"list[current_player;main;0,4;8,3;8]"..
default.get_hotbar_bg(0,3)
return formspec
end

function campfire.get_campfire_active_formspec(pos, percent)
local meta = minetest.get_meta(pos)local inv = meta:get_inventory()
local fuellist = inv:get_list("fuel")
if fuellist then
end
return campfire.campfire_active(pos, percent, item_percent)
end

campfire.campfire_inactive_formspec =
("size[8,6.75]"..
"bgcolor[#080808BB;true]"..
"background[5,5;1,1;campfire_inv.png;true]"..
"listcolors[#00000069;#5A5A5A;#141318;#30434C;#FFF]"..
"label[2,0;The Campfire is out of wood]"..
"label[1,1.75;< Add Some Wood]"..
"list[current_name;fuel;0,1.75;1,1;]"..
"list[current_name;src;4,1.75;1,1;]"..
"image[5,1.75;1,1;gui_furnace_arrow_bg.png^[transformR270]"..
"list[current_name;dst;6,1.75;2,1;]"..
"list[current_player;main;0,3;8,1;]"..
"list[current_player;main;0,4;8,3;8]"..
"list[current_player;main;0,3;8,1;]"..
"list[current_player;main;0,4;8,3;8]")

minetest.register_node("campfire:campfire", {
description = "Camp Fire",
range = 12,
stack_max = 99,
drawtype = 'mesh',
mesh = 'contained_campfire.obj',
tiles = {
{name='campfire_invisible.png', animation={type='vertical_frames', aspect_w=16, aspect_h=16, length=1}}, {name='campfire_logs.png'}},
inventory_image = 'campfire_campfire.png',
wield_image = 'campfire_campfire.png',
walkable = false,
buildable_to = true,
drop = "",
dug_item = '', -- Get nothing
is_ground_content = true,
paramtype = 'light',
sunlight_propagates = true,
light_source =1,
paramtype2 = "facedir",
selection_box = {
type = "fixed",
fixed = { -0.48, -0.5, -0.48, 0.48, -0.5, 0.48 }
},
groups = {cracky=2,attached_node=1,dig_immediate=3},
on_construct = function(pos)
local meta = minetest.get_meta(pos)
meta:set_string('formspec', campfire.campfire_inactive_formspec)
meta:set_string('infotext', 'Campfire')
local inv = meta:get_inventory()
		inv:set_size("fuel", 1)
		inv:set_size("src", 1)
		inv:set_size("dst", 2)
end,
	can_dig = function(pos,player)
		local meta = minetest.env:get_meta(pos);
		local inv = meta:get_inventory()
		if not inv:is_empty("fuel") then
			return false
		elseif not inv:is_empty("dst") then
			return false
		elseif not inv:is_empty("src") then
			return false
		end
		return true
	end,
})


minetest.register_node("campfire:campfire_active", {
description = "Campfire Active",
range = 12,
drawtype = 'mesh',
mesh = 'contained_campfire.obj',
tiles = {
{name='fire_basic_flame_animated.png', animation={type='vertical_frames', aspect_w=16, aspect_h=16, length=2}}, {name='campfire_logs.png'}},
walkable = false,
damage_per_second = 1,
drop = "",
dug_item = '', -- Get nothing
is_ground_content = true,
paramtype = 'light',
sunlight_propagates = true,
light_source =12,
paramtype2 = "facedir",
selection_box = {
type = "fixed",
fixed = { -0.48, -0.5, -0.48, 0.48, -0.5, 0.48 }
},
groups = {cracky=2,hot=2,attached_node=1,dig_immediate=3, not_in_creative_inventory =1},
on_construct = function(pos)
local meta = minetest.env:get_meta(pos)
meta:set_string("formspec", campfire.campfire_inactive_formspec)
meta:set_string("infotext", "Campfire");
local inv = meta:get_inventory()
		inv:set_size("fuel", 1)
		inv:set_size("src", 1)
		inv:set_size("dst", 2)
end,
	can_dig = function(pos,player)
		local meta = minetest.env:get_meta(pos);
		local inv = meta:get_inventory()
		if not inv:is_empty("fuel") then
			return false
		elseif not inv:is_empty("dst") then
			return false
		elseif not inv:is_empty("src") then
			return false
		end
		return true
	end,
})

function hacky_swap_node(pos,name)
	local node = minetest.env:get_node(pos)
	local meta = minetest.env:get_meta(pos)
	local meta0 = meta:to_table()
	if node.name == name then
		return
	end
	node.name = name
	local meta0 = meta:to_table()
	minetest.env:set_node(pos,node)
	meta = minetest.env:get_meta(pos)
	meta:from_table(meta0)
end

minetest.register_abm({
nodenames = {"campfire:campfire","campfire:campfire_active"},
interval = 1.0,
chance = 1,
action = function(pos, node, active_object_count, active_object_count_wider)
local meta = minetest.env:get_meta(pos)
for i, name in ipairs({
    "fuel_totaltime",
    "fuel_time",
				"src_totaltime",
				"src_time"
		}) do
			if meta:get_string(name) == "" then
				meta:set_float(name, 0.0)
			end
		end

		local inv = meta:get_inventory()

		local srclist = inv:get_list("src")
		local cooked = nil

		if srclist then
			cooked = minetest.get_craft_result({method = "cooking", width = 1, items = srclist})
		end

		local was_active = false

		if meta:get_float("fuel_time") < meta:get_float("fuel_totaltime") then
			was_active = true
			meta:set_float("fuel_time", meta:get_float("fuel_time") + 0.25)
   meta:set_float("src_time", meta:get_float("src_time") + 0.25)
			if cooked and cooked.item and meta:get_float("src_time") >= cooked.time then
				-- check if there's room for output in "dst" list
				if inv:room_for_item("dst",cooked.item) then
					-- Put result in "dst" list
					inv:add_item("dst", cooked.item)
					-- take stuff from "src" list
					srcstack = inv:get_stack("src", 1)
					srcstack:take_item()
					inv:set_stack("src", 1, srcstack)
				else
					print("Could not insert '"..cooked.item:to_string().."'")
				end
				meta:set_string("src_time", 0)
			end
		end

if meta:get_float("fuel_time") < meta:get_float("fuel_totaltime") then
minetest.sound_play({name="campfire_small"},{pos=pos}, {max_hear_distance = 1},{loop=true},{gain=0.01})
local percent = math.floor(meta:get_float("fuel_time") /
meta:get_float("fuel_totaltime") * 100)
meta:set_string("infotext","Campfire active: "..percent.."%")
hacky_swap_node(pos,"campfire:campfire_active")
meta:set_string("formspec",
"size[8,6.75]"..
"bgcolor[#080808BB;true]"..
"background[5,5;1,1;campfire_inv.png;true]"..
"listcolors[#00000069;#5A5A5A;#141318;#30434C;#FFF]"..
"label[2,0;The Campfire is Now Active: "..percent.."%]"..
"label[1,1.75;< Add More Wood]"..
"list[current_name;fuel;0,1.75;1,1;]"..
"list[current_name;src;4,1.75;1,1;]"..
"image[5,1.75;1,1;gui_furnace_arrow_bg.png^[transformR270]"..
"list[current_name;dst;6,1.75;2,1;]"..
"list[current_player;main;0,3;8,1;]"..
"list[current_player;main;0,4;8,3;8]"..
"list[current_player;main;0,3;8,1;]"..
"list[current_player;main;0,4;8,3;8]")
return
end

		local fuel = nil
		local cooked = nil
		local fuellist = inv:get_list("fuel")
		local srclist = inv:get_list("src")

		if srclist then
			cooked = minetest.get_craft_result({method = "cooking", width = 1, items = srclist})
		end
		if fuellist then
			fuel = minetest.get_craft_result({method = "fuel", width = 1, items = fuellist})
		end

if fuel.time <= 0 then
meta:set_string("infotext","Put more wood on the fire!")
hacky_swap_node(pos,"campfire:campfire")
meta:set_string("formspec", campfire.campfire_inactive_formspec)
default.get_hotbar_bg(0,2.75)
return
end



		meta:set_string("fuel_totaltime", fuel.time)
		meta:set_string("fuel_time", 0)

		local stack = inv:get_stack("fuel", 1)
		stack:take_item()
		inv:set_stack("fuel", 1, stack)
	end,
})

-- craft recipes
minetest.register_craft({
output = 'campfire:campfire',
recipe = {
{'default:cobble', 'default:cobble', 'default:cobble'},
{'default:cobble', 'fire:basic_flame', 'default:cobble'},
{'default:cobble', 'default:cobble', 'default:cobble'},
}
})
