#define PASSIVE_INTERNAL_BLEEDING_HEALING -0.005
#define INTERNAL_BLEEDING_MAX_BLOODFLOW 4


/datum/wound_pregen_data/internal_bleeding
	abstract = TRUE
	ignore_cannot_bleed = FALSE
	viable_zones = list(BODY_ZONE_CHEST)
	required_limb_biostate = BIO_BLOODED

	weight = 30
	wound_series = WOUND_SERIES_INTERNAL_BLEEDING


/datum/wound/internal_bleeding
	name = "Internal Bleeding"
	can_scar = FALSE
	processes = TRUE

	var/initial_flow
	var/clot_rate = -0.001

	var/datum/wound/internal_bleeding/demotes_to
	var/datum/wound/internal_bleeding/promotes_to

	var/lowering_threshold
	var/higering_threshold

/datum/wound/internal_bleeding/wound_injury(datum/wound/old_wound, attack_direction)
	set_blood_flow(initial_flow)
	return ..()

/datum/wound/internal_bleeding/handle_process(seconds_per_tick)
	if(!victim || HAS_TRAIT(victim, TRAIT_STASIS))
		return
	if(limb.can_bleed())
		adjust_blood_flow(clot_rate * seconds_per_tick)

/datum/wound/internal_bleeding/adjust_blood_flow(adjust_by, minimum)
	. = ..()
	if(blood_flow > INTERNAL_BLEEDING_MAX_BLOODFLOW)
		blood_flow = INTERNAL_BLEEDING_MAX_BLOODFLOW

	if(blood_flow <= 0 && !QDELETED(src))
		qdel(src)

	if(blood_flow <= lowering_threshold && demotes_to)
		replace_wound(new demotes_to)
	else if(blood_flow > higering_threshold && promotes_to)
		replace_wound(new promotes_to)

/datum/wound/internal_bleeding/apply_wound(obj/item/bodypart/limb, silent, datum/wound/old_wound, smited, attack_direction, wound_source, replacing)
	if(replacing && istype(old_wound, /datum/wound/internal_bleeding))
		var/datum/wound/internal_bleeding/old = old_wound
		initial_flow = old.initial_flow
		clot_rate = old.clot_rate
	return ..()

/datum/wound/internal_bleeding/on_xadone(power)
	. = ..()
	adjust_blood_flow(-0.01 * power)




/datum/wound/internal_bleeding/moderate
	severity = WOUND_SEVERITY_MODERATE

	initial_flow = 1

	promotes_to = /datum/wound/internal_bleeding/severe
	higering_threshold = 1.5

/datum/wound_pregen_data/internal_bleeding/moderate
	wound_path_to_generate = /datum/wound/internal_bleeding/moderate
	abstract = FALSE

/datum/wound/internal_bleeding/severe
	severity = WOUND_SEVERITY_SEVERE

	initial_flow = 2

	demotes_to = /datum/wound/internal_bleeding/moderate
	promotes_to = /datum/wound/internal_bleeding/critical
	lowering_threshold = 1.5
	higering_threshold = 2.5

/datum/wound_pregen_data/internal_bleeding/severe
	wound_path_to_generate = /datum/wound/internal_bleeding/severe
	abstract = FALSE

/datum/wound/internal_bleeding/critical
	severity = WOUND_SEVERITY_CRITICAL

	initial_flow = 3

	demotes_to = /datum/wound/internal_bleeding/moderate
	lowering_threshold = 2.5

/datum/wound_pregen_data/internal_bleeding/critical
	wound_path_to_generate = /datum/wound/internal_bleeding/critical
	abstract = FALSE

