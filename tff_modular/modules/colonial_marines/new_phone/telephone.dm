#define MAX_ENTERED_NUMBER_LENGTH 8

/obj/machinery/stationary_phone
	name = "telephone receiver"
	desc = "The finger plate is a little stiff."
	icon = 'tff_modular/modules/colonial_marines/new_phone/icons/phone.dmi'
	icon_state = "rotary_phone"
	base_icon_state = "rotary_phone"
	density = FALSE
	anchored_tabletop_offset = 6
	max_integrity = 100
	pass_flags = PASSTABLE

	// Temporary things
	use_power = NO_POWER_USE
	// End

	/// Unique identificator for phone
	var/phone_id
	/// generated identificator lenght (Используется только если ID телефона не установлен)
	var/phone_id_length = 6
	/// The current input of the numpad on the telephone
	var/numeric_input = ""

	var/enabled = TRUE

	/// Текущее соединение
	var/datum/phone_connection/current_connection
	/// Присоединенная трубка телефона
	var/obj/item/phone_handset/attached_handset
	/// Цикличные звуки
	var/datum/looping_sound/telephone/connection_problem/connection_problem_loop_sound
	var/datum/looping_sound/telephone/hangup/hangup_loop_sound
	var/datum/looping_sound/telephone/busy/busy_loop_sound
	var/datum/looping_sound/telephone/dial/dial_loop_sound
	var/datum/looping_sound/telephone/ring/ring_loop_sound

/obj/machinery/stationary_phone/Initialize(mapload)
	. = ..()
	if(!phone_id)
		phone_id = generate_unique_id(len = phone_id_length)

	var/obj/item/phone_handset/handset = new(src)
	connect_handset(handset)

	connection_problem_loop_sound = new(null)
	hangup_loop_sound = new(null)
	busy_loop_sound = new(null)
	dial_loop_sound = new(null, _skip_starting_sounds = TRUE)
	ring_loop_sound = new(null)

	register_context()

/obj/machinery/stationary_phone/Destroy(force)
	if(current_connection)
		current_connection.hangup()
	if(is_handset_on_phone())
		qdel(attached_handset)
	else
		disconnect_handset()
	qdel(connection_problem_loop_sound)
	qdel(hangup_loop_sound)
	qdel(busy_loop_sound)
	qdel(dial_loop_sound)
	qdel(ring_loop_sound)
	return ..()

/obj/machinery/stationary_phone/examine(mob/user)
	. = ..()
	. += "You can see small paper with a number on it: [phone_id]"

/obj/machinery/stationary_phone/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	context[SCREENTIP_CONTEXT_LMB] = "Open interface"

	if(is_handset_on_phone())
		context[SCREENTIP_CONTEXT_RMB] = "Pick up handset"
	else if(held_item == attached_handset)
		context[SCREENTIP_CONTEXT_RMB] = "Return handset"

	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/stationary_phone/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(tool == attached_handset)
		interact(user)
		return ITEM_INTERACT_BLOCKING
	return ..()

/obj/machinery/stationary_phone/item_interaction_secondary(mob/living/user, obj/item/tool, list/modifiers)
	if(tool == attached_handset)
		playsound(src, get_sound_file("rtb_handset"), 50, FALSE)
		stop_all_sounds()
		tool.forceMove(src)
		if(current_connection)
			current_connection.hangup()
		update_icon(UPDATE_ICON_STATE)
		return ITEM_INTERACT_SUCCESS
	return ..()

/obj/machinery/stationary_phone/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(!can_interact(user))
		return SECONDARY_ATTACK_CALL_NORMAL
	if(is_handset_on_phone())
		playsound(src, get_sound_file("rtb_handset"), 100, FALSE, 7)
		// ## +start noise
		user.put_in_hands(attached_handset)
		if(current_connection)
			current_connection.complete_connection()
		update_icon(UPDATE_ICON_STATE)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/stationary_phone/update_icon_state()
	. = ..()
	if(!is_handset_on_phone())
		icon_state = "[base_icon_state]-ear"
	else if(current_connection && current_connection.dialed_phone == src)
		icon_state = "[base_icon_state]-ring"
	else
		icon_state = "[base_icon_state]"

/*
 * UI
 */

/obj/machinery/stationary_phone/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Telephone")
		ui.open()

/obj/machinery/stationary_phone/ui_data(mob/user)
	var/list/data = list()
	data["numeric_input"] = numeric_input
	return data

