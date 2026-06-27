shader_type canvas_item;

uniform float edge_strength : hint_range(0.0, 5.0) = 1.2;
uniform float bump_strength : hint_range(0.0, 3.0) = 1.5;
uniform float dome_strength : hint_range(0.0, 2.0) = 0.6;
uniform float ao_depth : hint_range(0.0, 1.0) = 0.3;

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

		vec2 center = UV - vec2(0.5, 0.5);
		float dist = length(center);
		nml.x += center.x * dist * dome_strength;
		nml.y += center.y * dist * dome_strength;

		NORMAL = normalize(nml) * 0.5 + 0.5;

		float edge_ao = 1.0 - (1.0 - smoothstep(0.3, 0.9, base.a)) * ao_depth;
		COLOR = vec4(base.rgb * edge_ao, base.a);
	}
}
