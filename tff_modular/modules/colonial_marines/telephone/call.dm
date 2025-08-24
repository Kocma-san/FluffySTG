
/obj/machinery/stationary_phone
	name = "telephone receiver"
	desc = "It is a wall mounted telephone. The fine text reads: To log your details with the mainframe please insert your keycard into the slot below. Unfortunately the slot is jammed. You can still use the phone, however."
	icon = 'tff_modular/modules/colonial_marines/telephone/icons/phone.dmi'
	icon_state = "wall_phone"


	/// Machines thigs
	use_power = NO_POWER_USE
	/// END

	var/enabled = TRUE
	/// Unique identificator for phone
	var/phone_number
	/// Любые текущие таймеры
	var/current_timer
	/// Текущее соединение
	var/datum/phone_connection/current_connection

/obj/machinery/stationary_phone/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch(action)
		if("make_call")
			// zvuki nabora nomera
			make_call(params["phone_id"])

/obj/machinery/stationary_phone/proc/make_call(target_number)
	var/obj/machinery/stationary_phone/target_phone
	for(var/obj/machinery/stationary_phone/phone in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/stationary_phone))
		if(phone.phone_number == target_number)
			target_phone = phone
			break

	if(isnull(target_phone))
		return 1

	var/datum/phone_connection/connection = new()
	connection.initialize_connection(src, target_phone)

/obj/machinery/stationary_phone/proc/get_status()
	if(!enabled)
		return PHONE_UNAVAILABLE
	if(current_connection)
		return PHONE_BUSY
	return PHONE_AVAILABLE




/datum/phone_connection
	var/list/obj/machinery/stationary_phone/connected_phones = list()
	// + history for that call

/datum/phone_connection/Destroy(force)
	for(var/phone in connected_phones)
		remove_connection(phone)
	return ..()

/datum/phone_connection/proc/add_connection(obj/machinery/stationary_phone/phone)
	phone.current_connection = src
	connected_phones += phone

/datum/phone_connection/proc/remove_connection(obj/machinery/stationary_phone/phone)
	phone.current_connection = null
	connected_phones -= phone

/datum/phone_connection/proc/initialize_connection(obj/machinery/stationary_phone/caller, obj/machinery/stationary_phone/target)
	add_connection(caller)
	var/target_status = target.get_status()
	switch(target_status)
		if(PHONE_BUSY)
		if(PHONE_AVAILABLE)
			add_connection(target)


