extends RigidBody3D
class_name BuildingBlock

@export var connections: Array[BlockJoint]
var connectingBlocks: Array[BuildingBlock]
var containerParent: BuildingBlockContainer = null

signal Forward(delta: float)
signal Backward(delta: float)
signal Left(delta: float)
signal Right(delta: float)
signal Action(delta: float)
signal Jump(delta: float)
signal AltAction(delta: float)
signal Cancel(delta: float)
signal LeftTrigger(delta: float)
signal RightTrigger(delta: float)
signal DPadUp(delta: float)
signal DPadDown(delta: float)
signal DPadLeft(delta: float)
signal DPadRight(delta: float)

func CheckForConnection() -> BlockJoint:
	for joint in connections:
		if joint.bOpen:
			if(joint.connectorCheckShape.is_colliding()):
				var col: Node3D = joint.connectorCheckShape.get_collider(0)
				if(col.get_parent() is BuildingBlock):
					joint.closestConnection = col
					return joint
	return null

func UpdateBlock(delta: float) -> void:
	return
func UpdateBlockInput(event: InputEvent) -> void:
	return

func GrabbedBlock() -> void:
	for joint: BlockJoint in connections:
		joint.Activate()

func DroppedBlock() -> void:
	for joint: BlockJoint in connections:
		joint.Deactivate()

func AddConnection(joint: BlockJoint) -> void:
	#get this connection joins collider block and joint
	var block2: BuildingBlock = joint.closestConnection.get_parent()
	var block2Joint: BlockJoint = joint.closestConnection
	if(block2):
		global_rotation = block2Joint.global_rotation
		global_position = block2Joint.global_position

		var dir: Vector3 = block2Joint.global_basis.z.normalized()#(block2Joint.global_position - joint.global_position).normalized()#(block2Joint.global_position - block2.global_position).normalized()
		#self.global_rotation = block2Joint.global_rotation

		position += dir*joint.locPos.length()
		#position = oldPos

		#setup this joints connections this block to the connecting block
		joint.joint.node_a = self.get_path()
		joint.joint.node_b = block2.get_path()#joint.closestConnection.get_path()
		
		
		joint.connectorCheckShape.enabled = false
		joint.ourCollider.disabled = true
		joint.bOpen = false

		#disable collision between blocks
		self.add_collision_exception_with(block2)
		block2.add_collision_exception_with(self)
		connectingBlocks.append(block2)
		block2.connectingBlocks.append(self)

		#setup the connecting blocks joint 
		block2Joint.bOpen = false
		block2Joint.ourCollider.disabled = true
		block2Joint.connectorCheckShape.enabled = false
		block2Joint.joint.node_a = block2.get_path()
		block2Joint.joint.node_b = self.get_path()#joint.get_path()

func RemoveConnection(joint: BlockJoint) -> void:
	joint.joint.node_a = ""
	joint.joint.node_b = ""
	joint.connectorCheckShape.enabled = true
	joint.ourCollider.disabled = false
	joint.bOpen = true

	var block2: BuildingBlock = joint.closestConnection.get_parent()
	var block2Joint: BlockJoint = joint.closestConnection

	
	block2Joint.bOpen = true
	block2Joint.ourCollider.disabled = false
	block2Joint.connectorCheckShape.enabled = true
	block2Joint.joint.node_a = ""
	block2Joint.joint.node_b = ""

	connectingBlocks.erase(block2)
	block2.connectingBlocks.erase(self)
	self.remove_collision_exception_with(block2)
	block2.remove_collision_exception_with(self)

func EnteredControlUnit(b: BuildingBlock) -> void:
	pass
func ExitControlUnit(b: BuildingBlock) -> void:
	pass
