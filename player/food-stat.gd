extends Stat

class_name FoodStat

signal food_change

func _on_timer_timeout():
	add(-1)
