
/obj/structure/chair/comfy/shuttle/doublewide
	icon = 'tff_modular/modules/colonial_marines/alamo/icons/objects.dmi'
	icon_state = "doublewide_chair"
	has_armrest = FALSE

	var/user_offset_x = 0
	var/user_offset_y = 0

/obj/structure/chair/comfy/shuttle/doublewide/post_buckle_mob(mob/living/M)
	. = ..()
	M.add_offsets(type, x_add = user_offset_x, y_add = user_offset_y)

/obj/structure/chair/comfy/shuttle/doublewide/post_unbuckle_mob(mob/living/M)
	. = ..()
	M.remove_offsets(type)

/obj/structure/chair/comfy/shuttle/doublewide/left
	pixel_x = -8
	user_offset_x = -8

/obj/structure/chair/comfy/shuttle/doublewide/right
	pixel_x = 9
	user_offset_x = 9


/obj/machinery/door/airlock/multi_tile/alamo
	name = "\improper Alamo crew hatch"
	icon = 'tff_modular/modules/colonial_marines/alamo/icons/airlock.dmi'
	max_integrity = INFINITY
	opacity = TRUE

	opens_with_door_remote = FALSE
	glass = FALSE
	can_be_glass = FALSE

/obj/machinery/door/airlock/multi_tile/alamo/cargo
	name = "\improper Alamo cargo door"
	icon = 'tff_modular/modules/colonial_marines/alamo/icons/cargo_airlock.dmi'


/datum/map_template/shuttle/alamo
	name = "alamo dropship"
	prefix = "_maps/shuttles/fluffy/"
	suffix = "alamo"
	port_id = "dropship"
	who_can_purchase = null

