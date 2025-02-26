/obj/structure/bed/Destroy()
	unbuckle_all_mobs()
	return ..()

/obj/structure/bed/dogbed/shadow
	icon = 'modular_eros/icons/obj/objects.dmi'
	icon_state = "dogbed_shadow"
	buildstacktype = /obj/item/stack/sheet/mineral/wood/shadow

/obj/structure/bed/dogbed/mushroom
	icon = 'modular_eros/icons/obj/objects.dmi'
	icon_state = "dogbed_mushwood"
	buildstacktype = /obj/item/stack/sheet/mineral/wood/mushroom

/obj/structure/bed/shadow
	name = "shadow bed"
	desc = "A bunch of shadow planks strewn together. Better than sleeping on the ground."
	icon_state = "bed_shadow"
	icon = 'modular_eros/icons/obj/structures/beds.dmi'
	buildstacktype = /obj/item/stack/sheet/mineral/wood/shadow

/obj/structure/bed/double/shadow
	name = "shadow double bed"
	desc = "A double shadow bed, because tribals need luxury too."
	icon = 'modular_eros/icons/obj/structures/beds.dmi'
	icon_state = "bed_wide_shadow"
	buildstacktype = /obj/item/stack/sheet/mineral/wood/shadow

/obj/structure/bed/matress
	name = "matress"
	desc = "This is used to lie in, sleep in or strap on."
	icon_state = "mattress0"

/obj/structure/bed/matress/New()
	..()
	icon_state = "mattress[rand(0,6)]"
	
