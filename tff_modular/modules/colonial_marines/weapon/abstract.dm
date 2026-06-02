/datum/marine_ammo
	var/name = "default bullet"
	var/icon = 'icons/obj/weapons/guns/projectiles.dmi'
	var/icon_state = "bullet"
	/// When it deals damage.
	var/sound_hit
	var/stamina_damage = 0
	/// This is the base damage of the bullet as it is fired
	var/damage = 10
	/// BRUTE, BURN, TOX, OXY, CLONE are the only things that should be in here
	var/damage_type = BRUTE
	/// How much armor it ignores before calculations take place
	var/penetration = 0
	/// The % chance it will imbed in a human
	var/shrapnel_chance = SHRAPNEL_CHANCE_TIER_1
	/// The shrapnel type the ammo will embed, if the chance rolls
	var/shrapnel_type = /obj/projectile/bullet
	/// Stun,knockdown,knockout,irradiate,stutter,eyeblur,drowsy,agony
	var/debilitate[] = null
	/// if we should play a special sound when firing.
	var/sound_override = null

	/// This is added to the bullet's base accuracy.
	// var/accuracy = HIT_ACCURACY_TIER_1
	/// For most guns, this is where the bullet dramatically looses accuracy. Not for snipers though.
	var/accurate_range = 6
	/// This will de-increment a counter on the bullet.
	var/max_range = 22
	/// How much damage the bullet loses per turf traveled after the effective range
	// var/damage_falloff = DAMAGE_FALLOFF_TIER_10
	/// How fast the projectile moves.
	var/shell_speed = AMMO_SPEED_TIER_4

	var/caliber = null


/obj/item/ammo_casing/marines
	name = "default bullet"
	icon_state = "bullet"
	projectile_type = /obj/projectile/bullet/marines
	var/datum/marine_ammo/ammo_datum = /datum/marine_ammo

/obj/item/ammo_casing/marines/Initialize(mapload)
	. = ..()

	// var/ammo_type = ammo_datum
	fire_sound = ammo_datum::sound_override
	caliber = ammo_datum::caliber

	loaded_projectile.name = ammo_datum::name
	loaded_projectile.icon = ammo_datum::icon
	loaded_projectile.icon_state = ammo_datum::icon_state
	loaded_projectile.hitsound = ammo_datum::sound_hit
	loaded_projectile.stamina = ammo_datum::stamina_damage
	loaded_projectile.damage = ammo_datum::damage
	loaded_projectile.damage_type = ammo_datum::damage_type
	loaded_projectile.armour_penetration = ammo_datum::penetration
	loaded_projectile.shrapnel_type = ammo_datum::shrapnel_type

	if(!isnull(ammo_datum::debilitate))
		for(var/i = 1, i < length(ammo_datum::debilitate), i += 1)
			switch(i)
				if(1)
					loaded_projectile.stun = ammo_datum::debilitate[i]
				if(2)
					loaded_projectile.knockdown = ammo_datum::debilitate[i]
				if(5)
					loaded_projectile.stutter = ammo_datum::debilitate[i]
				if(6)
					loaded_projectile.eyeblur = ammo_datum::debilitate[i]
				if(7)
					loaded_projectile.drowsy = ammo_datum::debilitate[i]

	loaded_projectile.range = ammo_datum::max_range
	// loaded_projectile.damage_falloff = ammo_datum::damage_falloff
	loaded_projectile.speed = ammo_datum::shell_speed

/obj/projectile/bullet/marines
	name = "Bug"
