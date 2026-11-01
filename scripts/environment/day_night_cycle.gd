extends Node3D
class_name DayNightCycle

@export var day_length_seconds: float = 120.0 # 2 minutes for full cycle in demo
@export var sun_light: DirectionalLight3D
@export var world_environment: WorldEnvironment

var time_of_day: float = 0.25 # Start at morning (0.25 = sunrise/morning, 0.5 = noon, 0.75 = sunset, 0.0 = midnight)

func _process(delta: float) -> void:
	time_of_day += delta / day_length_seconds
	if time_of_day >= 1.0:
		time_of_day -= 1.0
		
	var angle = time_of_day * TAU - PI * 0.5
	if sun_light:
		sun_light.rotation.x = angle
		sun_light.rotation.y = deg_to_rad(30.0)
		
		# Intensity based on sun elevation
		var elevation = sin(angle)
		if elevation > 0:
			sun_light.light_energy = clamp(elevation * 1.5, 0.0, 1.2)
			sun_light.light_color = Color(1.0, 0.95, 0.85).lerp(Color(1.0, 0.6, 0.3), pow(1.0 - elevation, 3.0))
		else:
			sun_light.light_energy = 0.05
			sun_light.light_color = Color(0.3, 0.4, 0.7)
