@tool
extends Button

@export var secret_fields: Array[LineEdit] = []
@export var is_secret := true:
    set(val):
        is_secret = val
        if not is_node_ready(): return
        update_nodes()
        update_icon()

@export var texture_visible: Texture2D:
    set(val):
        texture_visible = val
        if not is_node_ready(): return
        update_icon()

@export var texture_secret: Texture2D:
    set(val):
        texture_secret = val
        if not is_node_ready(): return
        update_icon()

func _get_configuration_warnings() -> PackedStringArray:
    var warnings: PackedStringArray = []
    if not texture_secret:
        warnings.append("This button needs a texture for the icon on secret.")
    if not texture_visible:
        warnings.append("This button needs a texture for the icon on visible.")
    if secret_fields.is_empty():
        warnings.append("Please include LineEdit nodes that need to be toggled secret")
    return warnings


func update_nodes() -> void:
    for ln: LineEdit in secret_fields:
        ln.secret = is_secret



func update_icon() -> void:
    if is_secret and texture_secret:
        icon = texture_secret
    elif !is_secret and texture_visible:
        icon = texture_visible


func _pressed() -> void:
    is_secret = !is_secret
    update_nodes()
    update_icon()


