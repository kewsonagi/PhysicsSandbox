extends CharacterBody3D
class_name PlayerPhysicsTest

@export var animBody: AnimationPlayer
@export var grabberRay: RayCast3D
@export var ball: PackedScene
@export var moveSpeed: float = 1
@export var playerCamera: Camera3D
@export var mouseSensitivity: float = 0.5
var camAngle: float = 0


func _ready() -> void:
	pass

func _process(delta: float) -> void:
	var velocity_floor: Vector2 = moveSpeed * Input.get_vector("Left", "Right", "w", "s")
	velocity = Vector3(velocity_floor.x, velocity.y - 9.81 * delta, velocity_floor.y)
	move_and_slide()
	pass

func _unhandled_input(event: InputEvent) -> void:
	if (event.is_action_pressed(&"Jump") or event.is_action(&"Jump")):
		#animBody.play("Jump_Move")
		animBody.play("Jump_Move")
	
	# if (event is InputEventMouseMotion):
	# 	playerCamera.rotate_y(Camera3D.deg2rad(-event.relative.x * mouseSensitivity))

	# 	# Rotate vertically (pitch) with clamping
	# 	var pitch_change: float = -event.relative.y * mouseSensitivity
	# 	if (camAngle + pitch_change > -50 and camAngle + pitch_change < 50):
	# 		camAngle += pitch_change
	# 		playerCamera.rotate_x(Camera3D.deg2rad(pitch_change))
	# 	pass
	pass


func LeftClicked() -> void:
	var toss: RigidBody3D = ball.instantiate()
	if (toss):
		toss.position = self.position
	pass

func RightClicked() -> void:
	pass
