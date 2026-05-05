

/obj/item/organ/heart
	var/heart_rate = 70
	var/blood_pressure = 100
	var/stroke_volume = 100


/obj/item/organ/heart/on_life(seconds_per_tick)
	. = ..()

	if(owner.needs_heart())
		handle_stroke_volume(seconds_per_tick)
		handle_heart_rate(seconds_per_tick)

		// debug
		var/message = "heart_rate: [heart_rate] | stroke_volume: [stroke_volume] | blood_pressure: [blood_pressure] ||| {blood_saturation: [owner.blood_saturation] ~ blood_volume: [owner.get_blood_volume()] ~ damage: [damage]}"
		message_admins(message)
		log_lua(message)
		// degub end

/obj/item/organ/heart/proc/handle_stroke_volume(seconds_per_tick)
	var/target_stroke_volume = 0

	var/blood_volume_factor = log(5, owner.get_blood_volume() / owner.default_blood_volume) + 1

	var/end_diastolic_volume = 150 * blood_volume_factor
	var/end_systolic_volume = 50 * blood_volume_factor

	target_stroke_volume = end_diastolic_volume - end_systolic_volume
	stroke_volume = MOVE_TOWARDS(stroke_volume, target_stroke_volume, seconds_per_tick * STROKE_VOLUME_CHANGE_SPEED)

/obj/item/organ/heart/proc/handle_heart_rate(seconds_per_tick)
	var/target_heart_rate = 0

	if(is_beating())
		var/target_cardiac_output = owner.needed_oxygen / owner.blood_saturation
		target_heart_rate = target_cardiac_output  / stroke_volume // &&&&

	target_heart_rate = clamp(target_heart_rate, 0, MAX_HEART_RATE)
	heart_rate = MOVE_TOWARDS(heart_rate, target_heart_rate, seconds_per_tick * HEART_RATE_CHANGE_SPEED)



