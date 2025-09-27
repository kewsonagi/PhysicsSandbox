extends BuildingBlock
class_name ControlUnitBlock

signal EnteredUnit(c: ControlUnitBlock)
signal ExitUnit(c: ControlUnitBlock)

var bCurrentlyControlling: bool = false

func UpdateBlock(delta: float) -> void:
	if(CheckForwardInput()):
		Forward.emit(delta)
	if(CheckBackwardInput()):
		Backward.emit(delta)
	if(CheckLeftInput()):
		Left.emit(delta)
	if(CheckRightInput()):
		Right.emit(delta)

	if(CheckActionInput()):
		Action.emit(delta)
	if(CheckAltActionInput()):
		AltAction.emit(delta)
	if(CheckJumpInput()):
		Jump.emit(delta)

	if(CheckLeftTriggerInput()):
		LeftTrigger.emit(delta)
	if(CheckRightTriggerInput()):
		RightTrigger.emit(delta)
	

func UpdateBlockInput(event: InputEvent) -> void:
	if(CheckCancelInput()):
		Cancel.emit(get_physics_process_delta_time())
	if(CheckDPadUpInput()):
		DPadUp.emit(get_physics_process_delta_time())
	if(CheckDPadDownInput()):
		DPadDown.emit(get_physics_process_delta_time())
	if(CheckDPadLeftInput()):
		DPadLeft.emit(get_physics_process_delta_time())
	if(CheckDPadRightInput()):
		DPadRight.emit(get_physics_process_delta_time())

	pass

#control units should only connect to 1 of the connection points
#there could be multiple locations they can connect at, so just make sure 1 has been taken before scanning for a connection
func GrabbedBlock() -> void:
	var bIsConnected: bool = false
	for joint: BlockJoint in connections:
		if(!joint.bOpen):
			bIsConnected = true

	if(!bIsConnected):
		for joint: BlockJoint in connections:
			joint.Activate()
	else:
		if(!bCurrentlyControlling):
			EnteredUnit.emit(self)
			bCurrentlyControlling = true

func DroppedBlock() -> void:
	var bIsConnected: bool = false
	for joint: BlockJoint in connections:
		if(!joint.bOpen):
			bIsConnected = true
	
	if(!bIsConnected):
		for joint: BlockJoint in connections:
			joint.Deactivate()
	else:
		if(bCurrentlyControlling):
			ExitUnit.emit(self)
			bCurrentlyControlling = false
	

func CheckForwardInput() -> bool:
	return Input.is_action_pressed("Forward")
func CheckBackwardInput() -> bool:
	return Input.is_action_pressed("Backward")
func CheckLeftInput() -> bool:
	return Input.is_action_pressed("Left")
func CheckRightInput() -> bool:
	return Input.is_action_pressed("Right")
	
func CheckActionInput() -> bool:
	return Input.is_action_just_pressed("Action")
func CheckAltActionInput() -> bool:
	return Input.is_action_just_pressed("AltAction")
func CheckCancelInput() -> bool:
	return Input.is_action_just_pressed("Cancel")
func CheckJumpInput() -> bool:
	return Input.is_action_pressed("Jump")
func CheckLeftTriggerInput() -> bool:
	return Input.is_action_pressed("LeftTrigger")
func CheckRightTriggerInput() -> bool:
	return Input.is_action_pressed("RightTrigger")

func CheckDPadUpInput() -> bool:
	return Input.is_action_just_pressed("DPadUp")
func CheckDPadDownInput() -> bool:
	return Input.is_action_just_pressed("DPadDown")
func CheckDPadLeftInput() -> bool:
	return Input.is_action_just_pressed("DPadLeft")
func CheckDPadRightInput() -> bool:
	return Input.is_action_just_pressed("DPadRight")

func EnteredControlUnit(b: BuildingBlock) -> void:
	pass
func ExitControlUnit(b: BuildingBlock) -> void:
	pass