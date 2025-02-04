
/mob/living/carbon/human
	var/datum/pain/ff_pain

/mob/living/carbon/human/Initialize(mapload)
	. = ..()
	ff_pain = new /datum/pain(src)
