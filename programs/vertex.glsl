#version 330

in vec2 in_vert;  // Alterado de 'in_vert' para 'in_position'

uniform float time;

void main() {
    vec2 position = in_vert;
      // Movendo a posição ao longo do tempo
    gl_Position = vec4(position, 0.0, 1.0);
    /*vec2 position = in_vert;
    gl_Position = vec4(position, 0.0, 1.0);*/  // A posição permanece fixa
}
