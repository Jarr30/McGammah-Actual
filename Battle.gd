extends Control

signal textbox_closed

export(Resource) var enemy = null

var current_player_health = 0
var current_enemy_health = 0
var is_defending = false

func _ready():
	set_health($EnemyContainer/ProgressBar, enemy.health, enemy.health)
	set_health($PlayerPanel/PlayerData/ProgressBar, State.current_health, State.max_health)
	$EnemyContainer/Enemy.texture = enemy.texture
	
	current_player_health = State.current_health
	current_enemy_health = enemy.health
	
	$TextBox.hide()
	$ActionsPanel.hide()
	
	display_text("%s challenged you to a fight!" % enemy.name.to_upper())
	yield(self, "textbox_closed")
	$ActionsPanel.show()

func set_health(progress_bar, health, max_health):
	progress_bar.value = health
	progress_bar.max_value = max_health
	progress_bar.get_node("Label").text = "HP:%d/%d" % [health, max_health]

func _input(event):
	if (Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(BUTTON_LEFT)) and $TextBox.visible:
		$TextBox.hide()
		emit_signal("textbox_closed")

func display_text(text):
	$ActionsPanel.hide()
	$TextBox.show()
	$TextBox/Label.text = text
	
func enemy_turn():
	display_text("%s played 3 hours of shreksaphone!" % enemy.name.to_upper())
	yield(self, "textbox_closed")
	
	if is_defending:
		is_defending = false
		$AnimationPlayer.play("mini_shake")
		yield($AnimationPlayer, "animation_finished")
		display_text("You effectively avoided the Shreksaphone!")
		yield(self, "textbox_closed")
	else:
		current_player_health = max(0, current_player_health - enemy.damage)
		set_health($PlayerPanel/PlayerData/ProgressBar, current_player_health, State.max_health)
		$AnimationPlayer.play("shake")
		yield($AnimationPlayer, "animation_finished")
		display_text("%s dealt %d damage!" % [enemy.name.to_upper(), enemy.damage])
		yield(self, "textbox_closed")
	if current_player_health == 0:
		display_text("%s made you quit, maybe you can talk to the rubber duck about it. :(" % enemy.name.to_upper())
		yield(self, "textbox_closed")
		yield(get_tree().create_timer(0.25), "timeout")
		get_tree().quit()
	else:
		$ActionsPanel.show()

func _on_Run_pressed() -> void:
	display_text("You ran like a coward!")
	yield(self, "textbox_closed")
	yield(get_tree().create_timer(0.25), "timeout")
	get_tree().quit()

func _on_Attack_pressed() -> void:
	display_text("You comment on his bad practice! You deal %d damage!" % State.damage )
	yield(self, "textbox_closed")
	
	current_enemy_health = max(0, current_enemy_health - State.damage)
	set_health($EnemyContainer/ProgressBar, current_enemy_health, enemy.health)
	
	$AnimationPlayer.play("enemy_damaged")
	yield($AnimationPlayer, "animation_finished")

	if current_enemy_health == 0:
		display_text("%s started crying and got back to work!" % enemy.name)
		yield(self, "textbox_closed")
		
		$AnimationPlayer.play("enemy_died")
		yield($AnimationPlayer, "animation_finished")
		yield(get_tree().create_timer(0.1), "timeout")
		get_tree().quit()
	else:
		enemy_turn()

func _on_Defend_pressed() -> void:
	is_defending = true
	display_text("You lock his screen in preparation!")
	yield(self, "textbox_closed")
	
	yield(get_tree().create_timer(0.25), "timeout")
	
	$ActionsPanel.show()
