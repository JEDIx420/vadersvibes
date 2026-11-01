extends CanvasLayer
class_name CleanHUD

@onready var interaction_badge: PanelContainer = $CenterContainer/InteractionBadge
@onready var interaction_label: Label = $CenterContainer/InteractionBadge/Margin/InteractionText
@onready var gear_badge: Label = $BottomRight/Panel/Margin/GearText

func _ready() -> void:
	hide_interaction_prompt()
	update_gear_display(false, false)

func show_interaction_prompt(prompt_text: String) -> void:
	if interaction_label and interaction_badge:
		interaction_label.text = prompt_text
		interaction_badge.visible = true

func hide_interaction_prompt() -> void:
	if interaction_badge:
		interaction_badge.visible = false

func update_gear_display(has_lightsaber: bool, has_guitar: bool) -> void:
	if not gear_badge:
		return
	if has_lightsaber:
		gear_badge.text = "⚡ Lightsaber: ACTIVE [F: Holster]\n🎸 Guitar: Stored [G: Equip]"
	elif has_guitar:
		gear_badge.text = "🎸 Guitar: ACTIVE [Keys 1-6 to Strum]\n⚡ Lightsaber: Holstered [F: Draw]\n[G or 0: Put Away]"
	else:
		gear_badge.text = "✋ Hands: FREE\n⚡ [F: Draw Lightsaber]\n🎸 [G: Play Guitar]"
