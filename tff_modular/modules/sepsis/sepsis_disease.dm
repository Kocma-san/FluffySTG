#define SEPTIC_SHOCK_TIMEOUT (2 MINUTES)
#define BASIC_TIME_TO_START_CURE (30 SECONDS)

/datum/disease/sepsis
	visibility_flags = HIDDEN_SCANNER | HIDDEN_PANDEMIC
	disease_flags = CURABLE|CAN_CARRY
	spread_flags = DISEASE_SPREAD_NON_CONTAGIOUS

	name = "Bacteremia"
	desc = "A dangerous condition caused by infection that can lead to organ failure, coma and eventually death."
	spread_text = "Blood"	// It's a lie
	cure_text = "The Spaceacillin stops further progression of inflammation. Treatable with Sulfonal or prolonged intravenous infusion of Spaceacillin."

	max_stages = 5
	stage_prob = 10

	viable_mobtypes = list(/mob/living/carbon/human)
	cures = list(/datum/reagent/toxin/sulfonal)	// Cures without having to wait for time_before_cure
	cure_chance = 8
	bypasses_immunity = TRUE
	severity = DISEASE_SEVERITY_DANGEROUS

	var/agent_names = list("Streptococcus", "Staphylococcus", "Pseudomonas aeruginosa", "Salmonella")
	var/sepsis_start_time
	var/time_before_cure = BASIC_TIME_TO_START_CURE
	var/seconds_with_spaceacillin = 0

/datum/disease/sepsis/New()
	. = ..()
	agent = pick(agent_names)

/datum/disease/sepsis/update_stage(new_stage)
	. = ..()
	switch(new_stage)
		if(2)
			visibility_flags &= ~HIDDEN_SCANNER
			affected_mob.med_hud_set_status()
			stage_prob = 4
		if(3)
			name = "Sepsis"
			desc = "Sepsis is a potentially life-threatening condition that occurs when the body's response to an infection results in damage to its own tissues and organs."
			stage_prob = 0
			cure_chance = 4
			sepsis_start_time = world.time
			time_before_cure = BASIC_TIME_TO_START_CURE * 2
		if(4)
			stage_prob = 4
		if(5)
			name = "Septic shock"
			desc = "Septic shock is a potentially fatal condition resulting from sepsis, which is organ damage in response to infection, and results in dangerously low blood pressure and impaired cellular metabolism."
			cure_chance = 2
			time_before_cure = BASIC_TIME_TO_START_CURE * 4
	return .

