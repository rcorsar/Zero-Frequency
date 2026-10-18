# Путь: scripts/LobbyRoom.gd
extends Node2D

@onready var room_bg: ColorRect = $RoomBackground
@onready var floor_rect: ColorRect = $Floor
@onready var dark_overlay: ColorRect = $DarkOverlay
@onready var room_title_lbl: Label = $UI/RoomTitleLabel

# Контейнеры комнат
@onready var room_reception: Node2D = $Room_Reception
@onready var room_ward: Node2D = $Room_Ward
@onready var room_bathroom: Node2D = $Room_Bathroom
@onready var room_exit: Node2D = $Room_ExitHall

# UI Часов с сердцем
@onready var watch_panel: Panel = $UI/WatchPanel
@onready var heart_visual: ColorRect = $UI/WatchPanel/HeartVisual
@onready var watch_status_lbl: Label = $UI/WatchPanel/WatchStatusLabel
@onready var toggle_watch_btn: Button = $UI/WatchPanel/ToggleWatchBtn
@onready var inspect_back_btn: Button = $UI/WatchPanel/InspectBackBtn

@onready var subtitle_label: Label = $UI/SubtitlePanel/SubtitleLabel

# Окно диалога
@onready var dialogue_panel: Panel = $UI/DialogueModal
@onready var npc_title: Label = $UI/DialogueModal/NpcTitle
@onready var npc_speech: Label = $UI/DialogueModal/NpcSpeech
@onready var opt_1: Button = $UI/DialogueModal/VBoxOptions/Opt1
@onready var opt_2: Button = $UI/DialogueModal/VBoxOptions/Opt2
@onready var opt_close: Button = $UI/DialogueModal/VBoxOptions/OptClose

var current_npc: String = ""

func _ready() -> void:
	GameState.world_updated.connect(_refresh_scene)
	GameState.thought_requested.connect(func(txt: String): subtitle_label.text = txt)
	GameState.dialogue_requested.connect(_open_dialogue)
	
	toggle_watch_btn.pressed.connect(func(): GameState.toggle_watch())
	inspect_back_btn.pressed.connect(_on_inspect_watch_back)
	
	opt_1.pressed.connect(func(): _on_dialogue_choice(1))
	opt_2.pressed.connect(func(): _on_dialogue_choice(2))
	opt_close.pressed.connect(func(): dialogue_panel.visible = false)
	
	dialogue_panel.visible = false
	_refresh_scene()
	GameState.say("Константин Веретенников (13 лет): «Пансионат \"Омут\" у Ладожского озера. Подойду к медсестрам и спрошу, в какой палате мой дедушка Серафим.»")

func _process(_delta: float) -> void:
	# Анимация биения сердца внутри часов (только когда они в обычном мире!)
	if GameState.has_pocket_watch:
		if not GameState.is_dark_world:
			var pulse: float = 1.0 + sin(Time.get_ticks_msec() * 0.012) * 0.18
			heart_visual.scale = Vector2(pulse, pulse)
		else:
			heart_visual.scale = Vector2(1.0, 1.0)

func _refresh_scene() -> void:
	var dark: bool = GameState.is_dark_world
	var r: String = GameState.current_room
	
	# Переключаем видимость активной комнаты и блокируем клики в скрытых
	_set_room_active(room_reception, r == "reception")
	_set_room_active(room_ward, r == "ward")
	_set_room_active(room_bathroom, r == "bathroom")
	_set_room_active(room_exit, r == "exit_hall")
	
	# Человек в Белом виден только у выхода в Темном мире
	var man_node = room_exit.get_node_or_null("ManInWhiteProp")
	if man_node:
		man_node.visible = dark
		man_node.input_pickable = dark

	# Цвета и атмосфера мира
	dark_overlay.visible = dark
	if dark:
		room_bg.color = Color(0.11, 0.11, 0.13) # Пыльный угольно-серый склеп
		floor_rect.color = Color(0.07, 0.07, 0.08)
	else:
		room_bg.color = Color(0.24, 0.25, 0.22) # Больничный бледно-зеленоватый сепия
		floor_rect.color = Color(0.16, 0.14, 0.12)

	# Названия локаций
	var room_names := {
		"reception": "ПРИЕМНЫЙ ПОКОЙ ПАНСИОНАТА «ОМУТ»",
		"ward": "ПАЛАТА №6 СЕРАФИМА И ОБЩИЙ КОРИДОР",
		"bathroom": "СТАРАЯ КАФЕЛЬНАЯ УМЫВАЛЬНАЯ",
		"exit_hall": "ПАРАДНОЕ КРЫЛЬЦО И ВЫХОД К ЛЕСУ"
	}
	room_title_lbl.text = room_names.get(r, "") + (" [ТЕМНЫЙ МИР: ЗАБРОШКА]" if dark else " [ОБЫЧНЫЙ МИР]")

	# Панель часов Серафима (появляется только после сцены в туалете!)
	watch_panel.visible = GameState.has_pocket_watch
	if GameState.has_pocket_watch:
		if dark:
			heart_visual.color = Color(0.08, 0.08, 0.09) # Черное замершее сердце
			watch_status_lbl.text = "Часы Серафима: СЕРДЦЕ ЧЕРНОЕ (ЗАМЕРЛО)"
			toggle_watch_btn.text = "Нажать головку часов (В Обычный мир)"
		else:
			heart_visual.color = Color(0.85, 0.12, 0.18) # Алое бьющееся сердце
			watch_status_lbl.text = "Часы Серафима: СЕРДЦЕ БЬЕТСЯ (ТУК-ТУК)"
			toggle_watch_btn.text = "Нажать головку часов (В Темный мир)"

