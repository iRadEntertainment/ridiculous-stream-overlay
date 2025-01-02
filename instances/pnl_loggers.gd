extends PanelContainer

var settings: RSSettings

func start() -> void:
    populate_list()


func populate_list() -> void:
    # reset the container with the check boxes for each logger
    for child in %flow.get_children():
        child.queue_free()
    
    for logger_name in RSSettings.ALL_LOGGERS:
        var ck := CheckBox.new()
        ck.text = logger_name
        ck.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        ck.button_pressed = logger_name in settings.log_enabled
        ck.toggled.connect(_ck_logger_toggled.bind(logger_name))
        %flow.add_child(ck)

    show()


func _ck_logger_toggled(toggled: bool, logger_name: String) -> void:
    if toggled:
        if !settings.log_enabled.has(logger_name):
            settings.log_enabled.append(logger_name)
    else:
        if settings.log_enabled.has(logger_name):
            settings.log_enabled.erase(logger_name)