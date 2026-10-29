extends Node

var levels = {
	1: {
		"goal": "destroy_all",
		"text": "Три блока. Всего три. Если ты и это не разобьешь — может, лучше в ферму поиграть?",
		"blocks": [
			{"type": "big", "pos": Vector2(180, 300)},
			{"type": "big", "pos": Vector2(360, 300)},
			{"type": "big", "pos": Vector2(540, 300)}
		],
		"bonuses": [], "bonus_chance": 0.0
	},
	2: {
		"goal": "destroy_all",
		"text": "Их стало четыре. Я в тебя верю. Наверное.",
		"blocks": [
			{"type": "big", "pos": Vector2(180, 250)},
			{"type": "big", "pos": Vector2(540, 250)},
			{"type": "big", "pos": Vector2(180, 450)},
			{"type": "big", "pos": Vector2(540, 450)}
		],
		"bonuses": [], "bonus_chance": 0.0
	},
	3: {
		"goal": "destroy_all",
		"text": "Видишь синий? Он крепкий. Как твоя уверенность после первого уровня.",
		"blocks": [
			{"type": "big", "pos": Vector2(180, 250)},
			{"type": "big", "pos": Vector2(540, 250)},
			{"type": "big", "pos": Vector2(180, 450)},
			{"type": "big", "pos": Vector2(540, 450)},
			{"type": "strong", "pos": Vector2(360, 600)}
		],
		"bonuses": [], "bonus_chance": 0.0
	},
	4: {
		"goal": "destroy_all",
		"text": "Четыре крепыша и один хлюпик. Найди хлюпика, если сможешь.",
		"blocks": [
			{"type": "block", "pos": Vector2(180, 250), "size": Vector2(160, 80), "hp": 2, "color": "3b82f6", "points": 20},
			{"type": "block", "pos": Vector2(540, 250), "size": Vector2(160, 80), "hp": 2, "color": "3b82f6", "points": 20},
			{"type": "block", "pos": Vector2(180, 450), "size": Vector2(160, 80), "hp": 2, "color": "3b82f6", "points": 20},
			{"type": "block", "pos": Vector2(540, 450), "size": Vector2(160, 80), "hp": 2, "color": "3b82f6", "points": 20},
			{"type": "block", "pos": Vector2(360, 350), "size": Vector2(40, 20), "hp": 1, "color": "fbbf24", "points": 10}
		],
		"bonuses": [], 
		"bonus_chance": 0.0
	},
	5: {
		"goal": "destroy_all",
		"text": "Впереди — красная штука. Она взорвется. Ты тоже, если не увернешься.",
		"blocks": [
			{"type": "explosive", "pos": Vector2(360, 450), "size": Vector2(600, 80)},
			{"type": "block", "pos": Vector2(110, 380), "size": Vector2(40, 20), "hp": 1, "color": "fbbf24"},
			{"type": "block", "pos": Vector2(150, 380), "size": Vector2(40, 20), "hp": 2, "color": "3b82f6"},
			{"type": "block", "pos": Vector2(190, 380), "size": Vector2(40, 20), "hp": 1, "color": "fbbf24"},
			{"type": "block", "pos": Vector2(230, 380), "size": Vector2(40, 20), "hp": 2, "color": "3b82f6"},
			{"type": "block", "pos": Vector2(270, 380), "size": Vector2(40, 20), "hp": 1, "color": "fbbf24"},
			{"type": "block", "pos": Vector2(310, 380), "size": Vector2(40, 20), "hp": 2, "color": "3b82f6"},
			{"type": "block", "pos": Vector2(350, 380), "size": Vector2(40, 20), "hp": 1, "color": "fbbf24"},
			{"type": "block", "pos": Vector2(390, 380), "size": Vector2(40, 20), "hp": 2, "color": "3b82f6"},
			{"type": "block", "pos": Vector2(430, 380), "size": Vector2(40, 20), "hp": 1, "color": "fbbf24"},
			{"type": "block", "pos": Vector2(470, 380), "size": Vector2(40, 20), "hp": 2, "color": "3b82f6"},
			{"type": "block", "pos": Vector2(510, 380), "size": Vector2(40, 20), "hp": 1, "color": "fbbf24"},
			{"type": "block", "pos": Vector2(550, 380), "size": Vector2(40, 20), "hp": 2, "color": "3b82f6"},
			{"type": "block", "pos": Vector2(590, 380), "size": Vector2(40, 20), "hp": 1, "color": "fbbf24"}
		],
		"bonuses": ["grow"], 
		"bonus_chance": 0.0, 
		"guaranteed_bonus": "grow",
		"guaranteed_at": 11
	},
	6: {
		"goal": "destroy_all",
		"text": "Ого, тут есть взрывные блоки. Не подорвись!",
		"blocks": [], # <-- Пусто! Блоки сгенерируются в game.gd
		"use_generator": true, # <-- Флаг для game.gd
		"bonuses": ["grow"],
		"bonus_chance": 0.10
	},
	7: {
		"goal": "destroy_target",
		"text": "Глаза. Мне нужны его глаза. Уничтожь только их.",
		"blocks": [
			# ВЕРХ (y=150)
			{"type": "block", "pos": Vector2(200, 150), "size": Vector2(40, 40), "hp": 4, "color": "3b82f6"},
			{"type": "block", "pos": Vector2(250, 150), "size": Vector2(40, 40), "hp": 4, "color": "3b82f6"},
			{"type": "block", "pos": Vector2(300, 150), "size": Vector2(40, 40), "hp": 4, "color": "3b82f6"},
			{"type": "block", "pos": Vector2(350, 150), "size": Vector2(40, 40), "hp": 4, "color": "3b82f6"},
			{"type": "block", "pos": Vector2(400, 150), "size": Vector2(40, 40), "hp": 4, "color": "3b82f6"},
			{"type": "block", "pos": Vector2(450, 150), "size": Vector2(40, 40), "hp": 4, "color": "3b82f6"},
			{"type": "block", "pos": Vector2(500, 150), "size": Vector2(40, 40), "hp": 4, "color": "3b82f6"},
			
			# БОКА (y=200-400)
			{"type": "block", "pos": Vector2(150, 200), "size": Vector2(40, 40), "hp": 4, "color": "3b82f6"},
			{"type": "block", "pos": Vector2(550, 200), "size": Vector2(40, 40), "hp": 4, "color": "3b82f6"},
			{"type": "block", "pos": Vector2(150, 250), "size": Vector2(40, 40), "hp": 4, "color": "3b82f6"},
			{"type": "block", "pos": Vector2(550, 250), "size": Vector2(40, 40), "hp": 4, "color": "3b82f6"},
			{"type": "block", "pos": Vector2(150, 300), "size": Vector2(40, 40), "hp": 4, "color": "3b82f6"},
			{"type": "block", "pos": Vector2(550, 300), "size": Vector2(40, 40), "hp": 4, "color": "3b82f6"},
			{"type": "block", "pos": Vector2(150, 350), "size": Vector2(40, 40), "hp": 4, "color": "3b82f6"},
			{"type": "block", "pos": Vector2(550, 350), "size": Vector2(40, 40), "hp": 4, "color": "3b82f6"},
			
			# ГЛАЗА (цели, 60x60, в центре)
			{"type": "target", "pos": Vector2(280, 250), "size": Vector2(60, 60)},
			{"type": "target", "pos": Vector2(440, 250), "size": Vector2(60, 60)},
			
			# НОС (y=300-350)
			{"type": "block", "pos": Vector2(360, 300), "size": Vector2(40, 40), "hp": 4, "color": "3b82f6"},
			{"type": "block", "pos": Vector2(360, 350), "size": Vector2(40, 40), "hp": 4, "color": "3b82f6"},
			
			# СКУЛЫ (y=400)
			{"type": "block", "pos": Vector2(200, 400), "size": Vector2(40, 40), "hp": 4, "color": "3b82f6"},
			{"type": "block", "pos": Vector2(500, 400), "size": Vector2(40, 40), "hp": 4, "color": "3b82f6"},
			
			# ЗУБЫ (y=400-500)
			{"type": "block", "pos": Vector2(250, 400), "size": Vector2(40, 40), "hp": 4, "color": "3b82f6"},
			{"type": "block", "pos": Vector2(300, 400), "size": Vector2(40, 40), "hp": 4, "color": "3b82f6"},
			{"type": "block", "pos": Vector2(350, 400), "size": Vector2(40, 40), "hp": 4, "color": "3b82f6"},
			{"type": "block", "pos": Vector2(400, 400), "size": Vector2(40, 40), "hp": 4, "color": "3b82f6"},
			{"type": "block", "pos": Vector2(450, 400), "size": Vector2(40, 40), "hp": 4, "color": "3b82f6"},
			
			{"type": "block", "pos": Vector2(250, 450), "size": Vector2(40, 40), "hp": 4, "color": "3b82f6"},
			{"type": "block", "pos": Vector2(300, 450), "size": Vector2(40, 40), "hp": 4, "color": "3b82f6"},
			{"type": "block", "pos": Vector2(350, 450), "size": Vector2(40, 40), "hp": 4, "color": "3b82f6"},
			{"type": "block", "pos": Vector2(400, 450), "size": Vector2(40, 40), "hp": 4, "color": "3b82f6"},
			{"type": "block", "pos": Vector2(450, 450), "size": Vector2(40, 40), "hp": 4, "color": "3b82f6"},
			
			# ЧЕЛЮСТЬ (y=500)
			{"type": "block", "pos": Vector2(300, 500), "size": Vector2(40, 40), "hp": 4, "color": "3b82f6"},
			{"type": "block", "pos": Vector2(350, 500), "size": Vector2(40, 40), "hp": 4, "color": "3b82f6"},
			{"type": "block", "pos": Vector2(400, 500), "size": Vector2(40, 40), "hp": 4, "color": "3b82f6"}
		],
		"bonuses": [], 
		"bonus_chance": 0.0
	},	
}

# Функция генерации (вызывается из game.gd)
func generate_grid_blocks() -> Array:
	var blocks = []
	var cols = 12
	var rows = 6
	var block_width = 40
	var block_height = 20
	var gap_x = 18
	var gap_y = 8
	var total_width = cols * block_width + (cols - 1) * gap_x
	var start_x = (720 - total_width) / 2 + block_width / 2
	var start_y = 150
	var row_height = block_height + gap_y
	
	for row in range(rows):
		for col in range(cols):
			# Взрывной каждый третий блок
			var b_type = "explosive" if (row + col) % 4 == 0 else "block"
			
			var data = {
				"type": b_type,
				"pos": Vector2(start_x + col * (block_width + gap_x), start_y + row * row_height),
				"size": Vector2(40, 20),
				"color": "fbbf24" if b_type == "block" else "ef4444"
			}
			
			# Прочность только для обычных блоков
			if b_type == "block":
				data["hp"] = 1
				data["points"] = 10
				
			blocks.append(data)
	return blocks
