/datum/component/phone_cable
	/// One side of the tether
	var/atom/tether_parent
	/// Other side of the tether
	var/atom/tether_target
	/// Maximum distance that this tether can be adjusted to
	var/max_dist
	/// What the tether is going to be called
	var/tether_name
	/// Beam effect
	var/datum/beam/tether_beam

	var/icon_name
	var/icon_file
	var/can_be_blocked

/datum/component/phone_cable/Initialize(atom/tether_target, max_dist, tether_name, icon="line", icon_file='icons/obj/clothing/modsuit/mod_modules.dmi', can_be_blocked = FALSE)
	if(!ismovable(parent) || !istype(tether_target) || !tether_target.loc)
		return COMPONENT_INCOMPATIBLE

	src.tether_parent = parent
	src.tether_target = tether_target
	src.max_dist = max_dist
	src.icon_name = icon
	src.icon_file = icon_file
	src.tether_name = tether_name
	src.can_be_blocked = can_be_blocked

	create_beam()

/datum/component/phone_cable/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_parent_pre_move))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_parent_moved))
	RegisterSignal(tether_target, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_target_pre_move))
	RegisterSignal(tether_target, COMSIG_MOVABLE_MOVED, PROC_REF(on_target_moved))
	RegisterSignal(tether_target, COMSIG_QDELETING, PROC_REF(on_delete))

/datum/component/phone_cable/Destroy(force)
	if(!QDELETED(tether_beam))
		qdel(tether_beam)
	return ..()

/datum/component/phone_cable/proc/create_beam()
	if(!QDELETED(tether_beam))
		qdel(tether_beam)

	tether_beam = tether_target.Beam(
		src.tether_parent,
		src.icon_name,
		src.icon_file,
		emissive = FALSE,
		beam_type = /obj/effect/ebeam,
		layer = GIB_LAYER,
	)


/datum/component/phone_cable/proc/on_parent_pre_move()
	SIGNAL_HANDLER


/datum/component/phone_cable/proc/on_parent_moved()
	SIGNAL_HANDLER
	if(!isturf(tether_parent.loc))
		while(!isturf(tether_parent.loc))
			tether_parent = tether_parent.loc
	create_beam()

/datum/component/phone_cable/proc/on_target_pre_move()
	SIGNAL_HANDLER


/datum/component/phone_cable/proc/on_target_moved()
	SIGNAL_HANDLER
	if(!isturf(tether_target.loc))
		while(!isturf(tether_target.loc))
			tether_target = tether_target.loc
	create_beam()


/datum/component/phone_cable/proc/on_delete()
	SIGNAL_HANDLER
	qdel(src)
