extends FPSController3D
class_name GrabberPlayer

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
@export var characterShadow: RigidBody3D
@export var leftHandJoint: Joint3D
@export var leftHandRay: ShapeCast3D
@export var rightHandJoint: Joint3D
@export var rightHandRay: ShapeCast3D
@export var pushForce: float = 50
@export var constructionContainerNode: Node3D

@export var underwater_env: Environment


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	setup()
	#emerged.connect(_on_controller_emerged.bind())
	#submerged.connect(_on_controller_subemerged.bind())

var bSyncWithShadow: bool = false
func _physics_process(delta):
	var is_valid_input := Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	
	ProcessPlayerShadow()

	if is_valid_input:
		if Input.is_action_just_pressed(input_fly_mode_action_name):
			fly_ability.set_active(not fly_ability.is_actived())
		var input_axis = Input.get_vector(input_left_action_name, input_right_action_name, input_back_action_name, input_forward_action_name)
		var input_jump = Input.is_action_just_pressed(input_jump_action_name)
		var input_crouch = Input.is_action_pressed(input_crouch_action_name)
		var input_sprint = Input.is_action_pressed(input_sprint_action_name)
		var input_swim_down = Input.is_action_pressed(input_crouch_action_name)
		var input_swim_up = Input.is_action_pressed(input_jump_action_name)
		
		if (bGrabbing or bSyncWithShadow):
			move(delta, input_axis, input_jump, input_crouch, input_sprint, input_swim_down, input_swim_up, characterShadow)
		else:
			move(delta, input_axis, input_jump, input_crouch, input_sprint, input_swim_down, input_swim_up, null)

	else:
		# NOTE: It is important to always call move() even if we have no inputs 
		## to process, as we still need to calculate gravity and collisions.
		if (bGrabbing or bSyncWithShadow):
			move(delta, Vector2.ZERO, false, false, false, false, false, characterShadow)
		else:
			move(delta, Vector2.ZERO, false, false, false, false, false, null)
	
	
var bGrabbing: bool = false
var objectGrabbedLeft: RigidBody3D
var objectGrabbedRight: RigidBody3D
var shapeCastColliderObject: Object
func _input(event: InputEvent) -> void:
	# Mouse look (only if the mouse is captured).
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_head(event.screen_relative)
	
	ProcessPlayerActions(event)

func ProcessPlayerShadow() -> void:
	if (characterShadow.linear_velocity.length() > 5):
		bSyncWithShadow = true
	else:
		bSyncWithShadow = false

	if bGrabbing or bSyncWithShadow:
		global_position.x = characterShadow.global_position.x
		global_position.z = characterShadow.global_position.z
		#just incase the physics freaks out and we move to fast
		#TODO: probably should do a raycast to get the ground position instead
		global_position.y = characterShadow.global_position.y

		#characterShadow.global_rotation = global_rotation
		characterShadow.linear_damp = 1
	else:
		characterShadow.linear_velocity = Vector3.ZERO
		characterShadow.global_transform = global_transform
		characterShadow.linear_damp = 1

func ProcessPlayerActions(event: InputEvent) -> void:
	if event.is_action("LeftClick"):
		if (leftHandRay.is_colliding()):
			GrabbedWithLeft()
	
	if event.is_action("RightClick"):
		if (rightHandRay.is_colliding()):
			GrabbedWithRight()

	if event.is_action_released("LeftClick"):
		ReleasedWithLeft()
		
	if event.is_action_released("RightClick"):
		ReleasedWithRight()

func GrabbedWithLeft() -> void:
	shapeCastColliderObject = leftHandRay.get_collider(0)
	print("grabbed collider: %s" % shapeCastColliderObject)
	characterShadow.linear_damp = 1
	
	if (shapeCastColliderObject is RigidBody3D):
		leftHandJoint.node_a = characterShadow.get_path()
		leftHandJoint.node_b = shapeCastColliderObject.get_path()
		objectGrabbedLeft = shapeCastColliderObject
		bGrabbing = true
	elif (shapeCastColliderObject.get_parent() is RigidBody3D):
		leftHandJoint.node_a = characterShadow.get_path()
		leftHandJoint.node_b = shapeCastColliderObject.get_parent().get_path()
		objectGrabbedLeft = shapeCastColliderObject.get_parent()
		bGrabbing = true
	if (objectGrabbedLeft is BuildingBlock):
		var block: BuildingBlock = objectGrabbedLeft
		GrabbedBlockWithLeft(block)