/obj/machinery/stationary_phone/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("keypad")
			playsound(src, SFX_TERMINAL_TYPE, 30, FALSE)
			if(current_connection)
				return TRUE
			var/digit = params["digit"]
			switch(digit)
				if("C")
					numeric_input = copytext(numeric_input, 1, -1)
					return TRUE
				if("phone")
					if(!is_handset_on_phone())
						try_start_call(numeric_input)
						numeric_input = ""
					return TRUE
				if("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
					if(length(numeric_input) < MAX_ENTERED_NUMBER_LENGTH)
						numeric_input += digit
					else
						playsound(src, 'sound/machines/nuke/general_beep.ogg', 50, FALSE)
					return TRUE

/*
 * Работа звонка
 */

/obj/machinery/stationary_phone/proc/get_current_status()
	if(!enabled)
		return PHONE_UNAVAILABLE
	if(current_connection)
		return PHONE_UNAVAILABLE
	if(!is_handset_on_phone())
		return PHONE_UNAVAILABLE
	return PHONE_AVAILABLE

/obj/machinery/stationary_phone/proc/try_start_call(entered_number)
	if(current_connection)
		CRASH("Телефон с активным соединением пытается позвонить!")

	new /datum/phone_connection(src, entered_number)


/datum/phone_connection
	var/obj/machinery/stationary_phone/calling_phone
	var/obj/machinery/stationary_phone/connected_phone
	var/obj/machinery/stationary_phone/dialed_phone
	/// Текущее состояние соединения
	VAR_PRIVATE/current_status = CONSTATUS_NO_STATUS
	/// Сам таймер таймаута. Нулл, если сейчас не идет вызов
	var/timeout_timer_id
	/// Время за которое на том конце должны взять трубку, иначе звонок сбросится
	var/timeout_duration = 45 SECONDS
	// ### + add history for that call

/datum/phone_connection/New(obj/machinery/stationary_phone/calling, dialed_number)
	if(isnull(calling))
		stack_trace("No calling phone when creating phone connection!")
		qdel(src)
		return
	if(isnull(dialed_number))
		stack_trace("No number entered when starting phone connection!")
		qdel(src)
		return
	if(!isnull(calling.current_connection))
		stack_trace("Calling phone already has connection!")
		qdel(src)
		return

	calling_phone = calling
	calling_phone.current_connection = src

	dialed_phone = get_phone_by_id(dialed_number)
	if(dialed_phone == calling)
		qdel(src)
		return
	if(isnull(dialed_phone))
		calling_phone.start_connection_problem_sound()
		qdel(src)
		return
	if(dialed_phone.get_current_status() != PHONE_AVAILABLE)
		calling_phone.start_busy_sound()
		qdel(src)
		return

	current_status = CONSTATUS_CALLING
	dialed_phone.current_connection = src

	calling_phone.start_dial_sound()
	dialed_phone.start_ring_sound()
	dialed_phone.update_icon(UPDATE_ICON_STATE)

	timeout_timer_id = addtimer(CALLBACK(src, PROC_REF(connection_timeout)), timeout_duration, TIMER_UNIQUE|TIMER_STOPPABLE)

/datum/phone_connection/Destroy(force)
    dialed_phone?.current_connection = null
    calling_phone?.current_connection = null
    connected_phone?.current_connection = null
    end_connection()
    dialed_phone = null
    calling_phone = null
    connected_phone = null
    return ..()

/datum/phone_connection/proc/connection_timeout()
	current_status = CONSTATUS_TIMEOUT
	qdel(src)

/datum/phone_connection/proc/hangup()
	qdel(src)

/datum/phone_connection/proc/complete_connection()
	current_status = CONSTATUS_INITIALIZED

	deltimer(timeout_timer_id)
	timeout_timer_id = null

	dialed_phone.stop_ring_sound()
	calling_phone.stop_dial_sound()

	connected_phone = dialed_phone
	dialed_phone = null

	RegisterSignal(calling_phone.attached_handset, COMSIG_MOVABLE_HEAR, PROC_REF(transmitt_data))
	RegisterSignal(connected_phone.attached_handset, COMSIG_MOVABLE_HEAR, PROC_REF(transmitt_data))

/datum/phone_connection/proc/end_connection()
	switch(current_status)
		if(CONSTATUS_NO_STATUS)	// Ничего не делаем
		if(CONSTATUS_CALLING)
			calling_phone.stop_dial_sound()
			dialed_phone.stop_ring_sound()
			dialed_phone.update_icon(UPDATE_ICON_STATE)
			if(connected_phone)
				stack_trace("Phone connection has connected phone when should not. Current status: [current_status]")
		if(CONSTATUS_TIMEOUT)
			calling_phone.stop_dial_sound()
			calling_phone.start_busy_sound()
			dialed_phone.stop_ring_sound()
			dialed_phone.update_icon(UPDATE_ICON_STATE)
			if(connected_phone)
				stack_trace("Phone connection has connected phone when should not. Current status: [current_status]")
		if(CONSTATUS_INITIALIZED)
			if(!calling_phone.is_handset_on_phone())
				calling_phone.start_hangup_sound()
			if(!connected_phone.is_handset_on_phone())
				connected_phone.start_hangup_sound()
			if(dialed_phone)
				stack_trace("Phone connection has dialled phone when should not. Current status: [current_status]")
			UnregisterSignal(calling_phone.attached_handset, COMSIG_MOVABLE_HEAR)
			UnregisterSignal(connected_phone.attached_handset, COMSIG_MOVABLE_HEAR)
		else
			CRASH("Invalid status for ending a call. Current status: [current_status]")

	current_status = CONSTATUS_ENDED

/datum/phone_connection/proc/transmitt_data(datum/source, list/hearing_args)
	SIGNAL_HANDLER

	var/obj/item/phone_handset/getter = connected_phone.attached_handset
	if(getter == source)
		getter = calling_phone.attached_handset

	getter.play_message(
		hearing_args[HEARING_SPEAKER],
		hearing_args[HEARING_LANGUAGE],
		hearing_args[HEARING_RAW_MESSAGE],
		hearing_args[HEARING_SPANS],
		hearing_args[HEARING_MESSAGE_MODE],
	)

/*
 * Трубка телефона
 */

/obj/item/phone_handset
	name = "telephone"
	icon = 'tff_modular/modules/colonial_marines/new_phone/icons/phone.dmi'
	lefthand_file = 'tff_modular/modules/colonial_marines/new_phone/icons/phone_inhand_lefthand.dmi'
	righthand_file = 'tff_modular/modules/colonial_marines/new_phone/icons/phone_inhand_righthand.dmi'
	icon_state = "rpb_phone"
	inhand_icon_state = "rpb_phone"

	// Соединенный с трубкой телефон
	var/obj/machinery/stationary_phone/connected_phone
	/// На каком расстоянии будет слышно слова из трубки
	var/speech_range = 2
	/// На каком расстоянии трубка сылшит звуки
	var/hear_range = 1
	/// Может ли слышать звуки из других телефонных трубок
	var/can_hear_other_phones = FALSE

/obj/item/phone_handset/Initialize(mapload)
	. = ..()
	become_hearing_sensitive()

/obj/item/phone_handset/Destroy(force)
	connected_phone.disconnect_handset()
	return ..()

/obj/item/phone_handset/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods, message_range)
	if(get_dist(src, speaker) > hear_range)
		return FALSE
	if(!can_hear_other_phones && istype(speaker, /obj/item/phone_handset))
		return FALSE
	if(message_mods[MODE_CUSTOM_SAY_ERASE_INPUT]) // Чисто эмоция, нет слов -> не передаем
		return FALSE
	return ..()

