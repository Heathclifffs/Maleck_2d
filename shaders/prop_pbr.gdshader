shader_type canvas_item;

uniform float edge_strength : hint_range(0.0, 5.0) = 1.5;
uniform float bump_strength : hint_range(0.0, 3.0) = 1.0;
uniform float rim_strength : hint_range(0.0, 1.0) = 0.35;
uniform float rim_power : hint_range(1.0, 8.0) = 3.0;

void fragment() {
	vec4 base = texture(TEXTURE, UV);

	if (base.a < 0.001) {
		COLOR = vec4(0.0);
	} else {
		vec2 px = TEXTURE_PIXEL_SIZE;

		float a_l = texture(TEXTURE, UV + vec2(-px.x, 0.0)).a;
		float a_r = texture(TEXTURE, UV + vec2(px.x, 0.0)).a;
		float a_u = texture(TEXTURE, UV + vec2(0.0, -px.y)).a;
		float a_d = texture(TEXTURE, UV + vec2(0.0, px.y)).a;

		vec3 nml = vec3(0.0, 0.0, 1.0);
		nml.x += (a_l - a_r) * edge_strength;
		nml.y += (a_u - a_d) * edge_strength;

		float l = dot(base.rgb, vec3(0.299, 0.587, 0.114));
		float l_l = dot(texture(TEXTURE, UV + vec2(-px.x, 0.0)).rgb, vec3(0.299, 0.587, 0.114));
		float l_r = dot(texture(TEXTURE, UV + vec2(px.x, 0.0)).rgb, vec3(0.299, 0.587, 0.114));
		float l_u = dot(texture(TEXTURE, UV + vec2(0.0, -px.y)).rgb, vec3(0.299, 0.587, 0.114));
		float l_d = dot(texture(TEXTURE, UV + vec2(0.0, px.y)).rgb, vec3(0.299, 0.587, 0.114));

		nml.x += (l_l - l_r) * bump_strength;
		nml.y += (l_u - l_d) * bump_strength;

		NORMAL = normalize(nml) * 0.5 + 0.5;
		COLOR = vec4(base.rgb, base.a);
	}
}

void light() {
	float rim = 1.0 - abs(dot(NORMAL, normalize(LIGHT_DIRECTION)));
	rim = pow(rim, rim_power);
	LIGHT.rgb += LIGHT.rgb * rim * rim_strength * LIGHT.a;
}
