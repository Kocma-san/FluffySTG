// Да, это чистая копипипаста
/proc/generate_unique_id(len = 5)
	var/static/list/used_names = list()
	var/static/valid_chars = "0123456789"

	var/list/new_name = list()
	var/text
	do
		new_name.Cut()
		for(var/i = 1 to len)
			new_name += valid_chars[rand(1,length(valid_chars))]
		text = new_name.Join()
	while(used_names[text])
	used_names[text] = TRUE
	return text


/proc/get_sound_file(group_name)
	var/sound_file
	switch(group_name)
		if("rtb_handset")
			sound_file = pick(
				'tff_modular/modules/colonial_marines/telephone/sound/rtb_handset_1.ogg',
				'tff_modular/modules/colonial_marines/telephone/sound/rtb_handset_2.ogg',
				'tff_modular/modules/colonial_marines/telephone/sound/rtb_handset_3.ogg',
				'tff_modular/modules/colonial_marines/telephone/sound/rtb_handset_4.ogg',
				'tff_modular/modules/colonial_marines/telephone/sound/rtb_handset_5.ogg',
			)
		if("talk_phone")
			sound_file = pick(
				'tff_modular/modules/colonial_marines/telephone/sound/talk_phone1.ogg',
				'tff_modular/modules/colonial_marines/telephone/sound/talk_phone2.ogg',
				'tff_modular/modules/colonial_marines/telephone/sound/talk_phone3.ogg',
				'tff_modular/modules/colonial_marines/telephone/sound/talk_phone4.ogg',
				'tff_modular/modules/colonial_marines/telephone/sound/talk_phone5.ogg',
				'tff_modular/modules/colonial_marines/telephone/sound/talk_phone6.ogg',
				'tff_modular/modules/colonial_marines/telephone/sound/talk_phone7.ogg',
			)
	return sound_file
