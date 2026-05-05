
/mob/living/carbon
	var/blood_saturation = 1
	var/needed_oxygen = 4000

/mob/living/carbon/human/handle_breathing(seconds_per_tick)
	. = ..()
	var/target_saturation = 0
	var/obj/item/organ/lungs/our_lungs = get_organ_slot(ORGAN_SLOT_LUNGS)
	if(istype(our_lungs))
		var/o2_pp_in_blood = our_lungs.last_partial_pressures[/datum/gas/oxygen] * 1000 * 760 / 101325	// mmHg
		// From here: https://www.nickalls.org/dick/papers/anes/JWSrevised2007.pdf
		target_saturation = (23400 / (o2_pp_in_blood ** 3 + 150 * o2_pp_in_blood) + 1) ** -1

	blood_saturation = MOVE_TOWARDS(blood_saturation, target_saturation, SATURATION_CHANGE_SPEED * seconds_per_tick)
