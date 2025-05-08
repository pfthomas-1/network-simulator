extends Node2D

var hostCount = 0;
var cableCount = 0;
var routerCount = 0;
var maxCount = 100;
var hostNumArray = [0]
var cableNumArray = [0]
var routerNumArray = [0]

var red = Color(1,0,0)
var green = Color(0,1,0)

@export var component_node: PackedScene
@export var cable_node: PackedScene

@onready var spawnArea = $Area2D/CollisionShape2D.get_shape().size
@onready var origin = $Area2D/CollisionShape2D.global_position - spawnArea
@onready var rect = $Area2D/CollisionShape2D.shape.get_rect()

@onready var topLeftCornerPos = $Area2D/TopLeftMarker.global_position
@onready var bottomRightCornerPos = $Area2D/BottomRightMarker.global_position

@onready var hud = $HUD
@onready var connectionTester = $test_connection_window

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hud.clearWorkspace.connect(deleteAll)
	connectionTester.checkConnectionBetween.connect(findRoute)


func get_random_pos():
	var x = randi_range(topLeftCornerPos.x, bottomRightCornerPos.x)
	var y = randi_range(topLeftCornerPos.y, bottomRightCornerPos.y)
	
	return Vector2(x, y)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$hostButton/hostCountLabel.set_text(str(get_tree().get_nodes_in_group("hosts").size()))
	$cableButton/cableCountLabel.set_text(str(get_tree().get_nodes_in_group("cables").size()))
	$routerButton/routerCountLabel.set_text(str(get_tree().get_nodes_in_group("routers").size()))


func _on_hostButton_pressed() -> void:
	if !get_tree().get_nodes_in_group("hosts").size() < maxCount:
		return
	
	var host = component_node.instantiate() # create component instance
	
	for i in range(1, hostNumArray.size() + 1): # find a number that's not in the array of host numbers
			if hostNumArray.find(i) == -1:
				host.number = i # assign the instance the first number found
				hostNumArray.append(i) # ...and add that number to the array
				break
	
	host.name = "Host " + str(host.number) # create host's name
	host.maxConnections = 3
	host.position = get_random_pos() # place the host in a random spot on the screen
	host.get_child(0).get_child(0).add_to_group("hosts") # first get_child(0) is Sprite2D, the second is Area2D, which is what we want to add to the group
	add_child(host)
	
	var sprite = host.get_child(0)
	
	sprite.texture = load("res://sprites/Host.png")
	sprite.scale = Vector2(2.75,2.75)
	sprite.get_child(0).scale = Vector2(.4,.4)
	
	host.componentTouchingMouse.connect(printComponentInfo)
	host.componentNotTouchingMouse.connect(clearInfoBox)
	host.componentDeleted.connect(removeHost) # Allows  removeHost(number) to remove a number from the array when the host of that number is deleted
	hostCount = get_tree().get_nodes_in_group("hosts").size() # update host count


func _on_cable_button_pressed() -> void:
	if !get_tree().get_nodes_in_group("cables").size() < maxCount:
		return
	
	var cable = cable_node.instantiate() # create a cable instance
	
	for i in range(1, cableNumArray.size() + 1):
		if cableNumArray.find(i) == -1:
			cable.number = i
			cableNumArray.append(i)
			break
	
	cable.name = "Cable " + str(cable.number)
	
	cable.position = get_random_pos() # give it a random coordinate
	add_child(cable)
	
	cable.cableTouchingMouse.connect(printCableInfo)
	cable.cableNotTouchingMouse.connect(clearInfoBox)
	cable.cableDeleted.connect(removeCable)
	cableCount = get_tree().get_nodes_in_group("cables").size() # update cableCount


