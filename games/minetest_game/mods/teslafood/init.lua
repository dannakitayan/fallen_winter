minetest.register_craftitem("teslafood:frozen_flash", {
	description = "Frozen flesh",
	inventory_image = "frozen_zombie_flesh.png",
	on_use = minetest.item_eat(1),
	groups = {food_bread = 1},
})

minetest.register_craftitem("teslafood:cooked_flash", {
	description = "Cooked flesh",
	inventory_image = "frozen_zombie_flesh.png",
	on_use = minetest.item_eat(1),
	groups = {food_bread = 1},
})