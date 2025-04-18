/obj/item/gun/ballistic/revolver/ocelot
	name = "Colt Peacemaker revolver"
	desc = "A modified Peacemaker revolver that chambers .357 ammo. Less powerful than the regular .357, but ricochets a lot more." // We need tension...conflict. The world today has become too soft. We're living in an age where true feelings are suppressed. So we're going to shake things up a bit. We'll create a world dripping with tension... ...a world filled with greed and suspicion, bravery and cowardice.
	// this could probably be made funnier by reducing its damage multiplier but also making it so that every fired bullet has the wacky ricochets
	// but that's a different plate of cookies for a different glass of milk
	icon_state = "c38_panther"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/cylinder

/obj/item/ammo_casing/c357/peacemaker
	name = ".357 Peacemaker bullet casing"
	desc = "A .357 Peacemaker bullet casing."
	caliber = CALIBER_357
	projectile_type = /obj/projectile/bullet/a357/peacemaker

/obj/projectile/bullet/a357/peacemaker
	name = ".357 Peacemaker bullet"
	damage = 25
	wound_bonus = 0
	ricochets_max = 6
	ricochet_chance = 200
	ricochet_auto_aim_angle = 50
	ricochet_auto_aim_range = 6
	ricochet_incidence_leeway = 80
	ricochet_decay_chance = 1

/datum/design/a357/peacemaker
	name = "Speed Loader (.357 Peacemaker)"
	id = "a357PM"
	build_type = AUTOLATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
	)
	build_path = /obj/item/ammo_box/a357/peacemaker
	category = list(
		RND_CATEGORY_HACKED,
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)

/obj/item/ammo_box/a357/peacemaker
	name = "speed loader (.357 Peacemaker)"
	desc = "Designed to quickly reload revolvers."
	icon_state = "357"
	ammo_type = /obj/item/ammo_casing/c357/peacemaker
	max_ammo = 7
	multiple_sprites = AMMO_BOX_PER_BULLET
	item_flags = NO_MAT_REDEMPTION


/obj/item/clothing/head/hats/sus_bowler
	name = "odd bowler"
	desc = "A deep black bowler. Inside the hat, there is a sleek red S, with a smaller X insignia embroidered within. On closer inspection, the brim feels oddly weighted..."
	icon_state = "bowler"
	force = 10
	throwforce = 45
	throw_speed = 5
	throw_range = 9
	w_class = WEIGHT_CLASS_SMALL
	armour_penetration = 30 //5 points less then a double esword!
	sharpness = SHARP_POINTY
	attack_verb_continuous = list("slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")

///obj/item/clothing/head/hats/sus_bowler/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	//var/caught = hit_atom.hitby(src, FALSE, FALSE, throwingdatum=throwingdatum)
	//if(thrownby && !caught)
		//addtimer(CALLBACK(src, TYPE_PROC_REF(/atom/movable, throw_at), thrownby, throw_range+2, throw_speed, null, TRUE), 1)
	//else
		//return ..()

///obj/item/clothing/head/hats/sus_bowler/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback, force, gentle = FALSE, quickstart = TRUE)
	//if(ishuman(thrower))
		//var/mob/living/carbon/human/I = thrower
		//I.throw_mode_off(THROW_MODE_TOGGLE) //so they can catch it on the return.
	//return ..()

//nullrod katana
/obj/item/katana/weak/curator //This has the same stats as the curator's claymore
	desc = "An ancient Katana. Forged by... Well, it doesn't really say, but surely it's authentic! And sharp to boot!"
	force = 15
	block_chance = 30
	armour_penetration = 5
