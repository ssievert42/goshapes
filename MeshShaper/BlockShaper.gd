@tool
extends Shaper
class_name BlockShaper

var watcher_cap := ResourceWatcher.new(mark_dirty)
@export var cap_shaper: Resource:
	set(value):
		cap_shaper = value
		watcher_cap.watch(cap_shaper)
		mark_dirty()
		

var watcher_wall := ResourceWatcher.new(mark_dirty)
@export var wall_shaper: Resource:
	set(value):
		wall_shaper = value
		watcher_wall.watch(wall_shaper)
		mark_dirty()
		

var watcher_bottom := ResourceWatcher.new(mark_dirty)
@export var bottom_shaper: Resource:
	set(value):
		bottom_shaper = value
		watcher_bottom.watch(bottom_shaper)
		mark_dirty()
		

@export_range(0.0, 20.0, 0.5) var bottom_depth = 0.0:
	set(value):
		bottom_depth = value
		mark_dirty()
		

enum ColliderType { None, CapOnly, Simple, Ridged, Accurate }
@export var collider_type: ColliderType = ColliderType.Simple:
	set(value):
		collider_type = value
		emit_changed()


@export_range(0.0, 10.0, 1.0) var collider_ridge: float = 0.0:
	set(value):
		collider_ridge = value
		emit_changed()
		

var is_dirty = false

func _init() -> void:
	if cap_shaper == null:
		cap_shaper = ShaperTypes.get_cap_types()[0].new()
	if wall_shaper == null:
		wall_shaper = ShaperTypes.get_wall_types()[0].new()
	if bottom_shaper == null:
		bottom_shaper = ShaperTypes.get_bottom_types()[0].new()
		bottom_shaper.enabled = false
	watcher_cap.watch(cap_shaper)
	watcher_wall.watch(wall_shaper)
	watcher_bottom.watch(bottom_shaper)

	
func mark_dirty():
	if is_dirty:
		return
	is_dirty = true
	_update.call_deferred()
	
	
func _update():
	is_dirty = false
	emit_changed()
	

func get_builder() -> ShapeBuilder:
	return BlockBuilder.new(self)
	

class BlockBuilder extends ShapeBuilder:
	
	var style: BlockShaper
	func _init(_style: BlockShaper):
		style = _style
		
	func build(_host: Node3D, _path: PathData) -> void:
		host = _host
		path = _path
		if style.cap_shaper != null and style.cap_shaper.enabled:
			style.cap_shaper.get_builder().build(host, path)
		if style.wall_shaper != null and style.wall_shaper.enabled:
			style.wall_shaper.get_builder().build(host, path)
		if style.bottom_shaper != null and style.bottom_shaper.enabled:
			style.bottom_shaper.cap_shaper = style.cap_shaper
			style.bottom_shaper.get_builder().build(host, path)
		

	func apply_mesh(mesh: ArrayMesh) -> void:
		var mesh_node = SceneUtils.get_or_create(host, "Mesh", MeshInstance3D)
		mesh_node.transform = Transform3D()
		mesh_node.mesh = mesh
		
		
	func apply_collider(mesh: ArrayMesh) -> void:
		var collider_body = SceneUtils.get_or_create(host, "Collider", StaticBody3D)
		collider_body.transform = Transform3D()
		var collider_shape = SceneUtils.get_or_create(collider_body, "CollisionShape", CollisionShape3D)
		collider_shape.shape = mesh.create_trimesh_shape()
		collider_shape.transform = Transform3D()
