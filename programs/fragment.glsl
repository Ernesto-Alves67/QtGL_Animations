#version 330

uniform vec2 u_resolution;  // Resolução da tela
uniform float time;         // Tempo para a animação
uniform vec2 u_mouse;       // Coordenadas do mouse

#define R3 1.732051

out vec4 fragColor;  // Declarar a saída do fragmento de cor

vec4 HexCoords(vec2 uv) {
    vec2 s = vec2(1, R3);
    vec2 h = .4 * s;

    vec2 gv = s * uv;
    vec2 a = mod(gv, s) - h;
    vec2 b = mod(gv + h, s) - h;

    vec2 ab = dot(a, a) < dot(b, b) ? a : b;
    vec2 st = ab;
    vec2 id = gv - ab;

    return vec4(st, id);
}

float GetSize(vec2 id, float seed) {
    float d = length(id);
    float t = time * .5;
    float a = sin(d * seed + t) + sin(d * seed * seed * 10. + t * 2.);
    return a / 2. + .5;
}

vec3 GetRayDir(vec2 uv, vec3 p, vec3 lookat, float zoom) {
    vec3 f = normalize(lookat - p);
    vec3 r = normalize(cross(vec3(0, 1, 0), f));
    vec3 u = cross(f, r);
    vec3 c = p + f * zoom;
    vec3 i = c + uv.x * r + uv.y * u;
    return normalize(i - p);
}

mat2 Rot(float a) {
    float s = sin(a);
    float c = cos(a);
    return mat2(c, -s, s, c);
}

float Hexagon(vec2 uv, float r, vec2 offs) {
    uv *= Rot(mix(0., 3.1415, r));

    r /= 1. / sqrt(2.);
    uv = vec2(-uv.y, uv.x);
    uv.x *= R3;
    uv = abs(uv);

    vec2 n = normalize(vec2(1, 1));
    float d = dot(uv, n) - r;
    d = max(d, uv.y - r * .507);

    d = smoothstep(.06, .02, abs(d));
    d += smoothstep(.1, .09, abs(r - .9)) * sin(time);
    return d;
}

float Xor(float a, float b) {
    return a + b;
}

float Layer(vec2 uv, float s) {
    vec4 hu = HexCoords(uv * 2.);

    float d = Hexagon(hu.xy, GetSize(hu.zw, s), vec2(0));
    vec2 offs = vec2(1, 0);
    d = Xor(d, Hexagon(hu.xy - offs, GetSize(hu.zw + offs, s), offs));
    d = Xor(d, Hexagon(hu.xy + offs, GetSize(hu.zw - offs, s), -offs));
    offs = vec2(.5, .8725);
    d = Xor(d, Hexagon(hu.xy - offs, GetSize(hu.zw + offs, s), offs));
    d = Xor(d, Hexagon(hu.xy + offs, GetSize(hu.zw - offs, s), -offs));
    offs = vec2(-.5, .8725);
    d = Xor(d, Hexagon(hu.xy - offs, GetSize(hu.zw + offs, s), offs));
    d = Xor(d, Hexagon(hu.xy + offs, GetSize(hu.zw - offs, s), -offs));
    offs = vec2(-.5, .825);
    return d;
}

float N(float p) {
    return fract(sin(p * 123.34) * 345.456);
}

vec3 Col(float p, float offs) {
    float n = N(p) * 334.34;

    return sin(n * vec3(2.23, 45.23, 6.2) + offs * 3.) * .5 + .5;
}

void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution) / u_resolution.y;  // UV normalizado para a resolução
    vec2 UV = gl_FragCoord.xy / u_resolution.xy - 0.5;  // UV baseado na tela
    float duv = dot(UV, UV);  // Distância ao centro da tela

    vec2 m = u_mouse - 0.5;  // Adaptação do iMouse.xy para u_mouse
    //float t = time * 0.2 + m.x * 10.0 + 5.0;
    float t = time * .2 + 5.;  // Usando o tempo uniformizado
    float y = sin(t*.5);//+sin(1.5 * t) / 3.;

    vec3 ro = vec3(0, 50. * y, -5);  // Posição do observador
    vec3 lookat = vec3(0, 0, -10);  // Ponto de foco
    vec3 rd = GetRayDir(uv, ro, lookat, 1.);  // Direção do raio

    vec3 col = vec3(0);

    vec3 p = ro + rd * (ro.y / rd.y);  // Ponto de interseção com o plano
    float dp = length(p.xz);  // Distância do ponto ao centro

    if ((ro.y / rd.y) > 0.) {
        col *= 0.1;  // Se estiver acima do plano, nenhuma cor
    } else {
        uv = p.xz * .1;
        uv *= mix(1., 5., sin(t * .5) * .5 + .5);  // Escalamento do UV com o tempo
        uv *= Rot(t);  // Rotação do UV
        for (float i = 0.; i < 1.; i += 1. / 3.) {
            float id = floor(i + t);
            float z = mix(5., .1, fract(i + t));
            float fade = smoothstep(0., .3, fract(i + t)) * smoothstep(1., .7, fract(i + t));
            col += fade * Layer(uv * z, N(i + id)) * Col(id, duv);
        }
    }

    col *= 2.;
    if (ro.y < 0.) col = 1. - col;  // Inverte as cores se estiver abaixo do plano
    //col *= smoothstep(18., 5., dp);  // Suavização das cores
    col *= 1. - duv * 2.;  // Atenuação baseada na distância do centro da tela

    fragColor = vec4(col, 1.0);  // Atribuir cor final
}