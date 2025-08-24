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
		end_call() // +maybe Redo
	if(is_handset_on_phone())
		qdel(attached_handset)
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
	if(held_item == attached_handset)
		context[SCREENTIP_CONTEXT_RMB] = "Return handset"

	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/stationary_phone/item_interaction_secondary(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(tool == attached_handset)
		playsound(src, get_sound_file("rtb_handset"), 100, FALSE, 7)
		stop_hangup_sound()
		stop_busy_sound()
		stop_connection_problem_sound()
		tool.forceMove(src)
		if(current_connection)
			end_call()
		update_icon(UPDATE_ICON_STATE)
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_FAILURE

/obj/machinery/stationary_phone/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(!can_interact(user))
		return SECONDARY_ATTACK_CALL_NORMAL
	if(is_handset_on_phone())
		playsound(src, get_sound_file("rtb_handset"), 100, FALSE, 7)
		// ## +start noise
		user.put_in_hands(attached_handset)
		SEND_SIGNAL(src, COMSIG_PHONE_ACCEPT_CALL)
		update_icon(UPDATE_ICON_STATE)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/stationary_phone/update_icon_state()
	. = ..()
	if(!is_handset_on_phone())
		icon_state = "[base_icon_state]-ear"
	else if(current_connection?.current_status == CONSTATUS_CALLING)
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

/obj/machinery/stationary_phone/proc/get_phone_by_id(id)
	for(var/obj/machinery/stationary_phone/phone in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/stationary_phone))
		if(phone.phone_id == id)
			return phone
	return null

/obj/machinery/stationary_phone/proc/get_current_status()
	if(!enabled)
		return PHONE_UNAVAILABLE
	if(current_connection)
		return PHONE_UNAVAILABLE
	if(!is_handset_on_phone())
		return PHONE_UNAVAILABLE
	return PHONE_AVAILABLE

/obj/machinery/stationary_phone/proc/try_start_call(entered_number)
	var/obj/machinery/stationary_phone/target_phone = get_phone_by_id(entered_number)

	if(isnull(target_phone))
		start_connection_problem_sound()
		return FALSE

	if(target_phone.get_current_status() != PHONE_AVAILABLE)
		start_busy_sound()
		return FALSE

	new /datum/phone_connection(src, target_phone)
	return TRUE

/obj/machinery/stationary_phone/proc/end_call()
	current_connection.end_connection()


/datum/phone_connection
	// /// Список всех подключенных телефонов (Обычно 2, но в теории можно и больше)
	// var/list/obj/machinery/stationary_phone/connected_phones = list()
	var/obj/machinery/stationary_phone/starting_phone
	var/obj/machinery/stationary_phone/target_phone
	/// Текущее состояние соединения
	var/current_status = CONSTATUS_NO_STATUS
	/// Сам таймер таймаута. Нулл, если сейчас не идет вызов
	var/timeout_timer_id
	/// Время за которое на том конце должны взять трубку, иначе звонок сбросится
	var/timeout_duration = 45 SECONDS
	// ### + add history for that call

/datum/phone_connection/New(obj/machinery/stationary_phone/starting_phone, obj/machinery/stationary_phone/target_phone)
	. = ..()
	if(!starting_phone || !target_phone)
		CRASH("wehwehwehweh")

	if(!isnull(starting_phone.current_connection) || !isnull(target_phone.current_connection))
		CRASH("One of the phones already has connection. Starting: [!!starting_phone.current_connection]; Target: [!!target_phone.current_connection]")

	src.starting_phone = starting_phone
	src.target_phone = target_phone
	starting_phone.current_connection = src
	target_phone.current_connection = src

	start_connection()

/datum/phone_connection/Destroy(force)
	end_connection()
	return ..()

/datum/phone_connection/proc/start_connection()
	current_status = CONSTATUS_CALLING

	timeout_timer_id = addtimer(CALLBACK(src, PROC_REF(connection_timeout)), timeout_duration, TIMER_UNIQUE|TIMER_STOPPABLE)
	RegisterSignal(target_phone, COMSIG_PHONE_ACCEPT_CALL, PROC_REF(complete_connection))
	starting_phone.start_dial_sound()
	target_phone.start_ring_sound()
	target_phone.update_icon(UPDATE_ICON_STATE)

