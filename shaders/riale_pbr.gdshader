shader_type canvas_item;

uniform float normal_strength : hint_range(0.0, 5.0) = 2.0;
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 0.85);
uniform float outline_threshold : hint_range(0.0, 1.0) = 0.15;
uniform float sample_radius : hint_range(0.0, 5.0) = 1.0;

void fragment() {
	vec4 base = texture(TEXTURE, UV);

	if (base.a < 0.001) {
		COLOR = vec4(0.0);
	} else {
		vec2 px = TEXTURE_PIXEL_SIZE * sample_radius;

		float a_l = texture(TEXTURE, UV + vec2(-px.x, 0.0)).a;
		float a_r = texture(TEXTURE, UV + vec2(px.x, 0.0)).a;
		float a_u = texture(TEXTURE, UV + vec2(0.0, -px.y)).a;
		float a_d = texture(TEXTURE, UV + vec2(0.0, px.y)).a;

		vec3 nml;
		nml.x = (a_l - a_r) * normal_strength;
		nml.y = (a_u - a_d) * normal_strength;
		nml.z = 1.0;
		NORMAL = normalize(nml) * 0.5 + 0.5;

		float edge = 0.0;
		if (a_l < outline_threshold) { edge = 1.0; }
		if (a_r < outline_threshold) { edge = 1.0; }
		if (a_u < outline_threshold) { edge = 1.0; }
		if (a_d < outline_threshold) { edge = 1.0; }

		if (edge < 0.5) {
			float a_ul = texture(TEXTURE, UV + vec2(-px.x, -px.y)).a;
			float a_ur = texture(TEXTURE, UV + vec2(px.x, -px.y)).a;
			float a_dl = texture(TEXTURE, UV + vec2(-px.x, px.y)).a;
			float a_dr = texture(TEXTURE, UV + vec2(px.x, px.y)).a;
			if (a_ul < outline_threshold) { edge = 1.0; }
			if (a_ur < outline_threshold) { edge = 1.0; }
			if (a_dl < outline_threshold) { edge = 1.0; }
			if (a_dr < outline_threshold) { edge = 1.0; }
		}

		COLOR = mix(base, outline_color, edge);
		COLOR.a = base.a;
	}
}
