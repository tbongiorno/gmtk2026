extends Node2D


var entry_scene = preload("res://src/ui/entry.tscn") # update this to a path that matches your entry scene

@export var leaderboard_internal_name: String = "speed-shooter-leaderboard"

@onready var entries_container: VBoxContainer = %Entries
@onready var username: TextEdit = %Username

@onready var time = time_manager

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	%time_label.text = "Your Time is " + str(int(time.curr_time_elapsed() / 60)) + ":" + str(int(time.curr_time_elapsed()) % 60)
	
	if not time.is_time_stopped():
		time.start_or_stop_time()
	await _load_entries()

func _create_entry(entry: TaloLeaderboardEntry) -> void:
	var entry_instance = entry_scene.instantiate()
	entry_instance.set_data(entry.position, entry.player_alias.identifier, entry.score)
	entries_container.add_child(entry_instance)

func _build_entries() -> void:
	for child in entries_container.get_children():
		child.queue_free()

	for entry in Talo.leaderboards.get_cached_entries(leaderboard_internal_name):
		_create_entry(entry)

func _load_entries() -> void:
	var page = 0
	var done = false

	while !done:
		var options := Talo.leaderboards.GetEntriesOptions.new()
		options.page = page

		var res := await Talo.leaderboards.get_entries(leaderboard_internal_name, options)
		var entries: Array[TaloLeaderboardEntry] = res.entries
		var count: int = res.count
		var is_last_page: bool = res.is_last_page
		
		if is_last_page:
			done = true
		else:
			page += 1
	
	_build_entries()

func _on_submit_pressed() -> void:
	await Talo.players.identify("username", username.text)

	var score : float = time.curr_time_elapsed()
	var res := await Talo.leaderboards.add_entry(leaderboard_internal_name, score)

	_build_entries()
	$UI/MarginContainer/VBoxContainer/Buttons/Submit.disabled = true
	


func _on_home_pressed():
	time.reset()
	get_tree().change_scene_to_file("res://src/ui/start_screen.tscn")
