@tool
extends EditorScript

var plugin_name : String = "godot-playfab"
var base_path : String = "../../"
var plugin_source_path : String = "godot-playfab/addons/godot-playfab"
var plugin_destination_path : String = "godot-playfab-example/godot-steam/addons/godot-playfab"

var exluded_directories : Array[String] = [
	"test"
]

# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	copy(plugin_source_path, plugin_destination_path)
	reload()


func reload():
	EditorInterface.set_plugin_enabled(plugin_name, false)
	EditorInterface.set_plugin_enabled(plugin_name, true)
	print("Reloaded plugin " + plugin_name)


func copy(source_path : String, destination_path : String):
	var da = DirAccess.open(base_path)
	var current_dir = da.get_current_dir()
	print ("Opened base path: %s", current_dir)

	source_path = current_dir.path_join(source_path) + "/"
	destination_path = current_dir.path_join(destination_path) + "/"
	print("source path: %s ➡️ destination path: %s" % [source_path, destination_path])

	if (da.dir_exists(source_path)):
		DirAccess.make_dir_absolute(destination_path)
		copy_directory(source_path, destination_path)
		print("Copied %s to %s" % [source_path, destination_path])


func _delete_excluded() -> void:
	pass


func copy_directory(src_dir: String, dest_dir: String) -> void:
	var dir = DirAccess.open(src_dir)
	if not dir:
		push_error("Source dir %s doesn't exist" % src_dir)
		return
	if not DirAccess.dir_exists_absolute(dest_dir) :
		if not DirAccess.make_dir_recursive_absolute(dest_dir):
			push_error("Destination dir %s couldn't be created" % src_dir)
			return
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name:
		if file_name == "." or file_name == ".." or file_name in exluded_directories:
			file_name = dir.get_next()
			continue
		var src_path = src_dir.path_join(file_name)
		var dest_path = dest_dir.path_join(file_name)
		if dir.current_is_dir():
			copy_directory(src_path, dest_path)
		else:
			copy_file(src_path, dest_path)
		file_name = dir.get_next()
	dir.list_dir_end()


func copy_file(src_path: String, dest_path: String) -> void:
	var src_file = FileAccess.open(src_path, FileAccess.READ)
	var dest_file = FileAccess.open(dest_path, FileAccess.WRITE)
	dest_file.store_buffer(src_file.get_buffer(src_file.get_length()))
	src_file.close()
	dest_file.close()