func GrabbedWithRight() -> void:
	shapeCastColliderObject = rightHandRay.get_collider(0)
	print("grabbed collider: %s" % shapeCastColliderObject)
	characterShadow.linear_damp = 1
	
	if (shapeCastColliderObject is RigidBody3D):
		rightHandJoint.node_a = self.get_path()
		rightHandJoint.node_b = shapeCastColliderObject.get_path()
		objectGrabbedRight = shapeCastColliderObject
		bGrabbing = true
	elif (shapeCastColliderObject.get_parent() is RigidBody3D):
		rightHandJoint.node_a = characterShadow.get_path()
		rightHandJoint.node_b = shapeCastColliderObject.get_parent().get_path()
		objectGrabbedRight = shapeCastColliderObject.get_parent()
		bGrabbing = true
	if (objectGrabbedRight is BuildingBlock):
		var block: BuildingBlock = objectGrabbedRight
		GrabbedBlockWithRight(block)

func ReleasedWithLeft() -> void:
	print("left go with left hand")
	if (objectGrabbedLeft is BuildingBlock):
		var block: BuildingBlock = objectGrabbedLeft
		ReleasedBlockWithLeft(block)
	leftHandJoint.node_a = leftHandJoint.get_path()
	leftHandJoint.node_b = leftHandJoint.get_path()
	characterShadow.linear_damp = 1
	objectGrabbedLeft = null
	if (!objectGrabbedRight):
		bGrabbing = false

func ReleasedWithRight() -> void:
	print("left go with right hand")
	if (objectGrabbedRight is BuildingBlock):
		var block: BuildingBlock = objectGrabbedRight
		ReleasedBlockWithRight(block)
	rightHandJoint.node_a = rightHandJoint.get_path()
	rightHandJoint.node_b = rightHandJoint.get_path()
	characterShadow.linear_damp = 1
	bGrabbing = false
	objectGrabbedRight = null
	if (!objectGrabbedLeft):
		bGrabbing = false

func GrabbedBlockWithLeft(block: BuildingBlock) -> void:
	block.GrabbedBlock()
	#block.lock_rotation = true
	block.axis_lock_angular_x = true
	block.axis_lock_angular_z = true


func ReleasedBlockWithLeft(block: BuildingBlock) -> void:
	#block.lock_rotation = false
	block.axis_lock_angular_x = false
	block.axis_lock_angular_z = false
	var blockJoint: BlockJoint = block.CheckForConnection()
	if (blockJoint):
		block.AddConnection(blockJoint)
		#process maintaining block container parent
		ConnectingBlocks(block, blockJoint.closestConnection.get_parent())
	block.DroppedBlock()

func GrabbedBlockWithRight(block: BuildingBlock) -> void:
	block.GrabbedBlock()
	#block.lock_rotation = true
	block.axis_lock_angular_x = true
	block.axis_lock_angular_z = true


func ReleasedBlockWithRight(block: BuildingBlock) -> void:
	#block.lock_rotation = false
	block.axis_lock_angular_x = false
	block.axis_lock_angular_z = false
	var blockJoint: BlockJoint = block.CheckForConnection()
	if (blockJoint):
		block.AddConnection(blockJoint)
		#process maintaining block container parent
		ConnectingBlocks(block, blockJoint.closestConnection.get_parent())
	block.DroppedBlock()

func ConnectingBlocks(block1: BuildingBlock, block2: BuildingBlock) -> void:
	var block1Parent: BuildingBlockContainer = block1.containerParent
	var block2Parent: BuildingBlockContainer = block2.containerParent
		
	if(block1Parent):
		if(block2Parent):#both blocks are apart of some kind of container construction of blocks, so remove one and put them in the other
			var block2Connections: Array[BuildingBlock] = block2Parent.blocks.duplicate_deep()
			for b: BuildingBlock in block2Connections:
				block2Parent.RemoveBlock(b)
				block1Parent.AddBlock(b)
			#block2Parent.queue_free()
		else:#second block has never been attached to anything, so just add it to the first blocks container
			block1Parent.AddBlock(block2)
	elif(block2Parent):#block 1 wasnt apart of any construction yet, so just add it to the other block container
		block2Parent.AddBlock(block1)
	else:#neither block is attached to anything, so make a container block for them
		var newBlockContainer: BuildingBlockContainer = BuildingBlockContainer.new()
		newBlockContainer.name = "%s%s" % [block1.name, block2.name]
		if(!newBlockContainer.get_parent()):
			constructionContainerNode.add_child(newBlockContainer)
		newBlockContainer.AddBlock(block1)
		newBlockContainer.AddBlock(block2)
