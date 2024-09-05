extends Camera2D
class_name Camera

# Screen shake parameters
var shake_intensity = 4.0
var shake_duration = 0.1
var shake_timer = 0.0

# Noise generator for shake effect
var noise = FastNoiseLite.new()

# Original camera position to reset after shaking
var original_position: Vector2

func _ready() -> void:
	original_position = position  # Store the original camera position
	noise.seed = int(Time.get_ticks_msec())
	noise.frequency = 0.05  # Adjust for the smoothness of the shake

func _process(delta: float) -> void:
	if shake_timer > 0:
		shake_timer -= delta
		# Apply a small random offset to the camera position for the shake effect using noise
		var shake_offset = Vector2(
			noise.get_noise_2d(Time.get_ticks_msec() * 0.01, 0.0),
			noise.get_noise_2d(0.0, Time.get_ticks_msec() * 0.01)
		) * shake_intensity
		position = original_position + shake_offset
	else:
		# Reset the camera to its original position when not shaking
		position = original_position

# Function to trigger the shake
func shake(intensity: float, duration: float) -> void:
	shake_intensity = intensity
	shake_duration = duration
	shake_timer = duration
