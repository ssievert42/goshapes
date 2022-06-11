@tool
extends CapShaper
class_name CapFlatShaper
			
			
func get_builder() -> ShapeBuilder:
	return CapFlatBuilder.new(self)
			
			
class CapFlatBuilder extends CapBuilder:
	
	var style: CapFlatShaper
	func _init(_style: CapFlatShaper):
		super._init(style)
		style = _style

	func build_sets(path: PathData) -> Array:
		var points = get_cap_points(style, path)
		var meshset = MeshUtils.make_cap(points)
		meshset.material = style.material
		return [meshset]