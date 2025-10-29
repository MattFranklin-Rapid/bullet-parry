extends Node2D


# Die after the timer finishes
func _on_timer_timeout() -> void:
	self.queue_free()
