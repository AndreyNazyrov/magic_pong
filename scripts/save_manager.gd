extends Node

const SAVE_PATH = "user://save.dat"

var coins: int = 0
var unlocked_levels: int = 1 # Открыт только 1-й уровень
var current_level: int = 1

func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(coins)
		file.store_var(unlocked_levels)
		file.close()

func load_game():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			coins = file.get_var()
			unlocked_levels = file.get_var()
			file.close()

func add_coins(amount: int):
	coins += amount
	save_game()

func unlock_level(level: int):
	if level > unlocked_levels:
		unlocked_levels = level
		save_game()
