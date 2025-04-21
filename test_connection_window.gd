extends Node2D

var regex = RegEx.new()
var connectionWindowEnabled = true

@onready var senderNumInput = $sender_num_input
@onready var receiverNumInput = $receiver_num_input
@onready var connectionWindow = $test_connection_window
@onready var outputLabel= $output_label

signal checkConnectionBetween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_check_button_pressed() -> void:
	var senderNum = senderNumInput.value
	var receiverNum = receiverNumInput.value
	
	print("Sending Host #: ", senderNum)
	print("Recieving Host #: ", receiverNum)
	checkConnectionBetween.emit(senderNum, receiverNum)


func _on_toggle_button_pressed() -> void:
	if connectionWindowEnabled:
		connectionWindowEnabled = false
		self.move_local_y(-100)
		outputLabel.set_text("")
	else:
		connectionWindowEnabled = true
		self.move_local_y(100)


func _on_sender_num_input_value_changed(value: float) -> void:
	outputLabel.set_text("")


func _on_receiver_num_input_value_changed(value: float) -> void:
	outputLabel.set_text("")
