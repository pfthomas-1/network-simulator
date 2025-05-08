extends Node2D

var plug1Selected = false
var plug2Selected = false
var rotationOffset = 90

var number = 0

var plug1Connected = false
var plug2Connected = false

var p1obj = "None";
var p2obj = "None";

var mouse_offset = Vector2(0, 0)
var plug1Offset = Vector2(0, 0)
var plug2Offset = Vector2(0, 0)

var touchingTrashCan = false

signal cableTouchingMouse
signal cableNotTouchingMouse
signal cableDeleted
signal cableSelected # used to tell connected devices to update connection tables

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$cableCord.set_point_position(0, $plug1.position)
	$cableCord.set_point_position(1, $plug2.position)
	p1LookAway()
	p2LookAway()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if plug1Selected:
		plug1FollowMouse()
	elif plug1Connected and is_instance_valid(p1obj):
		$plug1.look_at(p1obj.global_position)
		$plug1.rotate(PI/2)
		plug1FollowConnection()
	
	if plug2Selected:
		plug2FollowMouse()
	elif plug2Connected  and is_instance_valid(p2obj):
		$plug2.look_at(p2obj.global_position)
		$plug2.rotate(PI/2)
		plug2FollowConnection()	
	
	if !is_instance_valid(p1obj): # handles disconnecting cable from a component that gets deleted
		p1obj = "None"
		plug1Connected = false
		updateP2ObjConnections() 
	
	if !is_instance_valid(p2obj): # handles disconnecting cable from a component that gets deleted
		p2obj = "None"
		plug2Connected = false
		updateP1ObjConnections()
	
	if touchingTrashCan and (!plug1Selected and !plug2Selected) and (!plug1Connected and !plug2Connected):
		delete()


func plug1FollowMouse():
	$plug1.position = get_global_mouse_position() + mouse_offset
	p1LookAway()
	if !plug2Connected:
		p2LookAway()
	$cableCord.set_point_position(0, $plug1.position)


func plug2FollowMouse():
	$plug2.position = get_global_mouse_position() + mouse_offset
	p2LookAway()
	if !plug1Connected:
		p1LookAway()
	$cableCord.set_point_position(1, $plug2.position)


func plug1FollowConnection():
	$plug1.position = p1obj.global_position + plug1Offset
	$cableCord.set_point_position(0, $plug1.position)


func plug2FollowConnection():
	$plug2.position = p2obj.global_position + plug2Offset
	$cableCord.set_point_position(1, $plug2.position)


func p1LookAway():
	$plug1.look_at($plug2.global_position)
	$plug1.rotate(3 * PI / 2)

func p2LookAway():
	$plug2.look_at($plug1.global_position)
	$plug2.rotate(3 * PI / 2)

func _on_plug_1_area_2d_area_entered(area: Area2D) -> void:
	if (area.is_in_group("hosts") or area.is_in_group("routers")) and plug1Selected and str(area.owner) != str(p2obj):
		if area.owner.canConnect or area.owner.connectedCableNames.find(name) != -1:
			p1obj = area.owner
			plug1Offset = $plug1.position - area.get_global_position()
			plug1Connected = true
			cableTouchingMouse.emit(name, p1obj, p2obj)
			updateP2ObjConnections()
	elif area.is_in_group("trashcan"):
		touchingTrashCan = true


func _on_plug_1_area_2d_area_exited(area: Area2D) -> void:
	if (area.is_in_group("hosts") or area.is_in_group("routers")) and plug1Selected:
		plug1Connected = false
		p1obj = "None"
		cableTouchingMouse.emit(name, p1obj, p2obj)
		updateP2ObjConnections()
	elif area.is_in_group("trashcan"):
		touchingTrashCan = false


func _on_plug_1_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and Global.isMouseBusy == false:
			mouse_offset = $plug1.position - get_global_mouse_position()
			plug1Selected = true
			Global.isMouseBusy = true
			cableTouchingMouse.emit(name, p1obj, p2obj)
		else:
			plug1Selected = false
			Global.isMouseBusy = false


func _on_plug_2_area_2d_area_entered(area: Area2D) -> void:
	if (area.is_in_group("hosts") or area.is_in_group("routers")) and plug2Selected and str(area.owner) != str(p1obj):
		if area.owner.canConnect or area.owner.connectedCableNames.find(name) != -1:
			p2obj = area.owner
			plug2Offset = $plug2.position - area.get_global_position()
			plug2Connected = true
			cableTouchingMouse.emit(name, p1obj, p2obj)
			updateP1ObjConnections()
	elif area.is_in_group("trashcan"):
		touchingTrashCan = true


func _on_plug_2_area_2d_area_exited(area: Area2D) -> void:
	if (area.is_in_group("hosts") or area.is_in_group("routers")) and plug2Selected:
		plug2Connected = false
		p2obj = "None"
		cableTouchingMouse.emit(name, p1obj, p2obj)
		updateP1ObjConnections()
	elif area.is_in_group("trashcan"):
		touchingTrashCan = false


func _on_plug_2_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and Global.isMouseBusy == false:
			mouse_offset = $plug2.position - get_global_mouse_position()
			plug2Selected = true
			Global.isMouseBusy = true;
			cableTouchingMouse.emit(name, p1obj, p2obj)
		else:
			plug2Selected = false
			Global.isMouseBusy = false;


func _on_plug_1_area_2d_mouse_entered() -> void:
	if !Global.isMouseBusy:
		cableTouchingMouse.emit(name, p1obj, p2obj)


func _on_plug_2_area_2d_mouse_entered() -> void:
	if !Global.isMouseBusy:
		cableTouchingMouse.emit(name, p1obj, p2obj)


func _on_plug_1_area_2d_mouse_exited() -> void:
	if !Global.isMouseBusy:
		cableNotTouchingMouse.emit(name)


func _on_plug_2_area_2d_mouse_exited() -> void:
	if !Global.isMouseBusy:
		cableNotTouchingMouse.emit(name)


func delete():
	cableNotTouchingMouse.emit(name)
	cableDeleted.emit(number)
	print(name, " thrown away")
	queue_free()

func updateP1ObjConnections():
	if typeof(p1obj) != 4:
		if is_instance_valid(p1obj):
			p1obj.getOtherEnds()

func updateP2ObjConnections():	
	if typeof(p2obj) != 4:
		if is_instance_valid(p2obj):
			p2obj.getOtherEnds()
