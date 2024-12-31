
#define FAX_APP_MAX_CONNECTIONS 3

/datum/computer_file/program/fax_manager
	filename = "faxmanager"
	filedesc = "Fax Manager"
	downloader_category = PROGRAM_CATEGORY_EQUIPMENT
	program_open_overlay = "generic"
	extended_desc = "Program for receiving notifications on your PDA when messages arrive on your fax"
	program_flags = PROGRAM_ON_NTNET_STORE | PROGRAM_REQUIRES_NTNET
	size = 2
	tgui_id = "NtosFaxManager"
	program_icon = FA_ICON_FAX
	can_run_on_flags = PROGRAM_PDA

	// list of weakrefs of faxes connected to this app
	var/list/connected_faxes = list()

	var/max_connections = FAX_APP_MAX_CONNECTIONS

	var/notification = TRUE

/datum/computer_file/program/fax_manager/on_install()
	. = ..()
	// This is for auto-connecting to faxes for roles that have "personal" faxes
	var/area/assigned_fax_area
	if(istype(computer, /obj/item/modular_computer/pda/heads))
		if(istype(computer, /obj/item/modular_computer/pda/heads/captain))
			assigned_fax_area = /area/station/command/heads_quarters/captain
		else if(istype(computer, /obj/item/modular_computer/pda/heads/ce))
			assigned_fax_area = /area/station/command/heads_quarters/ce
		else if(istype(computer, /obj/item/modular_computer/pda/heads/cmo))
			assigned_fax_area = /area/station/command/heads_quarters/cmo
		else if(istype(computer, /obj/item/modular_computer/pda/heads/hop))
			assigned_fax_area = /area/station/command/heads_quarters/hop
		else if(istype(computer, /obj/item/modular_computer/pda/heads/hos))
			assigned_fax_area = /area/station/command/heads_quarters/hos
		else if(istype(computer, /obj/item/modular_computer/pda/heads/rd))
			assigned_fax_area = /area/station/command/heads_quarters/rd
		else if(istype(computer, /obj/item/modular_computer/pda/heads/quartermaster))
			assigned_fax_area = /area/station/command/heads_quarters/qm
	else if(istype(computer, /obj/item/modular_computer/pda/detective))
		assigned_fax_area = /area/station/security/detectives_office
	else if(istype(computer, /obj/item/modular_computer/pda/lawyer))
		assigned_fax_area = /area/station/service/lawoffice

	if(assigned_fax_area)
		for(var/obj/machinery/fax/fax as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/fax))
			if(istype(get_area(fax), assigned_fax_area))
				establish_connection(fax)

	return TRUE

/datum/computer_file/program/fax_manager/Destroy()
	for(var/datum/weakref/fax_ref in connected_faxes)
		UnregisterSignal(fax_ref.resolve(), COMSIG_FAX_MESSAGE_RECEIVED)
	return ..()

/datum/computer_file/program/fax_manager/proc/establish_connection(datum/target, mob/user)
	if(!istype(target, /obj/machinery/fax))
		return FALSE

	var/datum/weakref/fax_ref = WEAKREF(target)

	if(fax_ref in connected_faxes)
		to_chat(user, span_notice("PDA is already connected to this fax"))
		return FALSE

	if(length(connected_faxes) >= max_connections)
		to_chat(user, span_warning("Too many PDAs are linked to this fax!"))
		return FALSE

	establish_connection(target, user)
	to_chat(user, span_notice("PDA succesfully linked to this fax"))
	return TRUE

/datum/computer_file/program/fax_manager/proc/establish_connection(datum/target)
	connected_faxes += WEAKREF(target)
	RegisterSignal(target, COMSIG_FAX_MESSAGE_RECEIVED, PROC_REF(send_notification))

/*
/datum/computer_file/program/fax_manager/on_start(mob/user)
	. = ..()

/datum/computer_file/program/fax_manager/kill_program(mob/user)
	return ..()
*/

/datum/computer_file/program/fax_manager/ui_data(mob/user)
	var/list/data = list()

	data["faxes"] = list()
	for(var/datum/weakref/fax_ref in connected_faxes)
		var/obj/machinery/fax/fax = fax_ref.resolve()

		var/list/fax_data = list()
		fax_data["fax_id"] = fax.fax_id
		fax_data["fax_name"] = fax.fax_name

		data["faxes"] += list(fax_data)

	data["max_connections"] = max_connections
	data["notification"] = notification
	return data

/datum/computer_file/program/fax_manager/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	switch(action)
		if("disconnect")
			for(var/datum/weakref/fax_ref in connected_faxes)
				var/obj/machinery/fax/fax = fax_ref.resolve()
				if(fax.fax_id == params["id"])
					connected_faxes -= fax_ref
					UnregisterSignal(fax, COMSIG_FAX_MESSAGE_RECEIVED)
			return TRUE

		if("disable_notification")
			notification = !notification
			return TRUE

		if("scan_for_faxes")
			for (var/elem in view(1, usr))
				if (istype(elem, /obj/machinery/fax))
					establish_connection(elem, usr)
			return TRUE

/datum/computer_file/program/fax_manager/proc/send_notification(obj/machinery/fax/fax, obj/item/loaded, sender_name)
	SIGNAL_HANDLER

	if(!istype(fax))
		return FALSE

	if(!notification)
		return FALSE

	if(!length(GLOB.announcement_systems))
		return FALSE

	var/obj/machinery/announcement_system/announcement_system = pick(GLOB.announcement_systems)

	var/list/targets
	for(var/datum/computer_file/program/messenger/messenger_app in computer.stored_files)
		targets = list(messenger_app)
		break

	if(!length(targets))
		return FALSE

	var/datum/signal/subspace/messaging/tablet_message/signal = new(announcement_system, list(
		"fakename" = fax.fax_name,
		"fakejob" = "Fax",
		"message" = "New message received from [sender_name]!",
		"targets" = targets,
		"automated" = TRUE,
	))

	INVOKE_ASYNC(signal, TYPE_PROC_REF(/datum/signal/subspace/messaging/tablet_message, send_to_receivers))
	return TRUE

#undef FAX_APP_MAX_CONNECTIONS
