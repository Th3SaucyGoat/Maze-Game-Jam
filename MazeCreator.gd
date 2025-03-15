@tool
extends EditorScript
#
@export var SizeOfMaze: Vector2i = Vector2(5,5)
@export var DimensionsPerSection: Vector3 = Vector3(7.5,3.3, 7.5)
#
func _run() -> void:
	var mazeParent = get_editor_interface().get_selection().get_selected_nodes()[0]
	if mazeParent.name != "MazeParent":
		print("Can only use this script on the MazeParent node!!")
		return
	const identifier = preload("res://maze_section_identifier.tscn")
	var Xpos: float = mazeParent.global_position.x
	var Zpos: float = mazeParent.global_position.z
	for x in SizeOfMaze.x:
		for z in SizeOfMaze.y:
			var sect = identifier.instantiate()
			mazeParent.add_child(sect)
			sect.set_owner(mazeParent.get_tree().get_edited_scene_root())
			sect.global_position = Vector3(Xpos, DimensionsPerSection.y, Zpos)
			Zpos += DimensionsPerSection.z
		Xpos += DimensionsPerSection.x
		Zpos = mazeParent.global_position.z
		
	
