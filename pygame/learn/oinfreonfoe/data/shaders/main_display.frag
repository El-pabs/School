#version 330

const int max_lights = 16;

uniform sampler2D surface;
uniform sampler2D canvas;
uniform sampler2D noise;
uniform sampler2D world_mask;
uniform sampler2D ui;
uniform sampler2D end_tex;
uniform ivec2 pixel_dimensions;
uniform ivec2 scroll;
uniform float time;
uniform float ending;
uniform vec3 lights[max_lights];
uniform ivec2 window_dimensions;

const ivec2 surround_offsets[4] = ivec2[4] (ivec2(-1.0, 0), ivec2(1.0, 0), ivec2(0, -1.0), ivec2(0, -2.0));
const float canvas_scale = 3.0f;
const float noise_scale = 0.005f;
const float aspect_ratio = 4.0f / 3.0f;

out vec4 f_color;
in vec2 uv;

void main() {
  float adjusted_time = time * 0.3;

  float window_aspect_ratio = float(window_dimensions.x) / window_dimensions.y;
  float x_aspect_scale = window_aspect_ratio / aspect_ratio;
  float x_aspect_shift = (x_aspect_scale - 1) * 0.5;
  vec2 uv_adj = vec2(uv.x * x_aspect_scale - x_aspect_shift, uv.y);
  float is_border = min(1, (1 - step(0.0, uv_adj.x)) + step(1.0, uv_adj.x));

  ivec2 canvas_tex_size = textureSize(canvas, 0);
  ivec2 sample_pos = ivec2(uv_adj.x * pixel_dimensions.x + scroll.x, uv_adj.y * pixel_dimensions.y + scroll.y);
  ivec2 sample_pos_parallax = ivec2(uv_adj.x * pixel_dimensions.x + scroll.x * 1.25, uv_adj.y * pixel_dimensions.y + scroll.y * 1.25);
  vec3 display_sample = texture(surface, uv_adj).rgb;
  vec4 ui_sample = texture(ui, uv_adj);
  vec2 canvas_uv_adj = vec2(float(sample_pos.x) / canvas_tex_size.x * canvas_scale, float(sample_pos.y) / canvas_tex_size.y * canvas_scale);
  float canvas_color = texture(canvas, canvas_uv_adj).r;

  vec2 noise_pos1 = vec2(sample_pos_parallax.x * noise_scale * 0.5 - adjusted_time * 0.02, sample_pos_parallax.y * noise_scale + cos(adjusted_time * 0.07) * 0.1);
  vec2 noise_pos2 = vec2(sample_pos.x * noise_scale + sin(adjusted_time * 0.05) * 0.1, sample_pos.y * noise_scale * 3 + cos(adjusted_time * 0.05) * 0.1);
  vec2 noise_pos3 = vec2(sample_pos_parallax.x * noise_scale * 0.3 - adjusted_time * 0.035, sample_pos_parallax.y * noise_scale * 0.8 + cos(adjusted_time * 0.09 + 0.3) * 0.1);
  float noise_val = texture(noise, noise_pos3).r * 0.7 + texture(noise, noise_pos1).r * 0.2 + texture(noise, noise_pos2).r * 0.1;
  float noise_level = min(1, max(0, noise_val - 0.5) * 8);

  vec2 shadow_noise_pos = vec2(sample_pos.x * noise_scale * 2 + adjusted_time * 0.1, sample_pos.y * noise_scale * 2);
  float shadow_strength = texture(noise, shadow_noise_pos).r;

  float is_background = 1.0 - step(0.001, display_sample.r);
  float shadow = -0.5;
  int steps = int(shadow_strength * 22 * is_background);
  for (int i = 0; i < steps; i++) {
    int i2 = i - steps / 3;
    int i2y = i2 / 2;
    float s = step(0.001, texture(surface, vec2(uv_adj.x - float(i2y) / pixel_dimensions.x, uv_adj.y - float(i2) / pixel_dimensions.y)).r);
    shadow += s * 0.3;
  }
  shadow = max(0, min(1, shadow));
  display_sample = display_sample * (1 - shadow) + vec3(0.08627, 0.08627, 0.15294) * shadow;

  float brightness = 0;
  for (int i = 0; i < max_lights; i++) {
    vec3 light = lights[i];
    float y_dis = max(0, uv_adj.y - light.y);
    float depth_weight = max(0, 0.8 + light.z * 0.2 - y_dis) * 2;
    float x_dis = abs(light.x - (uv_adj.x - y_dis * 0.2));
    x_dis = pow(x_dis, 0.9);
    float active_light = step(0, light.z);
    float light_width_base = 0.11 + sin(adjusted_time + light.z * 1.3) * 0.05;
    depth_weight = max(0, depth_weight + cos(adjusted_time + light.z * 1.3) * 0.05);
    float light_brightness_base = max(0, pow((3 - light.z), 2) * 0.05 + 0.2 + sin(adjusted_time * 2.7 + light.z * 1.7) * 0.2);
    brightness += min(light_brightness_base, max(0, (light_width_base * (1 + light.z * 0.1) - x_dis) * 52 * depth_weight * light_brightness_base)) * active_light;
  }

  float background_sample_val = (texture(noise, vec2(noise_pos2.x + 0.5, noise_pos2.y + 0.2)).r - 0.5) * 3 + 0.5;
  vec3 background_color = vec3(0.09412, 0.64314, 0.90588) * background_sample_val + vec3(0.11765, 0.41176, 0.63529) * (1 - background_sample_val);
  display_sample += background_color * is_background * (1 - shadow);

  display_sample = display_sample * (1.0 - noise_level) + vec3(0.93, 0.92, 0.85) * noise_level;

  float adjusted_brightness = brightness * (abs(0.6 - is_background) * ((display_sample.g + display_sample.b) * 0.3 + 0.2));
  display_sample = display_sample * (1.0 - adjusted_brightness * 0.3) + adjusted_brightness * vec3(1.0, 0.9, 0.4);

  float mask_value = texture(world_mask, uv_adj).r;
  float mask_set = step(0.001, mask_value);
  vec3 mask_color = vec3(0.95294, 0.95294, 0.85);
  float bordering_mask = 0;
  for (int i = 0; i < 4; i++) {
    vec2 offset = surround_offsets[i];
    vec2 mask_lookup = vec2(uv_adj.x + offset.x / pixel_dimensions.x, uv_adj.y + offset.y / pixel_dimensions.y);
    bordering_mask += step(0.15, texture(world_mask, mask_lookup).r);
  }
  bordering_mask = min(1, bordering_mask);
  float valid_border = bordering_mask * (1 - mask_set);
  mask_color = valid_border * vec3(0.8, 0.8, 0.7) + (1 - valid_border) * mask_color;
  display_sample = display_sample * mask_value + mask_color * (1 - mask_value);

  vec3 render_color = display_sample * canvas_color;

  float center_dis = distance(uv_adj, vec2(0.5, 0.5));
  float desaturate = max(0, (center_dis - 0.45) * 5) + texture(noise, noise_pos1).r - 0.5;
  render_color = render_color * (1 - desaturate) + vec3(0.8, 0.8, 0.7) * desaturate;

  render_color = render_color * (1 - ui_sample.a) + ui_sample.rgb * ui_sample.a * render_color;

  vec3 end_sample = texture(end_tex, uv_adj).rgb;
  render_color = end_sample * ending + render_color * (1 - ending);

  render_color = vec3(0.0, 0.0, 0.0) * is_border + render_color * (1 - is_border);

  f_color = vec4(render_color, 1.0);
}
