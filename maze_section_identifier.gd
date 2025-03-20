
#extends MeshInstance3D
#
#
#@export var BushScene: PackedScene
#@export var greenMat: Material
#@export var IsBush: bool:
	#set(isTrue):
		#if isTrue:
			#set_surface_override_material(0, greenMat)
		#else:
			#set_surface_override_material(0, null)
		#IsBush = isTrue
#
#
#func doit():
	#if IsBush and not Engine.is_editor_hint():
		#var bush = BushScene.instantiate()
		#get_parent().add_child(bush)
		#bush.global_position = global_position
		#queue_free()
