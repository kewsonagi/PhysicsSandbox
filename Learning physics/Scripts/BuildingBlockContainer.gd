extends Node3D
class_name BuildingBlockContainer

@export var blocks: Array[BuildingBlock]
var controlBlock: ControlUnitBlock
var functionalUnits: Array[BuildingBlock]
var bActive: bool = false

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if(bActive):
		for block: BuildingBlock in blocks:
			block.UpdateBlock(delta)

func _unhandled_input(event: InputEvent) -> void:
	if(bActive):
		for block: BuildingBlock in blocks:
			block.UpdateBlockInput(event)

func AddBlock(b: BuildingBlock) -> void:
	if(!blocks.has(b)):
		b.containerParent = self
		blocks.append(b)
		if(b is FunctionalBuildingBlock):
			functionalUnits.append(b)
		if(b is ControlUnitBlock):
			(b as ControlUnitBlock).EnteredUnit.connect(EnteredControlUnit)
			(b as ControlUnitBlock).ExitUnit.connect(ExitControlUnit)

func RemoveBlock(b: BuildingBlock) -> void:
	blocks.erase(b)
	if(b.containerParent == self):
		b.containerParent = null
	if(b is FunctionalBuildingBlock):
		functionalUnits.erase(b)
	if(b is ControlUnitBlock):
		(b as ControlUnitBlock).EnteredUnit.disconnect(EnteredControlUnit)
		(b as ControlUnitBlock).ExitUnit.disconnect(ExitControlUnit)

func EnteredControlUnit(b: BuildingBlock) -> void:
	controlBlock = b as ControlUnitBlock
	for block: BuildingBlock in blocks:
		block.EnteredControlUnit(b)
	bActive = true

func ExitControlUnit(b: BuildingBlock) -> void:
	if(b == controlBlock):
		for block: BuildingBlock in blocks:
			block.ExitControlUnit(b)
			controlBlock = null
		bActive = false
