
--Hammer

minetest.register_tool("teslamaterial:hammer", {
  description = "Tool Hammer",
  inventory_image = "hammer.png",
})

--Scissors

minetest.register_tool("teslamaterial:scissors", {
  description = "Tool Scissors",
  inventory_image = "scissors.png",
  groups = sword,
})

-- Steel plate

minetest.register_craftitem("teslamaterial:steel_plate", {
  description = "Material steel plate",
  inventory_image = "steel_flat.png",
})

-- Steel cord

minetest.register_craftitem("teslamaterial:steel_cord", {
  description = "Material steel cord",
  inventory_image = "steel_cord.png",
})

-- Steel blank

minetest.register_craftitem("teslamaterial:steel_blank", {
  description = "Blank steel bar",
  inventory_image = "steel_blank.png",
})

-- Steel bar

minetest.register_craftitem("teslamaterial:steel_bar", {
  description = "Steel bar",
  inventory_image = "steel_bar.png",
})

minetest.register_craft({
    output = "teslamaterial:hammer",
	recipe = {
		{"", "default:steel_ingot", ""},
		{"", "group:stick", ""},
	}
})

minetest.register_craft({
    output = "teslamaterial:scissors",
	recipe = {
		{"", "teslamaterial:steel_plate", "teslamaterial:steel_plate"},
		{"", "group:stick", "group:stick"},
	}
})

minetest.register_craft({
    output = "teslamaterial:steel_blank",
	recipe = {
		{"teslamaterial:steel_cord", "teslamaterial:steel_cord", "teslamaterial:steel_cord"},
		{"teslamaterial:steel_cord", "group:stick", "teslamaterial:steel_cord"},
	}
})

minetest.register_craft({
    type = "shapeless",
    output = "teslamaterial:steel_plate",
    recipe = {"teslamaterial:hammer", "default:steel_ingot"},
	replacements = {{"teslamaterial:hammer", "teslamaterial:hammer"}},
})

minetest.register_craft({
    type = "shapeless",
	additional_wear = -0.02,
    output = "teslamaterial:steel_cord 5",
    recipe = {"teslamaterial:scissors", "teslamaterial:steel_plate"},
	replacements = {{"teslamaterial:scissors", "teslamaterial:scissors"}},
})

minetest.register_craft({
	type = "cooking",
	output = "teslamaterial:steel_bar",
	recipe = "teslamaterial:steel_blank",
	burntime = 0.4,
})
