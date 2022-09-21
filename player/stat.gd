extends BoxContainer

class_name Stat

var stat : int = 100

func add(value: int):
	stat += value
	update_ui()

func update_ui():
	$Count.text = str(stat)
