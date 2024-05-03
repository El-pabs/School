#version 330

uniform sampler2D surface;

out vec4 f_color;
in vec2 uv;

void main() {
  f_color = vec4(texture(surface, uv).rgb, 1.0);
}
