static func generate_enums(protocol_json_path: String, output_to_path: String) -> void:
	var protocol := FileAccess.open(protocol_json_path, FileAccess.READ).get_as_text()
	var protocol_json: Dictionary = JSON.parse_string(protocol)
	var res := "# This file is automatically generated, please do not change it. If you wish to edit it, check /addons/deckobsws/Utility/EnumGen.gd\n\n"
	for e in protocol_json.enums:
		# if all are deprecated, don't make the enum
		var deprecated_count: int
		for enumlet in e.enumIdentifiers:
			if enumlet.deprecated:
				deprecated_count += 1

		if deprecated_count == e.enumIdentifiers.size():
			continue

		res += "enum %s {\n" % e.enumType

		for enumlet in e.enumIdentifiers:
			var enumlet_value: int

			match typeof(enumlet.enumValue):
				TYPE_FLOAT:
					enumlet_value = int(enumlet.enumValue)
				TYPE_STRING when "<<" in enumlet.enumValue:
					enumlet_value = tokenize_lbitshift(enumlet.enumValue)
				TYPE_STRING when "|" in enumlet.enumValue:
					var token: String = (enumlet.enumValue as String)\
						.trim_prefix("(")\
						.trim_suffix(")")
					var split := Array(token.split("|")).map(
						func(x: String):
							return x.strip_edges()
							)
					var calc: int
					for enum_partial in e.enumIdentifiers:
						if enum_partial.enumIdentifier not in split:
							continue

						calc |= tokenize_lbitshift(enum_partial.enumValue)
					enumlet_value = calc
				TYPE_STRING:
					enumlet_value = int(enumlet.enumValue)

			res += "\t%s = %s,\n" % [
				(enumlet.enumIdentifier as String).to_snake_case().to_upper(),
				enumlet_value
				]

		res += "}\n\n\n"

	var result_file := FileAccess.open(output_to_path, FileAccess.WRITE)
	result_file.store_string(res.strip_edges() + "\n")


static func tokenize_lbitshift(s: String) -> int:
	var tokens := Array(s\
		.trim_prefix("(")\
		.trim_suffix(")")\
		.split("<<")).map(
			func(x: String):
				return int(x)
				)

	return tokens[0] << tokens [1]