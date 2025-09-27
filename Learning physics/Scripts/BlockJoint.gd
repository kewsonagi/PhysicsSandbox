extends RigidBody3D
class_name BlockJoint

@export var joint:Joint3D
@export var ourCollider: CollisionShape3D
@export var connectorCheckShape: ShapeCast3D
@export var bOpen: bool = true
var parentJoint: Generic6DOFJoint3D

var locPos: Vector3
var locRot: Vector3

var closestConnection: BlockJoint

func _ready() -> void:
	# parentJoint = Generic6DOFJoint3D.new()
	# parentJoint.node_a = self.get_path()
	# parentJoint.node_b = get_parent().get_path()
	self.mass = 0.1
	locPos = position
	locRot = rotation
	self.collision_layer = 256
	self.collision_mask = 0
	connectorCheckShape.collision_mask = 256
	#if(joint.node_b):
	#	bOpen = false
	Deactivate()

func _process(delta: float) -> void:
	position = locPos
	rotation = locRot

func Activate() -> void:
	if(bOpen):
		connectorCheckShape.enabled = true
func Deactivate() -> void:
	if(bOpen):
		connectorCheckShape.enabled = false
