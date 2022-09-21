extends BoxContainer

signal food_change
var food = 100


func _on_timer_timeout():
	food -= 1
	$Count.text = str(food)
	emit_signal("food_change")
