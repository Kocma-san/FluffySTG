
/datum/phone_history
	var/start_time
	var/end_time
	var/dialed_number
	var/calling_phone
	var/dialed_phone

	var/list/history = list()

/datum/phone_history/New(calling_phone, dialed_number)
	src.dialed_number = dialed_number
	src.calling_phone = WEAKREF(calling_phone) // ???
	src.start_time = server_timestamp()

	GLOB.phone_call_history += src

/datum/phone_history/proc/add_entry(list/message, source)
	var/list/history_entry = list()
	history_entry["time"] = server_timestamp()
	history_entry["message"] = message.Copy()
	history_entry["source"] = WEAKREF(source)

	src.history += list(history_entry)

/datum/phone_history/proc/end_call()
	src.end_time = server_timestamp()
