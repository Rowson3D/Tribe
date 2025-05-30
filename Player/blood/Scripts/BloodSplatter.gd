extends Node2D

@onready var particle_nodes := [$CPUParticles2D, $CPUParticles2D2, $CPUParticles2D3]

func _ready():
	print("BloodSplatter ready, emitting all particles")

	# Start all 3 particle systems
	for particles in particle_nodes:
		particles.emitting = true

	# Get the max lifetime to wait for cleanup
	var max_lifetime = particle_nodes.map(func(p): return p.lifetime).max()
	await get_tree().create_timer(max_lifetime).timeout
	queue_free()
