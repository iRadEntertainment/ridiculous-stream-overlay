shader_type canvas_item;

uniform sampler2D gradient2D;

void fragment() {
	COLOR.rgb = mix(COLOR.rgb, texture(gradient2D, UV).rgb, 0.5);
	COLOR.a = min(COLOR.a, texture(gradient2D, UV).a);
}
