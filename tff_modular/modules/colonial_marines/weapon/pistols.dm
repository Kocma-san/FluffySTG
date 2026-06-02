// FROM code\modules\projectiles\guns\pistols.dm

//-------------------------------------------------------
//Smartpistol. An IFF pistol, pretty much.
/*
/obj/item/gun/pistol/smart
	name = "\improper SU-6 Smartpistol"
	desc = "The SU-6 Smartpistol is an IFF-based sidearm currently undergoing field testing in the Colonial Marines. Uses modified .45 ACP IFF bullets. Capable of firing in bursts."
	icon = 'tff_modular/modules/colonial_marines/weapon/icons/USMC/pistols.dmi'
	icon_state = "smartpistol"
	item_state = "smartpistol"
	force = 8
	current_mag = /obj/item/ammo_magazine/pistol/smart
	fire_sound = 'sound/weapons/gun_su6.ogg'
	reload_sound = 'tff_modular/modules/colonial_marines/weapon/sound/gun_su6_reload.ogg'
	unload_sound = 'tff_modular/modules/colonial_marines/weapon/sound/gun_su6_unload.ogg'
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_ONE_HAND_WIELDED|GUN_AMMO_COUNTER

/obj/item/gun/pistol/smart/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 28, "muzzle_y" = 20,"rail_x" = 13, "rail_y" = 22, "under_x" = 24, "under_y" = 17, "stock_x" = 24, "stock_y" = 17)

/obj/item/gun/pistol/smart/set_gun_config_values()
	..()
	fire_delay = 1 // FIRE_DELAY_TIER_12
	set_burst_amount(BURST_AMOUNT_TIER_3)
	set_burst_delay(FIRE_DELAY_TIER_11)
	accuracy_mult = BASE_ACCURACY_MULT
	accuracy_mult_unwielded = BASE_ACCURACY_MULT
	scatter = SCATTER_AMOUNT_TIER_6
	burst_scatter_mult = SCATTER_AMOUNT_TIER_6
	scatter_unwielded = SCATTER_AMOUNT_TIER_6
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil = RECOIL_AMOUNT_TIER_5
	recoil_unwielded = RECOIL_AMOUNT_TIER_4

/obj/item/gun/pistol/smart/set_bullet_traits()
	LAZYADD(traits_to_give, list(
		BULLET_TRAIT_ENTRY(/datum/element/bullet_trait_iff)
	))
*/

//-------------------------------------------------------
//mod88 based off VP70 - Counterpart to M1911, offers burst and capacity ine exchange of low accuracy and damage.

/obj/item/gun/ballistic/marine/pistol/mod88
	name = "\improper 88 Mod 4 combat pistol"
	desc = "Standard issue USCM firearm. Also found in the hands of Weyland-Yutani PMC teams. Fires 9mm armor shredding rounds and is capable of 3-round burst."
	icon = 'tff_modular/modules/colonial_marines/weapon/icons/WY/pistols.dmi'
	icon_state = "_88m4"
	fire_sound = 'tff_modular/modules/colonial_marines/weapon/sound/gun_88m4_v7.ogg'
	fire_sound_volume = 20 // O: firesound_volume
	load_sound = 'tff_modular/modules/colonial_marines/weapon/sound/gun_88m4_reload.ogg' // O: reload_sound
	eject_sound  = 'tff_modular/modules/colonial_marines/weapon/sound/gun_88m4_unload.ogg' // O: unload_sound
	accepted_magazine_type = /obj/item/ammo_box/magazine/marines/mod88 // current_mag
	force = 8

	lefthand_file = 'tff_modular/modules/colonial_marines/weapon/icons/pistols_lefthand.dmi'
	righthand_file = 'tff_modular/modules/colonial_marines/weapon/icons/pistols_righthand.dmi'
	inhand_icon_state = "_88m4" // O: item_state
	empty_alarm = FALSE

/obj/item/gun/ballistic/marine/pistol/mod88/set_gun_config_values()
	..()
	fire_delay = FIRE_DELAY_TIER_11
	// burst_size = BURST_AMOUNT_TIER_3
	burst_delay = FIRE_DELAY_TIER_11
	projectile_damage_multiplier = BASE_BULLET_DAMAGE_MULT + BULLET_DAMAGE_MULT_TIER_4 // O: damage_mult
