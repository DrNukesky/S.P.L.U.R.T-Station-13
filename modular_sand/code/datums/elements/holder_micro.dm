/datum/element/mob_holder/micro

/datum/element/mob_holder/micro/Attach(datum/target, _worn_state, _alt_worn, _right_hand, _left_hand, _inv_slots = NONE, _proctype)
	. = ..()

	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	worn_state = _worn_state
	alt_worn = _alt_worn
	right_hand = _right_hand
	left_hand = _left_hand
	inv_slots = _inv_slots
	proctype = _proctype

	RegisterSignal(target, COMSIG_CLICK_ALT, .proc/mob_try_pickup_micro, override = TRUE)
	RegisterSignal(target, COMSIG_PARENT_EXAMINE, .proc/on_examine, override = TRUE)
	RegisterSignal(target, COMSIG_MICRO_PICKUP_FEET, .proc/mob_pickup_micro_feet)

/datum/element/mob_holder/micro/Detach(datum/source, force)
	. = ..()
	UnregisterSignal(source, COMSIG_CLICK_ALT)
	UnregisterSignal(source, COMSIG_PARENT_EXAMINE)
	UnregisterSignal(source, COMSIG_MICRO_PICKUP_FEET)

/datum/element/mob_holder/micro/on_examine(mob/living/source, mob/user, list/examine_list)
	if(ishuman(user) && !istype(source.loc, /obj/item/clothing/head/mob_holder))
		if(ismonkey(source)) //Incredibly easy way to fix duplicates, this is so stupid, but at least nobody can notice
			RemoveElement(/datum/element/mob_holder/micro, "micro")
		if(!ismonkey(source))
			examine_list += "<span class='notice'>Looks like [source.p_they(FALSE)] can be picked up with <b>Alt+Click</b>!</span>"

/datum/element/mob_holder/micro/proc/mob_pickup_micro(mob/living/source, mob/user)
	var/obj/item/clothing/head/mob_holder/micro/holder = new(get_turf(source), source, worn_state, alt_worn, right_hand, left_hand, inv_slots)
	if(!holder)
		return
	user.put_in_hands(holder)
	return

//shoehorned (get it?) and lazy way to do instant foot pickups cause haha funny.
/datum/element/mob_holder/micro/proc/mob_pickup_micro_feet(mob/living/source, mob/user)
	var/obj/item/clothing/head/mob_holder/micro/holder = new(get_turf(source), source, worn_state, alt_worn, right_hand, left_hand, inv_slots)
	if(!holder)
		return
	user.equip_to_slot(holder, SLOT_SHOES)
	return

/datum/element/mob_holder/micro/proc/mob_try_pickup_micro(mob/living/carbon/source, mob/living/carbon/user)
	if(ismonkey(source)) //Incredibly easy way to fix duplicates, this is so stupid, but at least nobody can notice
		RemoveElement(/datum/element/mob_holder/micro, "micro")
	if(!ishuman(user) || !user.Adjacent(source) || user.incapacitated())
		return FALSE
	if(abs(user.dna?.features["body_size"]/source.dna?.features["body_size"]) < 2.0 )
		to_chat(user, "<span class='warning'>They're too big to pick up!</span>")
		return FALSE
	if(user.get_active_held_item())
		to_chat(user, "<span class='warning'>Your hands are full!</span>")
		return FALSE
	if(source.buckled)
		to_chat(user, "<span class='warning'>[source] is buckled to something!</span>")
		return FALSE
	if(source == user)
		to_chat(user, "<span class='warning'>You can't pick yourself up.</span>")
		return FALSE
	source.visible_message("<span class='warning'>[user] starts picking up [source].</span>", \
					"<span class='userdanger'>[user] starts picking you up!</span>")
	var/p = abs(source.dna?.features["body_size"]/user.dna?.features["body_size"] * 40) //Scale how fast the pickup will be depending on size difference
	if(!do_after(user, p, target = source))
		return FALSE

	if(user.get_active_held_item()||source.buckled)
		return FALSE

	source.visible_message("<span class='warning'>[user] picks up [source]!</span>", \
					"<span class='userdanger'>[user] picks you up!</span>")
	to_chat(user, "<span class='notice'>You pick [source] up.</span>")
	source.drop_all_held_items()
	mob_pickup_micro(source, user)
	return TRUE

/obj/item/clothing/head/mob_holder/micro
	name = "micro"
	desc = "Another person, small enough to fit in your hand."
	icon = null
	icon_state = ""
	slot_flags = ITEM_SLOT_FEET | ITEM_SLOT_HEAD | ITEM_SLOT_ID | ITEM_SLOT_BACK | ITEM_SLOT_NECK
	w_class = null //handled by their size

//TODO: add a timer to escape someone's grip dependant on size diff
/obj/item/clothing/head/mob_holder/micro/container_resist(mob/living/user)
	if(user.incapacitated())
		to_chat(user, "<span class='warning'>You can't escape while you're restrained like this!</span>")
		return
	var/mob/living/L = loc
	visible_message("<span class='warning'>[src] begins to squirm in [L]'s grasp!</span>")
	if(do_after(user, 1200, target = src, required_mobility_flags = MOBILITY_RESIST))
		if(!user || user.stat != CONSCIOUS || user.loc != src)
			return
		to_chat(loc, "<span class='warning'>[src] stops resisting.</span>")
		return
	visible_message("<span class='warning'>[src] escapes [L]!")
	release()

/obj/item/clothing/head/mob_holder/micro/MouseDrop(mob/M as mob)
	..()
	if(M != usr)
		return
	if(usr == src)
		return
	if(!Adjacent(usr))
		return
	if(istype(M,/mob/living/silicon/ai))
		return
	for(var/mob/living/carbon/human/O in contents)
		O.show_inv(usr)

/obj/item/clothing/head/mob_holder/micro/attack_self(mob/living/user)
	if(cooldown < world.time)
		for(var/mob/living/carbon/human/M in contents)
			cooldown = world.time + 15
			if(user.a_intent == "harm") //TO:DO, rework all of these interactions to be a lot more in depth
				visible_message("<span class='danger'> slams their fist down on [M]!</span>", runechat_popup = 1)
				playsound(loc, 'sound/weapons/punch1.ogg', 50, 1)
				M.adjustBruteLoss(5)
				return
			if(user.a_intent == "disarm")
				visible_message("<span class='danger'> pins [M] down with a finger!</span>", runechat_popup = 1)
				playsound(loc, 'sound/effects/bodyfall1.ogg', 50, 1)
				M.adjustStaminaLoss(10)
				return
			if(user.a_intent == "grab")
				visible_message("<span class='danger'> squeezes their fist around [M]!</span>", runechat_popup = 1)
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1)
				M.adjustOxyLoss(5)
				return
			M.help_shake_act(user)

/obj/item/clothing/head/mob_holder/micro/attacked_by(obj/item/I, mob/living/user)
	return held_mob?.attacked_by(I, user) || ..()
