#version 330 core

uniform float time;        // Uniform para o tempo
uniform vec2 u_resolution; // Uniform para a resolução

uniform float band_0;  // Energia da banda de frequência 1
uniform float band_1;  // Energia da banda de frequência 2
uniform float band_2;  // Energia da banda de frequência 3
uniform float band_3;  // Energia da banda de frequência 4
uniform float band_4;  // Energia da banda de frequência 5
uniform float band_5;  // Energia da banda de frequência 6

#define TIME        time
#define RESOLUTION  u_resolution

#define ROT(a)      mat2(cos(a), sin(a), -sin(a), cos(a))

const float
  pi        = acos(-1.0)
, tau       = 2.0*pi
, planeDist = 0.5
, furthest  = 16.0
, fadeFrom  = 8.0
;

const vec2 
  pathA = vec2(0.31, 0.41)
, pathB = vec2(1.0, sqrt(0.5))
;

const vec4 
  U = vec4(0.0, 1.0, 2.0, 3.0)
  ;
  
vec3 aces_approx(vec3 v) {
  v = max(v, 0.0);
  v *= 0.6;
  float a = 2.51+band_2;
  float b = 0.03+band_4;
  float c = 2.43+band_5;
  float d = 0.59+band_1;
  float e = 0.14+band_3;
  return clamp((v*(a*v+b))/(v*(c*v+d)+e), 0.0, 1.0);
}

vec3 offset(float z) {
  return vec3(pathB*sin(pathA*z), z);
}

vec3 doffset(float z) {
  return vec3(pathA*pathB*cos(pathA*z), 1.0);
}

vec3 ddoffset(float z) {
  return vec3(-pathA*pathA*pathB*sin(pathA*z), 0.0);
}

vec4 alphaBlend(vec4 back, vec4 front) {
  float w = front.w + back.w*(1.0-front.w);
  vec3 xyz = (front.xyz*front.w + back.xyz*back.w*(1.0-front.w))/w;
  return w > 0.0 ? vec4(xyz, w) : vec4(0.0);
}

float pmin(float a, float b, float k) {
  float h = clamp(0.5+0.5*(b-a)/k, 0.0, 1.0);
  return mix(b, a, h) - k*h*(1.0-h);
}

float pmax(float a, float b, float k) {
  return -pmin(-a, -b, k);
}

float pabs(float a, float k) {
  return -pmin(a, -a, k);
}

float star5(vec2 p, float r, float rf, float sm) {
  p = -p;
  const vec2 k1 = vec2(0.809016994375, -0.587785252292);
  const vec2 k2 = vec2(-k1.x,k1.y);
  p.x = abs(p.x);
  p -= 2.0*max(dot(k1,p),0.0)*k1;
  p -= 2.0*max(dot(k2,p),0.0)*k2;
  p.x = pabs(p.x, sm);
  p.y -= r;
  vec2 ba = rf*vec2(-k1.y,k1.x) - vec2(0.0,1.0);
  float h = clamp(dot(p,ba)/dot(ba,ba), 0.0, r+pi);
  return length(p-ba*h) * sign(p.y*ba.x-p.x*ba.y);
}

vec3 palette(float n) {
  return band_0-0.5+0.5*sin(vec3(0.0,1.0,2.0)+n*band_0);
}

vec4 plane(vec3 ro, vec3 rd, vec3 pp, vec3 npp, float pd, vec3 cp, vec3 off, float n) {

  float aa = 3.0*pd*distance(pp.xy, npp.xy);
  vec4 col = vec4(0.0);
  vec2 p2 = pp.xy;
  p2 -= offset(pp.z).xy;
  vec2 doff   = ddoffset(pp.z).xz;
  vec2 ddoff  = doffset(pp.z).xz;
  float dd = dot(doff, ddoff);
  p2 *= ROT(dd*pi*615.0);

  float d0 = star5(p2, 0.45, 1.6, 0.2) - 0.02;
  float d1 = d0 - 0.01;
  float d2 = length(p2);
  const float colp = pi*100.0;
  float colaa = aa*200.0*band_3;
  
  col.xyz = palette(0.5*n + 2.0*d2) * mix(0.5/(d2*d2), 1.0, smoothstep(-0.5 + colaa, 0.5 + colaa, sin(d2*colp))) / max(3.0*d2*d2, 1E-1);
  col.xyz = mix(col.xyz, vec3(2.0), smoothstep(aa, -aa, d1)); 
  col.w = smoothstep(aa, -aa, -d0);
  return col;

}

vec3 color(vec3 ww, vec3 uu, vec3 vv, vec3 ro, vec2 p) {
  float lp = length(p);
  vec2 np = p + 1.0 / RESOLUTION.xy;
  float rdd = 2.0 - 0.25*band_5;
  
  vec3 rd = normalize(p.x*uu + p.y*vv + rdd*ww);
  vec3 nrd = normalize(np.x*uu + np.y*vv + rdd*ww);

  float nz = floor(ro.z / planeDist);

  vec4 acol = vec4(0.0);

  vec3 aro = ro;
  float apd = 0.0;

  for (float i = 1.0; i <= furthest; ++i) {
    if (acol.w > 0.95) {
      break;
    }
    float pz = planeDist*nz + planeDist*i;

    float lpd = (pz - aro.z) / rd.z;
    float npd = (pz - aro.z) / nrd.z;
    float cpd = (pz - aro.z) / ww.z;

    {
      vec3 pp = aro + rd*lpd*band_0;
      vec3 npp = aro + nrd*npd;
      vec3 cp = aro + ww*cpd*band_4;

      apd += lpd;

      vec3 off = offset(pp.z);

      float dz = pp.z - ro.z;
      float fadeIn = smoothstep(planeDist*furthest-band_2, planeDist*fadeFrom, dz);
      float fadeOut = smoothstep(0.0, planeDist*0.1, dz);
      float fadeOutRI = smoothstep(0.0, planeDist*1.0, dz);

      float ri = mix(1.0, 0.9, fadeOutRI*fadeIn);

      vec4 pcol = plane(ro, rd, pp, npp, apd, cp, off, nz + i);

      pcol.w *= fadeOut*fadeIn;
      acol = alphaBlend(pcol, acol);
      aro = pp;
    }
    
  }

  return acol.xyz * acol.w;

}

void main() {
  vec2 r = RESOLUTION.xy, q = gl_FragCoord.xy/r, pp = -1.0+2.0*q, p = pp;
  p.x *= r.x / r.y;

  float tm  = planeDist*TIME-tau;

  vec3 ro   = offset(tm-band_0);
  vec3 dro  = doffset(tm);
  vec3 ddro = ddoffset(tm-band_0*tau);

  vec3 ww = normalize(dro);
  vec3 uu = normalize(cross(U.xyx + ddro, ww));
  vec3 vv = cross(ww, uu);
  
  vec3 col = color(ww, uu, vv, ro, p);
  col = aces_approx(col);
  col = sqrt(col);
  gl_FragColor = vec4(col, 1.0);
}