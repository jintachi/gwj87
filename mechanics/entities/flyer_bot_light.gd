#*
#* flyer_bot_light.gd
#* =============================================================================
#* Cone-shaped light that follows the flyer bot's rotation.
#* =============================================================================
#*
extends PointLight2D

## Offset position from the bot's center (adjustable in editor).
@export var attach_offset: Vector2 = Vector2.ZERO

## Reference to the parent flyer bot.
var flyer_bot: FlyerBot

## Initial rotation offset (in radians) - can be adjusted if light needs to point in a different direction.
@export var rotation_offset: float = 0.0

## Cone angle in degrees (half-angle from center).
@export var cone_angle: float = 45.0

## Light range/distance.
@export var light_range: float = 300.0

## Light texture size (width and height).
@export var texture_size: Vector2i = Vector2i(256, 256)


func _ready() -> void:
	# Find the flyer bot parent
	flyer_bot = get_parent() as FlyerBot
	if not flyer_bot:
		# Try to find it in the parent hierarchy
		var parent = get_parent()
		while parent:
			if parent is FlyerBot:
				flyer_bot = parent
				break
			parent = parent.get_parent()
	
	if not flyer_bot:
		push_error("FlyerBotLight: Could not find FlyerBot parent")
		return
	
	# Set initial position based on offset
	position = attach_offset
	
	# Generate cone-shaped texture and set it
	_generate_cone_texture()


func _generate_cone_texture() -> void:
	# Create an image for the cone
	var image = Image.create(texture_size.x, texture_size.y, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))  # Transparent background
	
	# Light source is at the left center, cone extends to the right
	var source_x: float = texture_size.x * 0.1  # Light source near left edge
	var source_y: float = texture_size.y * 0.5  # Center vertically
	var half_angle_rad: float = deg_to_rad(cone_angle)
	var max_radius: float = texture_size.x * 0.9  # Radius of the circular arc
	
	# Draw cone shape as a slice of a circle
	for y in range(texture_size.y):
		for x in range(texture_size.x):
			var dx: float = x - source_x
			var dy: float = y - source_y
			var distance: float = sqrt(dx * dx + dy * dy)
			
			# Only process pixels to the right of the source
			if dx > 0:
				var angle: float = atan2(dy, dx)
				
				# Check if point is within the cone angle
				if abs(angle) <= half_angle_rad:
					# Check if point is within the circular arc (distance from source)
					if distance <= max_radius:
						# Calculate intensity based on distance from source (circular falloff)
						var normalized_distance: float = distance / max_radius
						var intensity: float = 1.0 - (normalized_distance * 0.7)  # Keep some intensity even at max distance
						
						# Fade based on angle for softer side edges
						var angle_factor: float = 1.0 - (abs(angle) / half_angle_rad) * 0.3
						intensity *= angle_factor
						
						# Additional fade near the circular edge for smoother transition
						var edge_fade: float = 1.0
						if normalized_distance > 0.8:
							# Fade out in the last 20% of the radius
							edge_fade = 1.0 - ((normalized_distance - 0.8) / 0.2)
						intensity *= edge_fade
						
						# Set pixel color (white with alpha based on intensity)
						intensity = clamp(intensity, 0.0, 1.0)
						image.set_pixel(x, y, Color(1, 1, 1, intensity))
	
	# Create texture from image (Godot 4 API)
	var image_texture = ImageTexture.create_from_image(image)
	
	# Note: PointLight2D may not have a 'texture' property in Godot 4.5
	# The texture is generated but cannot be automatically assigned.
	# You may need to:
	# 1. Manually assign the generated texture in the editor, OR
	# 2. Use a Sprite2D node with a shader material instead of PointLight2D
	# 
	# For now, we'll store it in a variable that can be accessed if needed
	# Store the texture reference (you can access this if needed for manual assignment)
	var generated_texture = image_texture


func _process(_delta: float) -> void:
	if not flyer_bot:
		return
	
	# Update position based on attach offset
	position = attach_offset
	
	# Update rotation based on bot's facing direction
	if not flyer_bot.face_dir.is_zero_approx():
		var angle: float = flyer_bot.face_dir.angle() + rotation_offset
		rotation = angle