/obj/item/phone_handset/proc/play_message(atom/movable/speaker, message_language, raw_message, list/spans, list/message_mods)
	playsound(src, get_sound_file("talk_phone"), 50, TRUE, SILENCED_SOUND_EXTRARANGE)

	var/list/hearers = get_hearers_in_LOS(speech_range, src)

	for(var/mob/dead/observer/ghost in GLOB.player_list)
		if(get_chat_toggles(ghost.client) & CHAT_GHOSTRADIO)
			hearers |= ghost

	for(var/atom/movable/hearer as anything in hearers)
		if(!hearer)
			stack_trace("null found in the hearers list returned by the spatial grid. This is bad")
			continue
		if(hearer == src)
			continue
		hearer.Hear(null, src, message_language, raw_message, null, spans, message_mods, speech_range)


/obj/machinery/stationary_phone/proc/is_handset_on_phone()
	if(isnull(attached_handset))
		return FALSE
	if(attached_handset.loc == src)
		return TRUE
	return FALSE

/obj/machinery/stationary_phone/proc/connect_handset(obj/item/phone_handset/handset)
	if(attached_handset)
		stack_trace("Phone handset are connecting to a phone with existed handset!")
	attached_handset = handset
	attached_handset.connected_phone = src

/obj/machinery/stationary_phone/proc/disconnect_handset()
	attached_handset.connected_phone = null
	attached_handset = null





/*
 * Sounds
 */

/obj/machinery/stationary_phone/proc/start_connection_problem_sound()
	if(attached_handset)
		connection_problem_loop_sound.start(attached_handset)
	else
		connection_problem_loop_sound.start(src)

/obj/machinery/stationary_phone/proc/start_hangup_sound()
	if(attached_handset)
		hangup_loop_sound.start(attached_handset)
	else
		hangup_loop_sound.start(src)

/obj/machinery/stationary_phone/proc/start_busy_sound()
	if(attached_handset)
		busy_loop_sound.start(attached_handset)
	else
		busy_loop_sound.start(src)

/obj/machinery/stationary_phone/proc/start_dial_sound()
	if(attached_handset)
		dial_loop_sound.start(attached_handset)
	else
		dial_loop_sound.start(src)

/obj/machinery/stationary_phone/proc/start_ring_sound()
	ring_loop_sound.start(src)


/obj/machinery/stationary_phone/proc/stop_connection_problem_sound()
	connection_problem_loop_sound.stop(TRUE)

/obj/machinery/stationary_phone/proc/stop_hangup_sound()
	hangup_loop_sound.stop(TRUE)

/obj/machinery/stationary_phone/proc/stop_busy_sound()
	busy_loop_sound.stop(TRUE)

/obj/machinery/stationary_phone/proc/stop_dial_sound()
	dial_loop_sound.stop(TRUE)

/obj/machinery/stationary_phone/proc/stop_ring_sound()
	ring_loop_sound.stop(TRUE)

/obj/machinery/stationary_phone/proc/stop_all_sounds()
	stop_connection_problem_sound()
	stop_hangup_sound()
	stop_busy_sound()
	stop_dial_sound()
	stop_ring_sound()


#undef MAX_ENTERED_NUMBER_LENGTH
