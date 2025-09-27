extends RigidFPSController3D
class_name GrabberPlayerRigidbody

## Example script that extends [CharacterController3D] through 
## [FPSController3D].
## 
## This is just an example, and should be used as a basis for creating your 
## own version using the controller's [b]move()[/b] function.
## 
## This player contains the inputs that will be used in the function 
## [b]move()[/b] in [b]_physics_process()[/b].
## The input process only happens when mouse is in capture mode.
## This script also adds submerged and emerged signals to change the 
## [Environment] when we are in the water.

@export var input_back_action_name := "move_backward"
@export var input_forward_action_name := "move_forward"
@export var input_left_action_name := "move_left"
@export var input_right_action_name := "move_right"
@export var input_sprint_action_name := "move_sprint"
@export var input_jump_action_name := "move_jump"
@export var input_crouch_action_name := "move_crouch"
@export var input_fly_mode_action_name := "move_fly_mode"
@export var leftHandJoint: Joint3D
@export var leftHandRay: ShapeCast3D
@export var rightHandJoint: Joint3D
@export var rightHandRay: ShapeCast3D
@export var pushForce: float = 50

@export var underwater_env: Environment


func _ready():
	super._ready()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	setup()
	#emerged.connect(_on_controller_emerged.bind())
	#submerged.connect(_on_controller_subemerged.bind())


func _physics_process(delta):
	var is_valid_input := Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	
	# for i: int in get_slide_collision_count():
	# 	var c: KinematicCollision3D = get_slide_collision(i)
	# 	if c.get_collider() is RigidBody3D:
	# 		c.get_collider().apply_central_impulse(-c.get_normal() * pushForce)
	
	var input_dir: Vector2 = Input.get_vector(inputLeft, inputRight, inputForward, inputBackward)
	var direction: Vector3 = (smoothBody.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()

	if is_valid_input:
		if Input.is_action_just_pressed(input_fly_mode_action_name):
			fly_ability.set_active(not fly_ability.is_actived())
		var input_axis = Input.get_vector(input_left_action_name, input_right_action_name, input_back_action_name, input_forward_action_name)
		var input_jump = Input.is_action_just_pressed(input_jump_action_name)
		var input_crouch = Input.is_action_pressed(input_crouch_action_name)
		var input_sprint = Input.is_action_pressed(input_sprint_action_name)
		var input_swim_down = Input.is_action_pressed(input_crouch_action_name)
		var input_swim_up = Input.is_action_pressed(input_jump_action_name)
		#var direction2: Vector3 = (smoothBody.basis * Vector3(input_axis.x, 0.0, input_axis.y)).normalized()
		#move_and_slide()
		move(delta, input_axis, input_jump, input_crouch, input_sprint, input_swim_down, input_swim_up)
	else:
		# NOTE: It is important to always call move() even if we have no inputs 
		## to process, as we still need to calculate gravity and collisions.
		#move_and_slide()
		move(delta)
	
	if Input.is_action_just_released("LeftClick"):
		print("left go with left hand")
		leftHandJoint.node_a = leftHandJoint.get_path()
		leftHandJoint.node_b = leftHandJoint.get_path()
	if Input.is_action_just_released("RightClick"):
		print("left go with right hand")
		rightHandJoint.node_a = rightHandJoint.get_path()
		rightHandJoint.node_b = rightHandJoint.get_path()
	
	
	
	linear_damp = 0.1
	
	if direction or _wants_to_jump:
		if is_on_floor():
			acceleration_magnitude = 15.0
		else:
			acceleration_magnitude = 9.8
		#target_velocity.x = SPEED * direction.x
		#target_velocity.z = SPEED * direction.z
	else:
		if is_on_floor():
			linear_damp = 20.0
		target_velocity.x = 0.0
		target_velocity.z = 0.0
	#move_and_slide()

var bGrabbing: bool = false
var objectGrabbedLeft: RigidBody3D
var objectGrabbedRight: RigidBody3D
var shapeCastColliderObject: Object
func _input(event: InputEvent) -> void:
	_wants_to_jump = false
	# Mouse look (only if the mouse is captured).
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_head(event.screen_relative)
	
	if event.is_action_pressed(inputJump) and is_on_floor():
		_wants_to_jump = true
		#var velocity: float = sqrt(2.0 * get_gravity().length() * JUMP_HEIGHT)
		#apply_central_impulse(mass * velocity * up_direction)
	else:
		_wants_to_jump = false

		
	if event.is_action("LeftClick"):
		if (leftHandRay.is_colliding()):
			shapeCastColliderObject = leftHandRay.get_collider(0)
			print("grabbed collider: %s" % shapeCastColliderObject)
			leftHandJoint.node_a = self.get_path()
			if (shapeCastColliderObject is RigidBody3D):
				leftHandJoint.node_b = shapeCastColliderObject.get_path()
				objectGrabbedLeft = shapeCastColliderObject
				bGrabbing = true
			elif (shapeCastColliderObject.get_parent() is RigidBody3D):
				leftHandJoint.node_b = shapeCastColliderObject.get_parent().get_path()
				objectGrabbedLeft = shapeCastColliderObject.get_parent()
				bGrabbing = true
					
	
	if event.is_action("RightClick"):
		if (rightHandRay.is_colliding()):
			shapeCastColliderObject = rightHandRay.get_collider(0)
			print("grabbed collider: %s" % shapeCastColliderObject)
			rightHandJoint.node_a = self.get_path()
			if (shapeCastColliderObject is RigidBody3D):
				rightHandJoint.node_b = shapeCastColliderObject.get_path()
				objectGrabbedRight = shapeCastColliderObject
				bGrabbing = true
			elif (shapeCastColliderObject.get_parent() is RigidBody3D):
				rightHandJoint.node_b = shapeCastColliderObject.get_parent().get_path()
				objectGrabbedRight = shapeCastColliderObject.get_parent()
				bGrabbing = true
	

#func _on_controller_emerged():
	#camera.environment = null
#
#
#func _on_controller_subemerged():
	#camera.environment = underwater_env

func modify_move_force(move_force: Vector3) -> Vector3:
	var horizontal_velocity: Vector3 = Vector3(linear_velocity.x, 0.0, linear_velocity.z)
	var x_offset: float = ((horizontal_velocity.x * basis.x)).normalized().dot(
			(target_velocity.x * basis.x).normalized())
	var z_offset: float =((horizontal_velocity.z * basis.z)).normalized().dot(
			(target_velocity.z * basis.z).normalized())
	
	if x_offset < 0.0:
		move_force.x *= ACCELRATION_CURVE.sample(x_offset)
	if z_offset < 0.0:
		move_force.z *= ACCELRATION_CURVE.sample(z_offset)
	
	return move_force
