

/obj/item/ammo_casing/marines/pistol
	name = "pistol bullet"

	ammo_datum = /datum/marine_ammo/pistol

/datum/marine_ammo/pistol
	name = "pistol bullet"
	// accuracy = -HIT_ACCURACY_TIER_3
	damage = 40
	penetration = ARMOR_PENETRATION_TIER_2
	shrapnel_chance = SHRAPNEL_CHANCE_TIER_2


/obj/item/ammo_casing/marines/pistol/ap
	name = "armor-piercing pistol bullet"

	ammo_datum = /datum/marine_ammo/pistol/ap

/datum/marine_ammo/pistol/ap
	name = "armor-piercing pistol bullet"

	damage = 25
	// accuracy = HIT_ACCURACY_TIER_2
	penetration = ARMOR_PENETRATION_TIER_8
	shrapnel_chance = SHRAPNEL_CHANCE_TIER_2


//-------------------------------------------------------
//88M4 based off VP70

/obj/item/ammo_box/magazine/marines/mod88
	name = "\improper 88M4 AP magazine (9mm)"
	desc = "A 9mm pistol magazine for the Mod88."
	ammo_type = /obj/item/ammo_casing/marines/pistol/ap // O: default_ammo
	caliber = "9mm"
	icon = 'tff_modular/modules/colonial_marines/weapon/icons/WY/pistols_mag.dmi'
	icon_state = "88m4"
	max_ammo = 19 // O: max_rounds
	w_class = WEIGHT_CLASS_NORMAL
	// gun_type =
	ammo_band_icon = "+88m4_band"
	ammo_band_icon_empty = "+88m4_band_e"
	ammo_band_color = "#1F951F" // O: AMMO_BAND_COLOR_AP

	multiple_sprites = AMMO_BOX_FULL_EMPTY





#undef ARMOR_PENETRATION_TIER_1
#undef ARMOR_PENETRATION_TIER_2
#undef ARMOR_PENETRATION_TIER_3
#undef ARMOR_PENETRATION_TIER_4
#undef ARMOR_PENETRATION_TIER_5
#undef ARMOR_PENETRATION_TIER_6
#undef ARMOR_PENETRATION_TIER_7
#undef ARMOR_PENETRATION_TIER_8
#undef ARMOR_PENETRATION_TIER_9
#undef ARMOR_PENETRATION_TIER_10
