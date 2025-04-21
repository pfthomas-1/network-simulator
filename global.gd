extends Node2D

var isMouseBusy = false;
var isRouteFound = false;
var checkedComponents = [] # when a component asks connected devices if they're connected to the reciever, it will ignore devices in this array

var limit = 4
@onready var count = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# print1 and print2 were used to brainstorm searching for a route

func print1():
	print(count, "A")
	print2()

func print2():
	print(count, "B")
	count += 1
	if count < limit:
		print1()
	else:
		return
