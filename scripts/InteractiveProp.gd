# Путь: scripts/InteractiveProp.gd
extends Area2D

@export var prop_id: String = ""

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		
		var player = get_tree().current_scene.get_node_or_null("Konstantin")
		if player:
			player.walk_to(global_position.x)
			
		_interact()

func _interact() -> void:
	var dark: bool = GameState.is_dark_world
	
	match prop_id:
		# --- КОМНАТА 1: ПРИЕМНЫЙ ПОКОЙ ---
		"nurses":
			if not dark:
				GameState.open_dialogue("nurses")
			else:
				GameState.say("Два высохших скелета в истлевшей форме медсестер сидят в пыли. Вокруг их черепов намотаны толстые черные нитки, плотно закрывающие уши... На стене нацарапано: «НЕ СЛУШАЙ ТИКАНЬЕ».")
		
		"door_to_ward":
			if not GameState.talked_to_nurses and not dark:
				GameState.say("Дверь в палаты закрыта. Сначала нужно спросить у дежурных медсестер, где лежит дедушка Серафим.")
			else:
				GameState.change_room("ward")
				if not dark:
					GameState.say("Я прошел по коридору в Палату №6, где должен жить дедушка Серафим.")
				else:
					GameState.say("Я шагнул в разрушенную палату. Под ногами хрустит битое стекло и вековая пыль.")

		"door_to_exit":
			GameState.change_room("exit_hall")
			if dark and not GameState.met_man_in_white:
				GameState.say("У заколоченного выхода на фоне черного леса за окном стоит человек в ослепительно белом костюме...")
			elif not dark:
				GameState.say("Парадный выход из пансионата «Омут».")

		# --- КОМНАТА 2: ПАЛАТА №6 И КОРИДОР СТАРИКОВ ---
		"grandpa_bed":
			if not dark:
				GameState.checked_grandpa_bed = true
				GameState.say("Кровать дедушки Серафима пуста! Матрас холодный, его тут нет. Надо расспросить его соседа по палате и старушек у окна.")
			else:
				GameState.say("Сгнивший железный каркас кровати, оплетенный сухими корнями. На спинке вырезано: «06:00 — ВРЕМЯ СТОИТ».")

		"roommate":
			if not dark:
				if not GameState.checked_grandpa_bed:
					GameState.say("Старик на соседней койке смотрит в стену. Сначала проверю кровать дедушки.")
				else:
					GameState.open_dialogue("roommate")
			else:
				GameState.say("Скелет старика Игната в кресле-каталке. Его уши тоже намертво перетянуты суровой бечевкой, а в костлявых пальцах зажат сломанный слуховой рожок.")

		"grannies":
			if not dark:
				if not GameState.checked_grandpa_bed:
					GameState.say("Две старушки синхронно вяжут шарф. Сначала посмотрю, на месте ли дедушка.")
				else:
					GameState.open_dialogue("grannies")
			else:
				GameState.say("Два скелета старушек, спутанных одной бесконечной черной шерстяной нитью. Нить десятки раз обмотана вокруг их голов, затыкая уши, чтобы они не слышали бой часов.")

		"door_to_bathroom":
			if not dark and (not GameState.talked_to_roommate or not GameState.talked_to_grannies):
				GameState.say("Дверь в умывальную. Сначала мне нужно подробно расспросить и соседа дедушки, и бабушек — вдруг они знают, куда он пропал.")
			else:
				GameState.change_room("bathroom")
				GameState.say("Я вошел в старую кафельную умывальную. Здесь сыро и гулко капает вода.")

		"door_back_reception":
			GameState.change_room("reception")

		# --- КОМНАТА 3: ТУАЛЕТ / УМЫВАЛЬНАЯ ---
		"sink":
			if not dark:
				GameState.washed_face = true
				GameState.say("Я плеснул ледяной водой в лицо... Вдруг прямо над головой, из вентиляционной шахты под потолком, раздался глухой стук и тиканье! Нужно залезть на унитаз и посмотреть наверх.")
			else:
				GameState.say("Раковина расколота пополам и забита сухой серой пылью и паутиной.")

		"toilet_climb":
			if not dark:
				if not GameState.washed_face:
					GameState.say("Старый унитаз с высоким чугунным бачком. Сначала умоюсь у раковины, голова гудит с дороги.")
				elif not GameState.has_pocket_watch:
					GameState.trigger_ceiling_grab_cutscene()
				else:
					GameState.say("Вентиляционный люк под потолком пуст. Я больше ни за что не полезу туда к этой руке!")
			else:
				GameState.say("Над сломанным бачком зияет черная дыра вентиляции. Оттуда свешиваются сухие серые пальцы, но в этом мертвом мире они неподвижны.")

		"door_Bathroom_to_ward":
			GameState.change_room("ward")

		# --- КОМНАТА 4: ВЫХОД И ЧЕЛОВЕК В БЕЛОМ ---
		"man_in_white":
			if dark:
				GameState.open_dialogue("man_in_white")

		"forest_exit":
			if not GameState.met_man_in_white:
				if dark:
					GameState.say("Дверь забита досками. Сначала нужно поговорить с этим странным Человеком в Белом!")
				else:
					GameState.say("Я не могу уйти из пансионата, пока не пойму, куда исчез дедушка Серафим.")
			elif GameState.is_dark_world:
				GameState.say("В Темном мире дверь оплетена черными корнями. Человек в Белом сказал сначала активировать часы и вернуться в обычный мир!")
			elif not GameState.inspected_watch_back:
				GameState.say("Мы вернулись в обычный мир! Перед тем как идти в лес, нужно осмотреть заднюю крышку часов (кнопка рядом с часами сверху).")
			else:
				GameState.say("КОНЕЦ 1-2 АКТА: Я сжал часы Серафима и шагнул в затяжной туманный лес к Черной реке и Старому Маяку! [Переход к Акту 3: Лес и Переправа]")