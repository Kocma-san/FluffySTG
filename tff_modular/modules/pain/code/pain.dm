#define HUMAN_MAX_PAIN 200

#define BRUTE_PAIN_MULTIPLIER 1
#define BURN_PAIN_MULTIPLIER 1.2
#define TOX_PAIN_MULTIPLIER 1.5
#define OXY_PAIN_MULTIPLIER 0

/datum/pain
	var/mob/living/carbon/source_mob

	var/max_pain = HUMAN_MAX_PAIN
	var/current_pain = 0
	var/reduction_pain = 0

	var/pain_level = PAIN_LEVEL_NONE
	var/list/pain_effects

	var/feels_pain = TRUE

	var/brute_pain_multiplier = BRUTE_PAIN_MULTIPLIER
	var/burn_pain_multiplier = BURN_PAIN_MULTIPLIER
	var/tox_pain_multiplier = TOX_PAIN_MULTIPLIER
	var/oxy_pain_multiplier = OXY_PAIN_MULTIPLIER

	var/threshold_mild = 20
	var/threshold_discomforting = 30
	var/threshold_moderate = 40
	var/threshold_distressing = 60
	var/threshold_severe = 70
	var/threshold_horrible = 80

/datum/pain/New(mob/living/carbon/owner)
	. = ..()
	if(istype(owner))
		source_mob = owner
	else
		qdel(src)

/datum/pain/Destroy()
	. = ..()
	source_mob = null

/datum/pain/proc/get_pain_percentage()
	var/percentage = clamp(floor((current_pain - reduction_pain) / max_pain * 100), 0, 100)

	return percentage

/datum/pain/proc/remove_pain_effects()
	if(pain_effects)
		for(var/effect in pain_effects)
			qdel(effect)

		LAZYNULL(pain_effects)

/datum/pain/proc/apply_pain(amount = 0, type = BRUTE)
	switch(type)
		if(BRUTE)
			amount *= brute_pain_multiplier
		if(BURN)
			amount *= burn_pain_multiplier
		if(TOX)
			amount *= tox_pain_multiplier
		if(OXY)
			amount *= oxy_pain_multiplier

	if(amount == 0)
		return

	current_pain = max(current_pain + amount, 0)

	update_pain_level()

/datum/pain/proc/apply_pain_reduction(amount = 0)
	reduction_pain = amount

	update_pain_level()

/datum/pain/proc/recalculate_pain(amount = 0, type = BRUTE)
	current_pain = 0

	apply_pain(source_mob.getBruteLoss(), BRUTE)
	apply_pain(source_mob.getFireLoss(), BURN)
	apply_pain(source_mob.getToxLoss(), TOX)
	apply_pain(source_mob.getOxyLoss(), OXY)

	update_pain_level()

	return TRUE

/datum/pain/proc/update_pain_level()
	var/new_level = PAIN_LEVEL_NONE

	var/pain_percentage = get_pain_percentage()
	if(pain_percentage >= threshold_horrible && !isnull(threshold_horrible))
		new_level = PAIN_LEVEL_HORRIBLE
	else if(pain_percentage >= threshold_severe && !isnull(threshold_severe))
		new_level = PAIN_LEVEL_SEVERE
	else if (pain_percentage >= threshold_distressing && !isnull(threshold_distressing))
		new_level = PAIN_LEVEL_DISTRESSING
	else if (pain_percentage >= threshold_moderate && !isnull(threshold_moderate))
		new_level = PAIN_LEVEL_MODERATE
	else if (pain_percentage >= threshold_discomforting && !isnull(threshold_discomforting))
		new_level = PAIN_LEVEL_DISCOMFORTING
	else if (pain_percentage >= threshold_mild && !isnull(threshold_mild))
		new_level = PAIN_LEVEL_MILD

	if(pain_level == new_level)
		return

	handle_pain_level(new_level)

/datum/pain/proc/handle_pain_level(new_level)
	if(!new_level)
		return FALSE

	remove_pain_effects()

	if(new_level >= PAIN_LEVEL_MILD)
		activate_mild()
	if(new_level >= PAIN_LEVEL_DISCOMFORTING)
		activate_discomforting()
	if(new_level >= PAIN_LEVEL_MODERATE)
		activate_moderate()
	if(new_level >= PAIN_LEVEL_DISTRESSING)
		activate_distressing()
	if(new_level >= PAIN_LEVEL_SEVERE)
		activate_severe()
	if(new_level >= PAIN_LEVEL_HORRIBLE)
		activate_horrible()

	pain_level = new_level

// Pain effects activation procs
/datum/pain/proc/activate_mild()
/datum/pain/proc/activate_discomforting()
/datum/pain/proc/activate_moderate()
/datum/pain/proc/activate_distressing()
/datum/pain/proc/activate_severe()
/datum/pain/proc/activate_horrible()


#undef HUMAN_MAX_PAIN
#undef BRUTE_PAIN_MULTIPLIER
#undef BURN_PAIN_MULTIPLIER
#undef TOX_PAIN_MULTIPLIER
