extends Node


func generate_countdown_numbers(card_count:int) -> Array:
	var large_numbers: Array = [25, 50, 75, 100]
	var small_numbers: Array = [1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10]
	var selected_numbers: Array = []
	
	# Randomly decide number of large numbers (0-4)
	var large_count: int = randi() % card_count
	
	# Select large numbers
	for i:int in range(large_count):
		selected_numbers.append(large_numbers[randi() % large_numbers.size()])
	
	# Fill remaining slots with small numbers
	for i:int in range(card_count - large_count):
		selected_numbers.append(small_numbers[randi() % small_numbers.size()])
	
	# Shuffle the final selection
	selected_numbers.shuffle()
	
	return selected_numbers
