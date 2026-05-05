#define NORMAL_HUMAN_BLOOD_PRESSURE 120
#define NORMAL_HUMAN_HEART_BPM 70

#define HEART_BPM_CHANGE_SPEED 30
#define BLOOD_PRESSURE_CHANGE_SPEED 1
#define OXYGEN_SATURATION_CHANGE_SPEED 1

#define MOVE_TOWARDS(c, t, maxDelta) ( (c) + sign((t)-(c))*min((maxDelta), abs((t)-(c))) )


//  ## bloodViscosity


/obj/item/organ/heart
	/// Текущее количество ударов сердца в минуту
	VAR_PROTECTED/current_bpm = NORMAL_HUMAN_HEART_BPM
	var/normal_bpm = NORMAL_HUMAN_HEART_BPM


	/// Текущее кровяное давление
	VAR_PROTECTED/blood_pressure = NORMAL_HUMAN_BLOOD_PRESSURE
	var/normal_blood_pressure = NORMAL_HUMAN_BLOOD_PRESSURE

	/// Текущая сатурация (0 .. 100)
	VAR_PROTECTED/oxygen_saturation = 100
	var/saturation_heart_factor = 1
	var/saturation_lungs_factor = 1
	var/saturation_blood_factor = 1




/obj/item/organ/heart/Initialize(mapload)
	. = ..()
	Restart() // Нам нужно запуститься


/obj/item/organ/heart/Restart()
	. = ..()

/obj/item/organ/heart/Stop()
	. = ..()


/* // --
В данный момент у нас еcть всего несколько параметров, которые могут влиять на сердце и кровь:
- Текущий объем крови
- bleed_rate - можно использовать как "вязкость"
- Бьется ли сердце
- Работают ли легкие
- Парциальное давление кислорода в воздухе в последнем вдохе
- Состояние органов (легких и сердца)
- ? Вещеста в крови
*/ // --


/obj/item/organ/heart/on_life(seconds_per_tick)
	. = ..()

	if(ishuman(owner))
		handle_heart_bpm(seconds_per_tick)
		handle_blood_pressure(seconds_per_tick)
		handle_oxygen_saturation(seconds_per_tick)
		handle_oxygen_compensation(seconds_per_tick)

		// debug
		var/message = "bpm: [current_bpm] | blood_pressure: [blood_pressure] | oxygen_saturation: [oxygen_saturation] ||| {blood_volume: [owner.get_blood_volume()] ~ damage: [damage]}"
		message_admins(message)
		log_lua(message)
		// degub end


/obj/item/organ/heart/proc/handle_heart_bpm(seconds_per_tick)
	var/target_bpm = normal_bpm

	if(!is_beating())
		target_bpm = 0
	else
		target_bpm = normal_bpm

		var/heart_efficiency = CLAMP01(1 - (damage / maxHealth))
		target_bpm *= 0.5 + 0.5 * heart_efficiency

		var/pressure_factor = clamp(normal_blood_pressure / max(blood_pressure, 1), 0.5, 2)
		target_bpm *= pressure_factor

	target_bpm = max(target_bpm, 0)
	current_bpm = MOVE_TOWARDS(current_bpm, target_bpm, seconds_per_tick * HEART_BPM_CHANGE_SPEED)


/obj/item/organ/heart/proc/handle_blood_pressure(seconds_per_tick)
	var/target_pressure = normal_blood_pressure

	var/blood_factor = owner.get_blood_volume() / owner.blood_volume_normal
	target_pressure *= blood_factor

	var/heart_efficiency = CLAMP01(1 - (damage / maxHealth))
	target_pressure *= heart_efficiency

	if(!is_beating())
		target_pressure *= 0.1

	target_pressure = max(target_pressure, 0)
	blood_pressure = MOVE_TOWARDS(blood_pressure, target_pressure, seconds_per_tick * BLOOD_PRESSURE_CHANGE_SPEED)


/obj/item/organ/heart/proc/handle_oxygen_saturation(seconds_per_tick)
	var/target_saturation = 100

	var/obj/item/organ/lungs/lungs = owner.get_organ_by_slot(ORGAN_SLOT_LUNGS)
	if(!isnull(lungs))
		var/breath_o2_pp = lungs.last_partial_pressures[GAS_O2]
		if(breath_o2_pp < lungs.safe_oxygen_min)



/obj/item/organ/heart/proc/handle_oxygen_compensation(seconds_per_tick)
	var/oxygen_error = (100 - oxygen_saturation) / 100

	var/max_bpm_compensation = 0.2


