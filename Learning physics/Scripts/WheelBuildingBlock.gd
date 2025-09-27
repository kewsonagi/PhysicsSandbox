extends FunctionalBuildingBlock
class_name WheelBuildingBlock

@export var physicalParent: RigidBody3D
@export var model: Node3D
@export var speed: float = 10
@export var turnSpeed: float = 30
@export var maxTurnAngle: float = 70
@export var groundCheck: RayCast3D
var wheelRot: float = 0

func _ready() -> void:
	pass

func EnteredControlUnit(b: BuildingBlock) -> void:
	b.Forward.connect(ForwardInput)
	b.Backward.connect(BackwardInput)
	b.Left.connect(LeftInput)
	b.Right.connect(RightInput)
	b.Jump.connect(JumpInput)
	groundCheck.enabled = true
	
func ExitControlUnit(b: BuildingBlock) -> void:
	b.Forward.disconnect(ForwardInput)
	b.Backward.disconnect(BackwardInput)
	b.Left.disconnect(LeftInput)
	b.Right.disconnect(RightInput)
	b.Jump.disconnect(JumpInput)
	groundCheck.enabled = false


func ForwardInput(delta: float) -> void:
	if(groundCheck.is_colliding()):
		physicalParent.apply_force(-physicalParent.global_transform.basis.z*(wheelRot/360)*speed*delta)
	physicalParent.apply_force(-physicalParent.global_transform.basis.z*(wheelRot/360)*speed*delta)
	model.rotation_degrees.z += speed*delta
func BackwardInput(delta: float) -> void:
	if(groundCheck.is_colliding()):
		physicalParent.apply_force(physicalParent.global_transform.basis.z*(wheelRot/360)*speed*delta)
	physicalParent.apply_force(physicalParent.global_transform.basis.z*(wheelRot/360)*speed*delta)
	model.rotation_degrees.z -= speed*delta
func LeftInput(delta: float) -> void:
	wheelRot-=turnSpeed*delta
	if(wheelRot<-maxTurnAngle):
		wheelRot = -maxTurnAngle
	physicalParent.rotation_degrees.y = wheelRot
	#physicalParent.apply_force(Vector3.LEFT*speed*delta)

func RightInput(delta: float) -> void:
	wheelRot+=turnSpeed*delta
	if(wheelRot>maxTurnAngle):
		wheelRot = maxTurnAngle
	physicalParent.rotation_degrees.y = wheelRot
	#physicalParent.apply_force(Vector3.RIGHT*speed*delta)
func JumpInput(delta: float) -> void:
	physicalParent.apply_force(Vector3.UP*speed*delta)
