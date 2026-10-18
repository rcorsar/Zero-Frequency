# Путь: scripts/GameState.gd
extends Node

signal world_updated()
signal thought_requested(text: String)
signal dialogue_requested(npc_id: String)

var current_room: String = "reception" # reception, ward, bathroom, exit_hall
var is_dark_world: bool = false

# Сюжетная прогрессия Акта 1 и Акта 2
var talked_to_nurses: bool = false
var checked_grandpa_bed: bool = false
var talked_to_roommate: bool = false
var talked_to_grannies: bool = false
var washed_face: bool = false

# Артефакт (Часы Серафима)
var has_pocket_watch: bool = false
var can_control_watch: bool = false # Открывается после встречи с Человеком в Белом
var met_man_in_white: bool = false
var inspected_watch_back: bool = false

func toggle_watch() -> void:
	if not has_pocket_watch:
		return
	if not can_control_watch:
		say("Часы заклинило после того, как эта костлявая рука схватила меня! Сердце за стеклом черное и не бьется...")
		return
		
	is_dark_world = not is_dark_world
	world_updated.emit()
	
	if is_dark_world:
		say("Я нажал на головку часов. Алое сердце за стеклом мгновенно почернело и замерло. Вокруг — пыль, скелеты и тишина.")
	else:
		say("Сердце внутри часов снова налилось алым светом и забилось: тук-тук... Больница вновь стала прежней.")

func change_room(new_room: String) -> void:
	current_room = new_room
	world_updated.emit()

func trigger_ceiling_grab_cutscene() -> void:
	has_pocket_watch = true
	is_dark_world = true
	world_updated.emit()
	say("КАТ-СЦЕНА: Я забрался на бачок и потянулся к люку... Там лежали часы с бьющимся сердцем! Вдруг из тьмы выбросилась костлявая рука, схватила меня и потянула вверх! Я в панике зажал часы — вспышка! Рука исчезла, сердце в часах почернело, а вокруг... заброшенный склеп.")

func say(text: String) -> void:
	thought_requested.emit(text)

func open_dialogue(npc_id: String) -> void:
	dialogue_requested.emit(npc_id)