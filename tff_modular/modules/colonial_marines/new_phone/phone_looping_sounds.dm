/datum/looping_sound/telephone/dial
	start_sound = 'tff_modular/modules/colonial_marines/telephone/sound/dial.ogg'
	start_length = 3.2 SECONDS
	mid_sounds = 'tff_modular/modules/colonial_marines/telephone/sound/ring_outgoing.ogg'
	mid_length = 2.1 SECONDS
	volume = 10

/datum/looping_sound/telephone/busy
	start_sound = 'tff_modular/modules/colonial_marines/telephone/sound/callstation_unavailable.ogg'
	start_length = 5.7 SECONDS
	mid_sounds = 'tff_modular/modules/colonial_marines/telephone/sound/phone_busy.ogg'
	mid_length = 1 SECONDS
	volume = 15
	falloff_exponent = 10

/datum/looping_sound/telephone/hangup
	start_sound = 'tff_modular/modules/colonial_marines/telephone/sound/remote_hangup.ogg'
	start_length = 0.6 SECONDS
	mid_sounds = 'tff_modular/modules/colonial_marines/telephone/sound/phone_busy.ogg'
	mid_length = 1 SECONDS
	volume = 15
	falloff_exponent = 10

/datum/looping_sound/telephone/connection_problem
	start_sound = 'tff_modular/modules/colonial_marines/telephone/sound/SIT.ogg'
	start_length = 6 SECONDS
	start_volume = 30
	mid_sounds = 'tff_modular/modules/colonial_marines/telephone/sound/reorder_tone.ogg'
	mid_length = 1 SECONDS
	volume = 7

/datum/looping_sound/telephone/ring
	mid_sounds = 'tff_modular/modules/colonial_marines/telephone/sound/telephone_ring.ogg'
	mid_length = 3 SECONDS
	volume = 15
	falloff_exponent = 3
