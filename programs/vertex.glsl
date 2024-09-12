#version 330

in vec2 in_vert;  // Alterado de 'in_vert' para 'in_position'

uniform float time;

/*void main() {
    vec2 position = in_vert;
      // Movendo a posição ao longo do tempo
    gl_Position = vec4(position, 0.0, 1.0);
    //vec2 position = in_vert;
    //gl_Position = vec4(position, 0.0, 1.0);  // A posição permanece fixa
}
void main() {
    // Rotacionar a posição ao longo do tempo
    float angle = time;  // Definir o ângulo com base no tempo
    mat2 rotation = mat2(cos(angle), -sin(angle),
                         sin(angle), cos(angle));  // Matriz de rotação

    vec2 position = rotation * in_vert;  // Aplicar rotação aos vértices

    gl_Position = vec4(position, 0.0, 1.0);
}

void main() {
    // Criar um efeito de pulsação
    float scale = 1.0 + 0.5 * sin(time);  // Escalonar suavemente entre 0.5 e 1.5
    vec2 position = in_vert * scale;      // Aplicar o escalonamento

    gl_Position = vec4(position, 0.0, 1.0);
}*/
void main() {
    // Criar movimento circular
    vec2 offset = vec2(cos(time), sin(time)) * 4.5;  // Coordenadas circulares

    vec2 position = in_vert + offset;  // Adicionar o deslocamento circular à posição do vértice

    gl_Position = vec4(position, 0.0, 1.0);
}