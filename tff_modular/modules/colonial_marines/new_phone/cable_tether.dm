#define UNREGISTER_VIS_SIDE(side) \
	if(!isnull(side)) { \
		UnregisterSignal(side, COMSIG_MOVABLE_PRE_MOVE); \
		side = null; \
	}

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
	/// One side of the tether
	var/atom/vis_parent
	/// Other side of the tether
	var/atom/vis_target

/datum/component/phone_cable/Initialize(atom/target, max_dist, tether_name, icon="line", icon_file='icons/obj/clothing/modsuit/mod_modules.dmi')
	if(!ismovable(parent) || !istype(target))
		return COMPONENT_INCOMPATIBLE

	src.tether_parent = parent
	src.tether_target = target
	src.max_dist = max_dist
	src.icon_name = icon
	src.icon_file = icon_file
	src.tether_name = tether_name

	RegisterSignal(tether_target, COMSIG_QDELETING, PROC_REF(on_delete))

	RegisterSignal(tether_parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(tether_target, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))

	redraw_beam()

/datum/component/phone_cable/Destroy(force)
	SEND_SIGNAL(src, COMSIG_CABLE_SNAPPED)

	UnregisterSignal(tether_target, COMSIG_QDELETING)

	UnregisterSignal(tether_parent, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(tether_target, COMSIG_MOVABLE_MOVED)
	tether_parent = null
	tether_target = null

	if(!isnull(vis_parent))
		UnregisterSignal(vis_parent, COMSIG_MOVABLE_PRE_MOVE)
		vis_parent = null
	if(!isnull(vis_target))
		UnregisterSignal(vis_target, COMSIG_MOVABLE_PRE_MOVE)
		vis_target = null

	if(!QDELETED(tether_beam))
		UnregisterSignal(tether_beam, COMSIG_QDELETING)
		QDEL_NULL(tether_beam)
	return ..()

/datum/component/phone_cable/proc/redraw_beam()
	message_admins("Перерисовка")
	if(QDELING(src))
		return

	if(QDELETED(tether_parent) || QDELETED(tether_target))
		message_admins("OnBD - Не хватает родителей")
		qdel(src)
		return

	var/atom/new_vis_parent = check_holder(tether_parent)
	var/atom/new_vis_target = check_holder(tether_target)

	if(isnull(new_vis_parent) || isnull(new_vis_target))
		snap()
		return

	if(get_dist(vis_parent, vis_target) > max_dist || new_vis_parent.z != new_vis_target.z)
		message_admins("OnBD - Нужно удалить [get_dist(vis_parent, vis_target)] pz: [new_vis_parent.z] tz: [new_vis_target.z]")
		qdel(src)
		return

	if(!QDELETED(tether_beam))
		if((new_vis_parent == vis_parent) && (new_vis_target == vis_target))
			message_admins("OnBD - Все ок, ничего не надо менять")
			return
		UnregisterSignal(tether_beam, COMSIG_QDELETING)
		QDEL_NULL(tether_beam)

	if(new_vis_parent != vis_parent)
		UNREGISTER_VIS_SIDE(vis_parent)
		vis_parent = new_vis_parent
		RegisterSignal(vis_parent, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_pre_move), TRUE)

	if(new_vis_target != vis_target)
		UNREGISTER_VIS_SIDE(vis_target)
		vis_target = new_vis_target
		RegisterSignal(vis_target, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_pre_move), TRUE)

	if(vis_parent == vis_target)
		message_admins("OnBD - Цель и есть родитель")
		return

	tether_beam = vis_target.Beam(
		vis_parent,
		src.icon_name,
		src.icon_file,
		maxdistance = max_dist + 1,
		beam_type = /obj/effect/ebeam,
		emissive = FALSE,
		layer = GIB_LAYER,
		override_target_pixel_x = vis_parent.pixel_x + 3,
		override_target_pixel_y = vis_parent.pixel_y + 2,
	)

	RegisterSignal(tether_beam, COMSIG_QDELETING, PROC_REF(need_redraw))

/datum/component/phone_cable/proc/snap()
	message_admins("SNAP")
	qdel(src)

/datum/component/phone_cable/proc/need_redraw()
	SIGNAL_HANDLER
	redraw_beam()

/proc/check_holder(atom/weh)
	var/atom/result = weh.loc
	if(result == get_turf(weh.loc))
		return weh
	if(result.loc == get_turf(weh.loc))
		return result
	return null

/datum/component/phone_cable/proc/on_delete()
	SIGNAL_HANDLER
	qdel(src)

/datum/component/phone_cable/proc/on_move(atom/movable/source, atom/oldloc)
	SIGNAL_HANDLER

	message_admins("Source: [source] + [source.loc] + [oldloc] | [vis_parent] - [vis_target] | [QDELETED(tether_beam)]")

	if(isturf(oldloc) && isturf(source.loc))
		return

	redraw_beam()

/datum/component/phone_cable/proc/on_pre_move(atom/movable/source, new_loc)
	SIGNAL_HANDLER

	if(QDELING(src))
		return

	var/atom/movable/anchor = (source == vis_target ? vis_parent : vis_target)
	if(get_dist(anchor, new_loc) > max_dist)
		if(!istype(anchor) || anchor.anchored || !(!anchor.anchored && anchor.move_resist <= source.move_force && anchor.Move(get_step_towards(anchor, new_loc))))
			to_chat(source, span_warning("Your tether to \the [tether_parent] prevents you from moving any further!"))
			return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

#undef UNREGISTER_VIS_SIDE
