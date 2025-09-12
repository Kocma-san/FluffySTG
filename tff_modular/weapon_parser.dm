

/*
 * target_path - Тип объекта, подтипы которого нужно проверить
 * output_file - Файл в который будет записана информация
 * required_data - Список формата "название_столбца" = "название_переменной"
 */
/proc/parse_atom_subtypes(target_path, output_file, list/required_data)
	output_file << "<table border=\"1\"><thead><tr>"

	for(var/data_name in required_data)
		output_file << "<th>[data_name]</th>"

	output_file << "</tr></thead>"
	output_file << "<tbody>"

	for(var/item_subtype in typesof(target_path))
		var/item_instance = new item_subtype
		output_file << "<tr>"
		for(var/data_name in required_data)
			var/required_var = required_data[data_name]
			output_file << "<td>[item_instance?:vars[required_var]]</td>"
		output_file << "</tr>"
		qdel(item_instance)

	output_file << "</tbody></table>"


/proc/parse_ballistic_to_html()
	var/target_path = /obj/item/gun/ballistic
	var/output_file = file("tff_modular/ballistics.html")
	var/list/required_data = list(
		"Weapon Path" = "type",
		"Weapon Name" = "name",
		"projectile_damage_multiplier" = "projectile_damage_multiplier",
		"projectile_wound_bonus" = "projectile_wound_bonus",
		"projectile_speed_multiplier" = "projectile_speed_multiplier",
		"recoil" = "recoil",
		"spread" = "spread",
		"burst_size" = "burst_size",
		"burst_delay" = "burst_delay",
		"fire_delay" = "fire_delay",
		"firing_burst" = "firing_burst",
		"weapon_weight" = "weapon_weight",
		"accepted_magazine_type" = "accepted_magazine_type",
		"semi_auto" = "semi_auto",
		"tac_reloads" = "tac_reloads",
	)
	parse_atom_subtypes(target_path, output_file, required_data)

/proc/parse_energy_to_html()
	var/target_path = /obj/item/gun/energy
	var/output_file = file("tff_modular/energy.html")
	var/list/required_data = list(
		"Weapon Path" = "type",
		"Weapon Name" = "name",
		"projectile_damage_multiplier" = "projectile_damage_multiplier",
		"projectile_wound_bonus" = "projectile_wound_bonus",
		"projectile_speed_multiplier" = "projectile_speed_multiplier",
		"recoil" = "recoil",
		"spread" = "spread",
		"burst_size" = "burst_size",
		"burst_delay" = "burst_delay",
		"fire_delay" = "fire_delay",
		"firing_burst" = "firing_burst",
		"weapon_weight" = "weapon_weight",
		"ammo_type" = "ammo_type",
		"cell_type" = "cell_type",
		"can_charge" = "can_charge",
		"selfcharge" = "selfcharge",
		"self_charge_amount" = "self_charge_amount",
		"charge_delay" = "charge_delay",
	)
	parse_atom_subtypes(target_path, output_file, required_data)

/proc/parse_magazine_to_html()
	var/target_path = /obj/item/ammo_box/magazine
	var/output_file = file("tff_modular/magazine.html")
	var/list/required_data = list(
		"Path" = "type",
		"Name" = "name",
		"caliber" = "caliber",
		"ammo_type" = "ammo_type",
		"max_ammo" = "max_ammo",
	)
	parse_atom_subtypes(target_path, output_file, required_data)

/proc/parse_casing_to_html()
	var/target_paths = list()
	var/output_file = file("tff_modular/ammo.html")
	var/list/required_data = list(
		"Path" = "type",
		"Name" = "name",
		"caliber" = "caliber",
		"delay" = "delay",
		"projectile_type" = "projectile_type",
	)
	var/list/additional_data = list(
		"projectile_speed" = "speed",
		"projectile_is_hitscan" = "hitscan",
		"projectile_damage" = "damage",
		"projectile_damage_type" = "damage_type",
		"projectile_armor_flag" = "armor_flag",
		"projectile_armour_penetration" = "armour_penetration",
		"projectile_weak_against_armour" = "weak_against_armour",
		"projectile_range" = "range",
		"projectile_reflectable" = "reflectable",
		"projectile_stun" = "stun",
		"projectile_knockdown" = "knockdown",
		"projectile_paralyze" = "paralyze",
		"projectile_immobilize" = "immobilize",
		"projectile_unconscious" = "unconscious",
		"projectile_eyeblur" = "eyeblur",
		"projectile_drowsy" = "drowsy",
		"projectile_jitter" = "jitter",
		"projectile_stamina" = "stamina",
		"projectile_stutter" = "stutter",
		"projectile_slur" = "slur",
		"projectile_dismemberment" = "dismemberment",
	)

	for(var/item_subtype in subtypesof(/obj/item/ammo_casing))
		var/item_instance = new item_subtype
		if(!isnull(item_instance?:caliber))
			target_paths += item_subtype
		qdel(item_instance)

	output_file << "<table border=\"1\"><thead><tr>"

	for(var/data_name in required_data)
		output_file << "<th>[data_name]</th>"
	for(var/data_name in additional_data)
		output_file << "<th>[data_name]</th>"

	output_file << "</tr></thead>"
	output_file << "<tbody>"

	for(var/item_subtype in target_paths)
		var/item_instance = new item_subtype
		output_file << "<tr>"
		for(var/data_name in required_data)
			var/required_var = required_data[data_name]
			output_file << "<td>[item_instance?:vars[required_var]]</td>"

		var/proj_type = item_instance?:projectile_type
		if(ispath(proj_type))
			var/proj_instance = new proj_type
			for(var/data_name in additional_data)
				var/required_var = additional_data[data_name]
				output_file << "<td>[proj_instance?:vars[required_var]]</td>"
			qdel(proj_instance)

		output_file << "</tr>"
		qdel(item_instance)

	output_file << "</tbody></table>"