func _set_room_active(room_node: Node2D, active: bool) -> void:
	room_node.visible = active
	for child in room_node.get_children():
		if child is Area2D:
			child.input_pickable = active

func _on_inspect_watch_back() -> void:
	if GameState.is_dark_world and not GameState.met_man_in_white:
		GameState.say("В этом мраке задняя крышка покрыта инеем. Нужно сначала выбраться к выходу из больницы.")
	else:
		GameState.inspected_watch_back = true
		GameState.say("Я открыл заднюю крышку часов! Под ней карта и гравировка дедушки: «Костя, иди через старый лес и Черную реку к Маяку на мысе Раскол. Жду тебя там. Серафим Веретенников».")

func _open_dialogue(npc_id: String) -> void:
	current_npc = npc_id
	dialogue_panel.visible = true
	
	match npc_id:
		"nurses":
			npc_title.text = "Дежурные медсестры Зинаида и Марфа"
			npc_speech.text = "«Здравствуй, мальчик! Ты Константин Веретенников? Твой дедушка Серафим так ждал тебя!»"
			opt_1.text = "1. Где я могу его увидеть? Отведите меня к нему."
			opt_2.text = "2. Почему в пансионате так тихо и все часы стоят?"
		"roommate":
			npc_title.text = "Сосед по палате — старый телеграфист Игнат"
			npc_speech.text = "«А? Кто здесь? Серафима ищешь, внучок?»"
			opt_1.text = "1. Его кровать пуста! Куда дедушка мог уйти?"
			opt_2.text = "2. Почему вы зажимаете уши руками, дедушка Игнат?"
		"grannies":
			npc_title.text = "Старушки-сестры Глаша и Паша"
			npc_speech.text = "«Петелька к петельке, ниточка к ниточке... Скоро шесть утра, милый...»"
			opt_1.text = "1. Бабушки, вы не видели моего дедушку Серафима Веретенникова?"
			opt_2.text = "2. Зачем вам столько черных шерстяных ниток?"
		"man_in_white":
			npc_title.text = "Человек в Белом (Незнакомец из Пустоты)"
			npc_speech.text = "«Не бойся, Константин. То, что ты видишь вокруг — настоящая участь этого места. Их уши завязаны нитями, чтобы не слышать, как остановилось время.»"
			opt_1.text = "1. Кто вы?! И как мне заставить часы снова работать и выбраться отсюда?"
			opt_2.text = "2. Где мой дедушка Серафим? Та рука в потолке утащила и его?"

func _on_dialogue_choice(choice: int) -> void:
	match current_npc:
		"nurses":
			if choice == 1:
				GameState.talked_to_nurses = true
				npc_speech.text = "«Его койка в Палате №6, прямо по коридору направо! Иди смело, дверь теперь открыта!»"
			else:
				npc_speech.text = "«Тихо? Что ты, милый, просто еще раннее утро, все отдыхают перед завтраком!»"
		"roommate":
			if choice == 1:
				GameState.talked_to_roommate = true
				npc_speech.text = "«Серафим боялся, что его часы отберут! Он вчера вечером встал на стул в умывальной и спрятал что-то в вентиляционную решетку под потолком!»"
			else:
				npc_speech.text = "«Тикает! В стенах все время тикает! Я бы зашил себе уши суровой ниткой, лишь бы не слышать этот проклятый маятник!»"
		"grannies":
			if choice == 1:
				GameState.talked_to_grannies = true
				npc_speech.text = "«В умывальную он пошел, соколик, в туалет в конце крыла! Умыться хотел, да так оттуда и не вышел! Иди умойся и посмотри наверх...»"
			else:
				npc_speech.text = "«Чтобы ушки завязать, когда шесть утра грянет! Кто тиканье услышит — тот в пыль обратится!»"
		"man_in_white":
			if choice == 1:
				GameState.met_man_in_white = true
				GameState.can_control_watch = true
				_refresh_scene()
				npc_speech.text = "«Я друг твоей семьи. Смотри: я разблокировал заводную головку твоих часов. Нажми на неё — черное сердце снова забьется алым, и ты вернешься в мир живых. А под задней крышкой часов Серафим оставил тебе адрес.»"
			else:
				npc_speech.text = "«Серафима здесь нет. Он ушел туда, откуда бьет луч над черной водой. Активируй часы, загляни под их заднюю крышку и ступай через лес.»"