func _on_router_button_pressed() -> void:
	if !get_tree().get_nodes_in_group("routers").size() < maxCount:
		return
	
	var router = component_node.instantiate() # create component instance
	
	for i in range(1, routerNumArray.size() + 1): # find a number that's not in the array of component numbers
			if routerNumArray.find(i) == -1:
				router.number = i # assign the instance the first number found
				routerNumArray.append(i) # ...and add that number to the array
				break
	
	router.name = "Router " + str(router.number) # create component's name
	router.maxConnections = 6
	router.position = get_random_pos() # place the component in a random spot on the screen
	router.get_child(0).get_child(0).add_to_group("routers") # first get_child(0) is Sprite2D, the second is Area2D, which is what we want to add to the group
	
	var sprite = router.get_child(0)
	
	sprite.texture = load("res://sprites/Router.png")
	sprite.scale = Vector2(1,1)
	sprite.get_child(0).scale = Vector2(.8,.8)
	add_child(router)
	
	router.componentTouchingMouse.connect(printComponentInfo)
	router.componentNotTouchingMouse.connect(clearInfoBox)
	router.componentDeleted.connect(removeRouter) # Allows  removeComponent(number) to remove a number from the array when the component of that number is deleted
	routerCount = get_tree().get_nodes_in_group("routers").size() # update component count


func removeHost(number): # remove component #number from array
	var index = hostNumArray.find(number) 
	hostNumArray.remove_at(index)

func removeCable(number):
	var index = cableNumArray.find(number)
	cableNumArray.remove_at(index)

func removeRouter(number):
	var index = routerNumArray.find(number) 
	routerNumArray.remove_at(index)

func printComponentInfo(name, connectedCables, connectedComponents):
	hud.updateInfoBoxWithComponent(name, connectedCables, connectedComponents)


func printCableInfo(name, p1obj, p2obj):
	hud.updateInfoBoxWithCable(name, p1obj, p2obj)


func clearInfoBox(name):
	hud.clearInfoBox(name)


func deleteAll():
	connectionTester.outputLabel.set_text("")
	
	for host in get_tree().get_nodes_in_group("hosts"):
		host.owner.queue_free()
	hostNumArray = [0]
	
	for cable in get_tree().get_nodes_in_group("cables"):
		cable.queue_free()
	cableNumArray = [0]
	
	for router in get_tree().get_nodes_in_group("routers"):
		router.owner.queue_free()
	routerNumArray = [0]

func isConnectionTestValid(senderNum, receiverNum):
	if hostNumArray.find(int(senderNum)) != -1 and hostNumArray.find(int(receiverNum)) != -1: # if both sender and receiver exist
		print("hosts ", senderNum, " and ", receiverNum, " exist")
		return true
	else:
		print("INVALID TEST! sender and/or receiver does not exist")
		return false

func findRoute(senderNum, recieverNum):
	Global.checkedComponents = [] # reset the array
	Global.isRouteFound = false;
	
	if !isConnectionTestValid(senderNum, recieverNum): # can't connect hosts that don't exist
		connectionTester.outputLabel.label_settings.font_color = red
		connectionTester.outputLabel.set_text("Invalid Input")
		return
	
	var senderName = "Host " + str(senderNum)
	var receiverName = "Host " + str(recieverNum)
	
	var sender = get_node(senderName)
	var receiver = get_node(receiverName)
	
	print("Sender: ", sender.name)
	print("Receiver: ", receiver.name)
	
	# 1. first, see if the sender and the receiver are the same
	if sender == receiver:
		print("Loopback - Sender is Receiver - Route Found")
		connectionTester.outputLabel.label_settings.font_color = green
		connectionTester.outputLabel.set_text("Route Found - Loopback")
		return
	
	# 2. check if the sender and receiver are connected to anything in the first place
	if !sender.checkForConnections() or !receiver.checkForConnections():
		print("No route found - Sender or Receiver has no connections")
		connectionTester.outputLabel.label_settings.font_color = red
		connectionTester.outputLabel.set_text("No Route Found")
		return
	
	# 3. if the sender isn't the receiver, check if the sender and reciever have any connections
	# 4. if not, ask every component the sender is connected to if they are the reciever
	# 5. if not, tell them to do the same
	# 6. repeat until a route is found or we run out of routes
	sender.checkTableFor(receiver)
	
	if Global.isRouteFound:
		print("Route Found")
		connectionTester.outputLabel.label_settings.font_color = green
		connectionTester.outputLabel.set_text("Route Found")
		return
	
	# 7. if no route is found, say something
	print("No route found!")
	connectionTester.outputLabel.label_settings.font_color = red
	connectionTester.outputLabel.set_text("No Route Found")
	return