/datum/disease/sepsis/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	var/mob/living/carbon/human/carrier = affected_mob

	if(has_antibiotics())
		seconds_with_spaceacillin += seconds_per_tick SECONDS
		if(seconds_with_spaceacillin >= time_before_cure)
			if(SPT_PROB((cure_chance / 2), seconds_per_tick))
				cure()
	else
		seconds_with_spaceacillin = max(seconds_with_spaceacillin - (seconds_per_tick * 2), 0)

	carrier.adjust_coretemperature(10, max_temp = BODYTEMP_HEAT_DAMAGE_LIMIT)
	carrier.adjust_bodytemperature(10, max_temp = BODYTEMP_HEAT_DAMAGE_LIMIT)

	switch(stage)
		if(1)
			if(SPT_PROB(10, seconds_per_tick))
				carrier.adjust_coretemperature(8, max_temp = BODYTEMP_HEAT_DAMAGE_LIMIT + 10)
				carrier.adjust_bodytemperature(8, max_temp = BODYTEMP_HEAT_DAMAGE_LIMIT + 10)
				to_chat(carrier, span_notice("You feel warmer."))
			if(SPT_PROB(1, seconds_per_tick))
				carrier.emote("twitch")
			if(SPT_PROB(5, seconds_per_tick))
				affected_mob.emote("cough")
		if(2)
			if(SPT_PROB(10, seconds_per_tick))
				carrier.adjust_coretemperature(8, max_temp = BODYTEMP_HEAT_DAMAGE_LIMIT + 10)
				carrier.adjust_bodytemperature(8, max_temp = BODYTEMP_HEAT_DAMAGE_LIMIT + 10)
				to_chat(carrier, span_notice("You feel much warmer."))
			if(SPT_PROB(1, seconds_per_tick))
				carrier.emote("twitch")
			if(SPT_PROB(5, seconds_per_tick))
				affected_mob.emote("cough")
		if(3)
			var/need_mob_update = FALSE
			if(world.time - sepsis_start_time > SEPTIC_SHOCK_TIMEOUT)
				update_stage(4)
			if(SPT_PROB(10, seconds_per_tick))
				to_chat(carrier, span_notice("You feel hotter and hotter."))
				carrier.adjust_coretemperature(8, max_temp = BODYTEMP_HEAT_DAMAGE_LIMIT + 30)
				carrier.adjust_bodytemperature(8, max_temp = BODYTEMP_HEAT_DAMAGE_LIMIT + 30)
			if(SPT_PROB(4, seconds_per_tick))
				to_chat(carrier, span_notice("Your eyes are blurring."))
				carrier.adjust_eye_blur(10 SECONDS)
			if(SPT_PROB(3, seconds_per_tick))
				to_chat(carrier, span_notice("You're struggling to breathe."))
				need_mob_update += carrier.adjustOxyLoss(3, updating_health = FALSE)
			if(SPT_PROB(3, seconds_per_tick))
				need_mob_update += carrier.adjustBruteLoss(3, updating_health = FALSE)
			if(SPT_PROB(3, seconds_per_tick))
				need_mob_update += carrier.adjustFireLoss(3, updating_health = FALSE)
			if(SPT_PROB(3, seconds_per_tick))
				need_mob_update += carrier.adjustToxLoss(3, updating_health = FALSE)
			if(SPT_PROB(4, seconds_per_tick))
				carrier.emote("twitch")
			if(SPT_PROB(1, seconds_per_tick))
				carrier.vomit()
			do_organ_damage(1, 3, 40)
			if(need_mob_update)
				carrier.updatehealth()
		if(4)
			var/need_mob_update = FALSE
			if(SPT_PROB(10, seconds_per_tick))
				to_chat(carrier, span_notice("You feel hotter and hotter."))
				carrier.adjust_coretemperature(8, max_temp = BODYTEMP_HEAT_DAMAGE_LIMIT + 30)
				carrier.adjust_bodytemperature(8, max_temp = BODYTEMP_HEAT_DAMAGE_LIMIT + 30)
			if(SPT_PROB(2, seconds_per_tick))
				to_chat(carrier, span_notice("Your eyes are blurring."))
				carrier.adjust_eye_blur(10 SECONDS)
			if(SPT_PROB(3, seconds_per_tick))
				to_chat(carrier, span_notice("You're struggling to breathe."))
				need_mob_update += carrier.adjustOxyLoss(3, updating_health = FALSE)
			if(SPT_PROB(3, seconds_per_tick))
				need_mob_update += carrier.adjustBruteLoss(3, updating_health = FALSE)
			if(SPT_PROB(3, seconds_per_tick))
				need_mob_update += carrier.adjustFireLoss(3, updating_health = FALSE)
			if(SPT_PROB(3, seconds_per_tick))
				need_mob_update += carrier.adjustToxLoss(3, updating_health = FALSE)
			if(SPT_PROB(4, seconds_per_tick))
				carrier.emote("twitch")
			if(SPT_PROB(1, seconds_per_tick))
				carrier.vomit()
			do_organ_damage(1, 3, 40)
			if(need_mob_update)
				carrier.updatehealth()
		if(5)
			var/need_mob_update = FALSE
			if(SPT_PROB(15, seconds_per_tick))
				to_chat(carrier, span_notice("You're so hot it feels like you are in hell!"))
				carrier.adjust_coretemperature(16, max_temp = BODYTEMP_HEAT_DAMAGE_LIMIT + 40)
				carrier.adjust_bodytemperature(16, max_temp = BODYTEMP_HEAT_DAMAGE_LIMIT + 40)
			if(SPT_PROB(2, seconds_per_tick))
				to_chat(carrier, span_notice("Your eyes are blurring."))
				carrier.adjust_eye_blur(10 SECONDS)
			if(SPT_PROB(5, seconds_per_tick))
				to_chat(carrier, span_notice("You're struggling to breathe."))
				need_mob_update += carrier.adjustOxyLoss(3, updating_health = FALSE)
			if(SPT_PROB(5, seconds_per_tick))
				need_mob_update += carrier.adjustBruteLoss(3, updating_health = FALSE)
			if(SPT_PROB(5, seconds_per_tick))
				need_mob_update += carrier.adjustFireLoss(3, updating_health = FALSE)
			if(SPT_PROB(5, seconds_per_tick))
				need_mob_update += carrier.adjustToxLoss(3, updating_health = FALSE)
			if(SPT_PROB(5, seconds_per_tick))
				carrier.emote("tremble")
			if(SPT_PROB(2, seconds_per_tick))
				carrier.vomit()
			if(SPT_PROB(5, seconds_per_tick))
				to_chat(carrier, span_notice("Your whole body hurts!"))
			do_organ_damage(1, 4, 70)
			if(need_mob_update)
				carrier.updatehealth()

/datum/disease/sepsis/proc/has_antibiotics()
	if(affected_mob.reagents.has_reagent(/datum/reagent/medicine/spaceacillin))
		return TRUE
	return FALSE

/datum/disease/sepsis/proc/do_organ_damage(min_damage, max_damage, chance = 100)
	var/list/obj/item/organ/organs = list()
	organs += affected_mob.get_organs_for_zone(BODY_ZONE_CHEST)
	organs += affected_mob.get_organs_for_zone(BODY_ZONE_HEAD)
	for(var/obj/item/organ/organ in organs)
		if(istype(organ, /obj/item/organ/brain))	// Brain traumas are annoying
			chance *= 0.8
		if(prob(chance))
			organ.apply_organ_damage(rand(min_damage, max_damage))

#undef SEPTIC_SHOCK_TIMEOUT
#undef BASIC_TIME_TO_START_CURE
