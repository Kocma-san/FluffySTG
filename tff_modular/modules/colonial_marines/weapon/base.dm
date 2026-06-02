/obj/item/gun/ballistic/marine
	name = "BUG"
	rack_delay = 30
	fire_sound = 'tff_modular/modules/colonial_marines/weapon/sound/Gunshot.ogg'
	eject_sound = 'tff_modular/modules/colonial_marines/weapon/sound/flipblade.ogg'
	// dry_fire_sound = 'tff_modular/modules/colonial_marines/weapon/sound/smg_empty_alarm.ogg'

/obj/item/gun/ballistic/marine/Initialize(mapload)
	. = ..()
	set_gun_config_values()

/obj/item/gun/ballistic/marine/proc/set_gun_config_values()
	fire_delay = FIRE_DELAY_TIER_5
	burst_size = BURST_AMOUNT_TIER_1
	projectile_damage_multiplier = BASE_BULLET_DAMAGE_MULT
	recoil = RECOIL_OFF


/obj/item/gun/ballistic/marine/pistol
	rack_sound = 'tff_modular/modules/colonial_marines/weapon/sound/gun_pistol_cocked.ogg'
	bolt_type = BOLT_TYPE_LOCKING
