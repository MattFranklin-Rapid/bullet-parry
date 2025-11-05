extends Node2D

func damage(proj: Projectile2D) -> void:
	print("I took %d damage!" % proj.damage)
	queue_free()
