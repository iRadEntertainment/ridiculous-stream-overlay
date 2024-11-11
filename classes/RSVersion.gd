class_name RSVersion
extends RefCounted

var major := 0
var minor := 0
var revision := 0
var patch := 0
var tag := &""
var original := &""

func _init(
	p_major: int = 0,
	p_minor: int = 0,
	p_revision: int = 0,
	p_patch: int = 0,
	p_tag: String = &"",
	p_original: String = &""
) -> void:
	major = p_major
	minor = p_minor
	revision = p_revision
	patch = p_patch
	tag = p_tag
	original = p_original

func as_string() -> String:
	var version_string := "%d.%d.%d" % [major, minor, revision]
	if patch > 0:
		version_string += ".%d" % [patch]
	if !tag.is_empty():
		version_string += "-%s" % [tag]
	return version_string

func compare_to(p_other_version: RSVersion) -> int:
	var diff = major - p_other_version.major
	if diff != 0: return diff
	diff = minor - p_other_version.minor
	if diff != 0: return diff
	diff = revision - p_other_version.revision
	if diff != 0: return diff
	diff = patch - p_other_version.patch
	if diff != 0: return diff
	diff = tag.casecmp_to(p_other_version.tag)
	return diff

static func parse(p_version_string: String) -> RSVersion:
	if p_version_string.is_empty():
		return RSVersion.new()

	var tag_parts := p_version_string.split("-", false, 1)
	assert(!tag_parts.is_empty(), "Invalid version string: '%s'" % [p_version_string])

	var base_string := tag_parts[0]
	var tag := tag_parts[1] if tag_parts.size() > 1 else ""

	var base_parts := base_string.split(".", false)
	assert(!base_parts.is_empty(), "No digit segments found before a hypen: '%s'" % [p_version_string])
	assert(base_parts.size() < 5, "There should only be 4 number segments before a hyphen but found %d in '%s'" % [
		base_parts.size(),
		p_version_string
	])

	var major := int(base_parts[0])
	var minor := int(base_parts[1]) if base_parts.size() > 1 else 0
	var revision := int(base_parts[2]) if base_parts.size() > 2 else 0
	var patch := int(base_parts[3]) if base_parts.size() > 3 else 0

	return RSVersion.new(major, minor, revision, patch, tag, p_version_string)
