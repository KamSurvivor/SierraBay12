/*
CONTAINS:
RSF

*/

/obj/item/rsf
	name = "rapid service fabricator"
	desc = "A device used to rapidly deploy service items."
	icon = 'icons/obj/tools/rcd.dmi'
	icon_state = "rcd"
	opacity = 0
	density = FALSE
	anchored = FALSE
	var/stored_matter = 30
	var/mode = 1
	w_class = ITEM_SIZE_NORMAL

/obj/item/rsf/examine(mob/user, distance)
	. = ..()
	if(distance <= 0)
		to_chat(user, "It currently holds [stored_matter]/30 fabrication-units.")

/obj/item/rsf/attackby(obj/item/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/rcd_ammo))

		if ((stored_matter + 10) > 30)
			to_chat(user, "The RSF can't hold any more matter.")
			return

		qdel(W)

		stored_matter += 10
		playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
		to_chat(user, "The RSF now holds [stored_matter]/30 fabrication-units.")
		return

/obj/item/rsf/attack_self(mob/user as mob)
	playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
	if (mode == 1)
		mode = 2
		to_chat(user, "Changed dispensing mode to 'Drinking Glass'")
		return
	if (mode == 2)
		mode = 3
		to_chat(user, "Changed dispensing mode to 'Paper'")
		return
	if (mode == 3)
		mode = 4
		to_chat(user, "Changed dispensing mode to 'Pen'")
		return
	if (mode == 4)
		mode = 5
		to_chat(user, "Changed dispensing mode to 'Dice Pack'")
		return
	if (mode == 5)
		mode = 1
		to_chat(user, "Changed dispensing mode to 'Cigarette'")
		return

/obj/item/rsf/use_after(atom/A, mob/living/user, click_parameters)
	if(istype(user,/mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = user
		if(R.stat || !R.cell || R.cell.charge <= 0)
			to_chat(user, SPAN_WARNING("You are unable to use \the [src]."))
			return TRUE
	else
		if(stored_matter <= 0)
			to_chat(user, SPAN_WARNING("\The [src] is empty!"))
			return TRUE

	if(!istype(A, /obj/structure/table) && !istype(A, /turf/simulated/floor))
		return FALSE

	playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
	var/used_energy = 0
	var/obj/product

	switch(mode)
		if(1)
			product = new /obj/item/clothing/mask/smokable/cigarette()
			used_energy = 10
		if(2)
			product = new /obj/item/reagent_containers/food/drinks/glass2()
			used_energy = 50
		if(3)
			product = new /obj/item/paper()
			used_energy = 10
		if(4)
			product = new /obj/item/pen()
			used_energy = 50
		if(5)
			product = new /obj/item/storage/pill_bottle/dice()
			used_energy = 200

	to_chat(user, "Dispensing [product ? product : "product"]...")
	product.dropInto(A.loc)

	if(isrobot(user))
		var/mob/living/silicon/robot/R = user
		if(R.cell)
			R.cell.use(used_energy)
	else
		stored_matter--
		to_chat(user, "The RSF now holds [stored_matter]/30 fabrication-units.")
	return TRUE
