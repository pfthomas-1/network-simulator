extends Node2D

var selected = false
var number = 0
var mouse_offset = Vector2(0, 0)
var touchingTrashCan = false
var connectedCables = [] # keeps track of which cables are connected to this component
var connectedPlugs = [] # keeps track of which plugs cables are connected to
var connectedCableNames = [] # used for cables
var connectedComponents = [] # what each connected cable leads to
var canConnect = true
var maxConnections; # Assigned upon instantiation 3 for hosts, 6 for routers

signal componentTouchingMouse
signal componentNotTouchingMouse
signal componentDeleted

func _ready():
	$Sprite2D/Area2D.monitoring = true
	for i in range(0, maxConnections):
		connectedCables.append("None")
		connectedPlugs.append("None")
		connectedCableNames.append("None")
		connectedComponents.append("None")


func _process(delta: float) -> void:
	if selected:
		followMouse()
	elif touchingTrashCan:
		delete()


func followMouse():
	position = get_global_mouse_position() + mouse_offset


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and Global.isMouseBusy == false:
			mouse_offset = position - get_global_mouse_position()
			selected = true
			Global.isMouseBusy = true;
		else:
			selected = false
			Global.isMouseBusy = false;


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("trashcan"):
		touchingTrashCan = true
	elif area.owner.is_in_group("cables") and canConnect:
		var cable = area.owner
		if area.get_parent().name == "plug1" and area.owner.plug1Selected: # if plug1 of the cable was dragged onto this component
			if !connectedCables.has(cable): # and that cable is not already connected to this component
				fillPortWith(cable, "1")
				
		elif area.get_parent().name == "plug2" and area.owner.plug2Selected: # if plug2 of the cable was dragged onto this component
			if !connectedCables.has(cable): # and that cable is not already connected to this component
				fillPortWith(cable, "2")
		
		canConnect = checkPorts()
		getOtherEnds()


func _on_area_2d_area_exited(area: Area2D) -> void:
	if is_instance_valid(area.owner):
		if area.is_in_group("trashcan"):
			touchingTrashCan = false
		elif area.owner.is_in_group("cables"):
			var cable = area.owner
			if area.get_parent().name == "plug1" and area.owner.plug1Selected: # if plug1 of the cable was dragged off of this component
				if str(area.owner.p2obj) != name: # and plug2 isn't connected to this component
					if connectedCables.has(cable): # and that cable was connected to this component
						emptyPortOf(cable)
			elif area.get_parent().name == "plug2" and area.owner.plug2Selected: # if plug2 of the cable was dragged off of this component
				if str(area.owner.p1obj) != name: # and plug1 isn't connected to this component
					if connectedCables.has(cable): # and that cable was connected to this component
						emptyPortOf(cable)


func _on_area_2d_mouse_entered() -> void:
	if !Global.isMouseBusy:
		componentTouchingMouse.emit(name, connectedCables, connectedComponents)


func _on_area_2d_mouse_exited() -> void:
	if !Global.isMouseBusy:
		componentNotTouchingMouse.emit(name)


func emptyPortOf(element):
	var index = connectedCables.find(element)
	connectedCables[index] = "None"
	connectedPlugs[index] = "None"
	connectedCableNames[index] = "None"
	connectedComponents[index] = "None"
	canConnect = true


func fillPortWith(cable, plug):
	for i in range(0, connectedCables.size()):
		if typeof(connectedCables[i]) == 4: # upon finding a string 
			connectedCables[i] = cable
			connectedPlugs[i] = plug
			connectedCableNames[i] = cable.name
			break


func checkPorts() -> bool:
	for i in range(0, connectedCables.size()):
		if typeof(connectedCables[i]) == 4: # upon finding a string
			return true
	return false


func checkTableFor(receiver): # returns true if the receiver is in this components connectedComponents array
	Global.checkedComponents.append(self)
	
	if connectedComponents.find(receiver) != -1:
		Global.isRouteFound = true
		return true
	
	for device in connectedComponents:
		if Global.checkedComponents.find(device) != -1 or typeof(device) == 4: # skip checked components and Strings
			continue
		
		if Global.isRouteFound:
			break
		
		device.checkTableFor(receiver)


func checkForConnections() -> bool: # returns true upon finding something in the connectedComponents array that isn't a String
	for component in connectedComponents:
		if typeof(component) != 4: 
			return true
	
	return false


func getOtherEnds():
	for port in range(0, connectedCables.size()):
		var cable = connectedCables[port]
		
		if typeof(cable) == 4: # if there is a string (meaning nothing is connected to that port)...
			connectedPlugs[port] = "None"
			continue
		
		if connectedPlugs[port] == "1":
			connectedComponents[port] = cable.p2obj
		elif connectedPlugs[port] == "2":
			connectedComponents[port] = cable.p1obj


func delete():
	componentNotTouchingMouse.emit(name)
	print(name, " thrown away")
	componentDeleted.emit(number)
	queue_free()
