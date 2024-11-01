shader_type canvas_item;

uniform vec4 colour : source_color;
uniform float strength = 4.0;
uniform sampler2D noise;



void fragment() {
	float noise_value = texture( noise, vec2(fract(TIME), UV.y) ).r;
	//noise_value = 1.0;
	if (texture(TEXTURE, UV).a <= 0.1) {
		float dist_to_mid = abs(UV.y - 0.5) * 2.0;
		float outline_a = colour.a * (strength * noise_value * (1.0 - dist_to_mid) * (1.0 - dist_to_mid));
		COLOR = vec4(colour.rgb, outline_a);
		//COLOR = vec4(outline_a);
	}
	//COLOR = texture(TEXTURE, vec2(UV.x - TIME, UV.y));
}
