extends Node2D

signal clearWorkspace # will be emmitted when a button in the escape menu is clicked, used to delete all objects in play

@onready var escMenu = $escMenu
@onready var quitConfirm = $escMenu/confirmQuitPopup

@onready var infoPage = $info_page
@onready var nameLabel = $info_page/name_label
@onready var infoLabel = $info_page/info_label

var showInfo = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hideEscMenu()
	nameLabel.set_text("Select a Component")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		if escMenu.visible:
			hideEscMenu()
		else:
			showEscMenu()


func _on_quit_button_pressed() -> void:
	quitConfirm.visible = true


func showEscMenu() -> void:
	escMenu.visible = true
	quitConfirm.visible = false


func hideEscMenu() -> void:
	escMenu.visible = false
	quitConfirm.visible = false


func _on_yes_quit_button_pressed() -> void:
	get_tree().quit()


func _on_no_quit_button_pressed() -> void:
	quitConfirm.visible = false


func _on_clear_button_pressed() -> void:
	clearWorkspace.emit()


func updateInfoBoxWithCable(name, p1obj, p2obj):
	nameLabel.set_text("Name: " + name)
	var info = ""
	
	if typeof(p1obj) == 4: # if p1obj datatype is String
		info += "Plug 1 Connection: " + p1obj + "\n"
	else:
		info += "Plug 1 Connection: " + p1obj.name + "\n"
	
	if typeof(p2obj) == 4: # if p1obj datatype is String
		info += "Plug 2 Connection: " + p2obj + "\n"
	else:
		info += "Plug 2 Connection: " + p2obj.name + "\n"
	
	infoLabel.set_text(info)


func updateInfoBoxWithComponent(name, connectedCables, connectedComponents):
	nameLabel.set_text("Name: " + name)
	var info = ""
	var numConnections = connectedCables.size()
	
	for i in range(0, numConnections): # Print info for the ports that are in use
		# First: assign variables
		var cableInSocket;
		var otherEnd = connectedCables[i]
		
		if typeof(connectedCables[i]) == 4: # if the slot is empty
			cableInSocket = "None"
		else:
			cableInSocket = connectedCables[i].name
		
		if typeof(otherEnd) != 4 and typeof(connectedComponents[i]) != 4: # if plug 1 is connected and the other end isn't empty
			otherEnd = connectedComponents[i].name
		else:
			otherEnd = "None"
		
		info += "Port " + str(i+1) + ": " + cableInSocket + " --> " + str(otherEnd) + "\n"
	
	infoLabel.set_text(info)


func clearInfoBox(name):
	if nameLabel.text == "Name: " + name:
		nameLabel.set_text("Select a Component")
		infoLabel.set_text("")


func _on_toggle_button_pressed() -> void:
	if showInfo:
		infoPage.move_local_y(200)
		showInfo = false
	else:
		infoPage.move_local_y(-200)
		showInfo = true
