@tool
extends PanelContainer

@export var do_populate := false:
	set(val):
		do_populate = val
		if is_node_ready():
			_populate_all()


func _populate_all() -> void:
	_populate_scopes()


func _populate_scopes() -> void:
	for child in %cnt_scopes.get_children():
		child.queue_free()
	
	var dic: Dictionary = TwitchScopes.get_grouped_scopes()
	
	for category: String in dic:
		var pnl := PanelContainer.new()
		var vb := VBoxContainer.new()
		pnl.name = "pnl_%s" % category
		vb.name = "vb_%s" % category
		var lb := Label.new()
		lb.name = "lb_cat_title"
		lb.text = category
		lb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vb.add_child(lb)
		vb.add_child(HSeparator.new())
		pnl.add_child(vb)
		%cnt_scopes.add_child(pnl)
		pnl.owner = self
		vb.owner = self
		lb.owner = self
		for scope: TwitchScopes.Scope in dic[category]:
			var ck := CheckBox.new()
			ck.text = scope.value
			ck.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			vb.add_child(ck)
			ck.owner = self
			