/datum/phone_connection/proc/complete_connection()
	current_status = CONSTATUS_INITIALIZED

	UnregisterSignal(target_phone, COMSIG_PHONE_ACCEPT_CALL)
	deltimer(timeout_timer_id)
	timeout_timer_id = null

	starting_phone.stop_dial_sound()
	target_phone.stop_ring_sound()

	RegisterSignal(starting_phone, COMSIG_PHONE_SEND_DATA, PROC_REF(transmitt_data))
	RegisterSignal(target_phone, COMSIG_PHONE_SEND_DATA, PROC_REF(transmitt_data))

/datum/phone_connection/proc/connection_timeout()
	SIGNAL_HANDLER

	end_connection()

/datum/phone_connection/proc/end_connection()
	starting_phone.current_connection = null
	target_phone.current_connection = null

	switch(current_status)
		if(CONSTATUS_CALLING)
			starting_phone.stop_dial_sound()
			starting_phone.start_busy_sound()
			target_phone.stop_ring_sound()
			target_phone.update_icon(UPDATE_ICON_STATE)
			UnregisterSignal(target_phone, COMSIG_PHONE_ACCEPT_CALL)
		if(CONSTATUS_INITIALIZED)
			if(!starting_phone.is_handset_on_phone())
				starting_phone.start_hangup_sound()
			if(!target_phone.is_handset_on_phone())
				target_phone.start_hangup_sound()
			UnregisterSignal(starting_phone, COMSIG_PHONE_SEND_DATA)
			UnregisterSignal(target_phone, COMSIG_PHONE_SEND_DATA)
		else
			CRASH("Invalid status for ending a call. Current status: [current_status]")

	starting_phone = null
	target_phone = null

	current_status = CONSTATUS_ENDED

/datum/phone_connection/proc/transmitt_data(list/data, obj/machinery/stationary_phone/sender)
	SIGNAL_HANDLER

	var/obj/machinery/stationary_phone/getter = sender == target_phone ? starting_phone : target_phone

	var/message = sender.say_quote(data["raw_message"], data["message_mods"])
	var/rendered = span_big(span_purple("<b>\[Telephone\] [sender.phone_id]</b> [message]"))

	log_telecomms(rendered)

	getter.attached_handset.say_message(rendered, data["message_language"])
	send_to_observers(rendered, src)

/*
 * Отправка и получение звуков
 */

/obj/machinery/stationary_phone/proc/get_data(message)
	// attached_handset.say_message(message)

/obj/machinery/stationary_phone/proc/need_to_send_data(data)
	SIGNAL_HANDLER
	SEND_SIGNAL(src, COMSIG_PHONE_SEND_DATA, data, src)

/*
 * Трубка телефона
 */

/obj/item/phone_handset
	name = "telephone"
	icon = 'tff_modular/modules/colonial_marines/telephone/icons/phone.dmi'
	lefthand_file = 'tff_modular/modules/colonial_marines/telephone/icons/phone_inhand_lefthand.dmi'
	righthand_file = 'tff_modular/modules/colonial_marines/telephone/icons/phone_inhand_righthand.dmi'
	icon_state = "rpb_phone"
	inhand_icon_state = "rpb_phone"

	// Соединенный с трубкой телефон
	var/obj/machinery/stationary_phone/connected_phone
	/// На каком расстоянии будет слышно слова из трубки
	var/hear_range = 1

/obj/item/phone_handset/Destroy(force)
	connected_phone.disconnect_handset()
	return ..()

/obj/item/phone_handset/proc/say_message(message, language)
	var/list/hearers = get_hearers_in_LOS(hear_range, src)

	// ## +Звук

	for(var/atom/movable/hearer as anything in hearers)
		if(!hearer)
			stack_trace("null found in the hearers list returned by the spatial grid. this is bad")
			continue
		hearer.Hear(message, message_language = language, message_range = INFINITY)


/obj/machinery/stationary_phone/proc/is_handset_on_phone()
	if(isnull(attached_handset))
		return FALSE
	if(attached_handset.loc == src)
		return TRUE
	return FALSE

/obj/machinery/stationary_phone/proc/connect_handset(obj/item/phone_handset/handset)
	// if(attached_handset)
	// 	disconnect_handset()
	attached_handset = handset
	attached_handset.connected_phone = src
	RegisterSignal(attached_handset, COMSIG_MOVABLE_HEAR, PROC_REF(need_to_send_data))

/obj/machinery/stationary_phone/proc/disconnect_handset()
	UnregisterSignal(attached_handset, COMSIG_MOVABLE_HEAR)
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


#undef MAX_ENTERED_NUMBER_LENGTH
