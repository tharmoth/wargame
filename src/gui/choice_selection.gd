extends PanelContainer

@export var menu_to_close: NodePath  # Assign the menu node to close in the Inspector

var default_stylebox: StyleBoxFlat
var hover_stylebox: StyleBoxFlat
var pressed_stylebox: StyleBoxFlat

func _ready() -> void:
	# Ensure the PanelContainer detects mouse events even when children are hovered
	mouse_filter = Control.MOUSE_FILTER_STOP  

	# Set children to ignore mouse input
	for child: Control in get_children():  # Explicitly define child as Control
		child.mouse_filter = Control.MOUSE_FILTER_IGNORE  

	# Create default style
	default_stylebox = StyleBoxFlat.new()
	default_stylebox.bg_color = Color(0.1, 0.1, 0.2, 0.85)  # Dark blue background
	default_stylebox.border_color = Color.GOLD
	default_stylebox.border_width_top = 4
	default_stylebox.border_width_bottom = 4
	default_stylebox.border_width_left = 4
	default_stylebox.border_width_right = 4
	
	# Set corner radii
	default_stylebox.corner_radius_top_left = 12
	default_stylebox.corner_radius_top_right = 12
	default_stylebox.corner_radius_bottom_left = 12
	default_stylebox.corner_radius_bottom_right = 12

	# Create hover style
	hover_stylebox = default_stylebox.duplicate()
	hover_stylebox.bg_color = Color(0.2, 0.2, 0.4, 1.0)  # Slightly brighter blue
	hover_stylebox.border_color = Color.WHITE

	# Create pressed style (when clicked)
	pressed_stylebox = default_stylebox.duplicate()
	pressed_stylebox.bg_color = Color(0.1, 0.2, 0.5, 1.0)  # Soft Blue
	pressed_stylebox.border_color = Color(0.3, 0.5, 1.0)  # Light Blue Border

	# Set default style
	add_theme_stylebox_override("panel", default_stylebox)

	# Connect signals for hover effects
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
	add_theme_stylebox_override("panel", hover_stylebox)

func _on_mouse_exited() -> void:
	add_theme_stylebox_override("panel", default_stylebox)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			add_theme_stylebox_override("panel", pressed_stylebox)  # Change to pressed style

		else:  # Mouse button released
			add_theme_stylebox_override("panel", hover_stylebox)  # Reset to hover style

			# Close the assigned menu
			var menu: Node = get_node_or_null(menu_to_close)
			if menu is Control:
				menu.hide()  # Hide the menu if it's a Control node
