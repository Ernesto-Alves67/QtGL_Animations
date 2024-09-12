#version 330 core

uniform float time;        // Uniform para o tempo
uniform vec2 u_resolution; // Uniform para a resolução

// Paleta de cores baseada no artigo de Inigo Quilez: https://iquilezles.org/articles/palettes/
vec3 palette( float t ) {
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1.0, 1.0, 1.0);
    vec3 d = vec3(0.263, 0.416, 0.557);
    
    return a + b * cos(6.28318 * (c * t + d));
}

// Função principal para renderizar a imagem
void main() {
    // Coordenadas da fragmentação
    vec2 uv = (gl_FragCoord.xy * 2.0 - u_resolution.xy) / u_resolution.y;
    vec2 uv0 = uv;
    vec3 finalColor = vec3(0.0);
    
    // Loop para gerar efeitos visuais
    for (float i = 0.0; i < 4.0; i++) {
        // Transformações para efeito de distorção
        uv = fract(uv * 2.5) - 0.5;

        // Cálculo da distância para criar o efeito
        float d = length(uv) * exp(-length(uv0));

        // Aplicação da paleta de cores
        vec3 col = palette(length(uv0) + i * 0.4 + time * 0.4);

        // Modificação da distância para criar padrões
        d = sin(d * 8.0 + time) / 8.0;
        d = abs(d);

        // Ajuste de intensidade
        d = pow(0.01 / d, 1.2);

        // Adição da cor ao resultado final
        finalColor += col * d;
    }

    // Definir a cor do fragmento
    gl_FragColor = vec4(finalColor, 1.0);
}
