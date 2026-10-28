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
			{"type": "strong", "pos": Vector2(180, 250)},
			{"type": "strong", "pos": Vector2(540, 250)},
			{"type": "strong", "pos": Vector2(180, 450)},
			{"type": "strong", "pos": Vector2(540, 450)},
			{"type": "normal", "pos": Vector2(360, 350)}
		],
		"bonuses": [], "bonus_chance": 0.0
	},
	5: {
		"goal": "destroy_all",
		"text": "Впереди — красная штука. Она взорвется. Ты тоже, если не увернешься.",
		"blocks": [
			{"type": "explosive", "pos": Vector2(360, 200)},
			{"type": "normal", "pos": Vector2(180, 350)},
			{"type": "strong", "pos": Vector2(360, 350)},
			{"type": "normal", "pos": Vector2(540, 350)},
			{"type": "explosive", "pos": Vector2(180, 500)},
			{"type": "normal", "pos": Vector2(360, 500)},
			{"type": "strong", "pos": Vector2(540, 500)}
		],
		"bonuses": ["grow"], 
		"bonus_chance": 0.0, 
		"guaranteed_bonus": "grow" # <-- Гарантированный бонус на 5 уровне
	}
}
