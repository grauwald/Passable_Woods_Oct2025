#ifdef GL_ES
precision highp float;
#endif

// Type of shader expected by Processing
#define PROCESSING_COLOR_SHADER

#define PI 3.1415926535897932384626433832795

uniform float time;
uniform vec2 center;
uniform float maxRadius;
uniform bool faded;

uniform sampler2D canvas;
uniform vec2 canvasSize;


float luminance(vec3 color) {
    // Calculate luminance using the Rec. 709 formula
    return dot(color, vec3(0.2126, 0.7152, 0.0722));
}


//	Simplex 3D Noise 
//	by Ian McEwan, Stefan Gustavson (https://github.com/stegu/webgl-noise)
//
vec4 permute(vec4 x){return mod(((x*34.0)+1.0)*x, 289.0);}
vec4 taylorInvSqrt(vec4 r){return 1.79284291400159 - 0.85373472095314 * r;}

float snoise(vec3 v){ 
  const vec2  C = vec2(1.0/6.0, 1.0/3.0) ;
  const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);

// First corner
  vec3 i  = floor(v + dot(v, C.yyy) );
  vec3 x0 =   v - i + dot(i, C.xxx) ;

// Other corners
  vec3 g = step(x0.yzx, x0.xyz);
  vec3 l = 1.0 - g;
  vec3 i1 = min( g.xyz, l.zxy );
  vec3 i2 = max( g.xyz, l.zxy );

  //  x0 = x0 - 0. + 0.0 * C 
  vec3 x1 = x0 - i1 + 1.0 * C.xxx;
  vec3 x2 = x0 - i2 + 2.0 * C.xxx;
  vec3 x3 = x0 - 1. + 3.0 * C.xxx;

// Permutations
  i = mod(i, 289.0 ); 
  vec4 p = permute( permute( permute( 
             i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
           + i.y + vec4(0.0, i1.y, i2.y, 1.0 )) 
           + i.x + vec4(0.0, i1.x, i2.x, 1.0 ));

// Gradients
// ( N*N points uniformly over a square, mapped onto an octahedron.)
  float N = 11.0; // N=7
  float n_ = 1.0/N; // N=7
  vec3  ns = n_ * D.wyz - D.xzx;

  vec4 j = p - (N*N) * floor(p * ns.z *ns.z);  //  mod(p,N*N)

  vec4 x_ = floor(j * ns.z);
  vec4 y_ = floor(j - N * x_ );    // mod(j,N)

  vec4 x = x_ *ns.x + ns.yyyy;
  vec4 y = y_ *ns.x + ns.yyyy;
  vec4 h = 1.0 - abs(x) - abs(y);

  vec4 b0 = vec4( x.xy, y.xy );
  vec4 b1 = vec4( x.zw, y.zw );

  vec4 s0 = floor(b0)*2.0 + 1.0;
  vec4 s1 = floor(b1)*2.0 + 1.0;
  vec4 sh = -step(h, vec4(0.0));

  vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
  vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

  vec3 p0 = vec3(a0.xy,h.x);
  vec3 p1 = vec3(a0.zw,h.y);
  vec3 p2 = vec3(a1.xy,h.z);
  vec3 p3 = vec3(a1.zw,h.w);

//Normalise gradients
  vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;

// Mix final noise value
  vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
  m = m * m;
  return 42.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1), 
                                dot(p2,x2), dot(p3,x3) ) );
}



float random (in vec2 _st) {
    return fract(sin(dot(_st.xy,
        // vec2(7.9898,11.233)))*
        // 18758.5453123);
        vec2(12.9898,78.233)))*
        43758.5453123);
}

// Based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
float noise (in vec2 _st) {
    vec2 i = floor(_st);
    vec2 f = fract(_st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

#define NUM_OCTAVES 7

float fbm ( in vec2 _st) {
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100.0);
    // Rotate to reduce axial bias
    mat2 rot = mat2(cos(0.5), sin(0.5),
                    -sin(0.5), cos(0.50));
    for (int i = 0; i < NUM_OCTAVES; ++i) {
        v += a * noise(_st);
        _st = rot * _st * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}


// Convert HSV to RGB
vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}


vec3 brightnessContrast(vec3 value, float brightness, float contrast) 
{     
  return (value - 0.5) * contrast + 0.5 + brightness; 
}  



void main(void) {
    // canvas does not match screen size
    vec2 st = gl_FragCoord.xy / vec2(textureSize(canvas, 0));
    
    vec4 canvasColor = texture2D(canvas, st); // get color from canvas
    float lumin = luminance(canvasColor.rgb); // calculate luminance from canvas color

    // lumin modulation
    // float luminMod = fbm(gl_FragCoord.xy * 0.0512317 + time *sin(lumin*PI*.09 + time*.00001)* 0.7 +lumin * 0.1); ;
    // lumin *= luminMod; // modulate luminance with noise

    // brightness
    float slowTime = time * 0.04;
    float clouds = fbm(gl_FragCoord.xy * 0.0015115 + slowTime + vec2( sin(time * 0.000514739)*1.75 + lumin * .044, cos(time * 0.00141297471)*.5 ) * lumin * .2  );
    float cloudsTime = fbm(gl_FragCoord.xy * 0.0012317 + slowTime * clouds * .1 + vec2( cos(time * 0.000214739)*2.5 + lumin * clouds * .01, sin(time * 0.0017197471)*.5 ) * lumin * .3  );

    vec2 vStretch = vec2( gl_FragCoord.x * 1.0, gl_FragCoord.y );
    float v = (snoise(
        vec3(vStretch * 0.0005751417, cos(sin(time * 0.141545) + cos(time * .05321)) * cloudsTime * .5 ) +
        vec3(vStretch * 0.000613514123, sin(cos(time * 0.131411) + sin(time * .04762)) * cloudsTime * .5)
    ) + 1.0) * 0.75;

    // v *= (snoise(
    //     vec3(vStretch * 0.00087643 * lumin, cos(time * 0.147) * v) +
    //     vec3(vStretch * 0.0009321 * lumin, sin(time * 0.014401) * v)
    // ) + 1.0) * 0.75;

    v *= clouds * 0.75 + 0.25; // modulate brightness with clouds

    // v *= 1.125;

    // float v = 1.0;

    if(faded) {
      // fade out towards the edges
      float fadeStart = maxRadius * 0.8;
      float fadeEnd = maxRadius;
      float dist = distance(gl_FragCoord.xy, center);
      float fade = 1.0;
      if (dist > fadeStart) {
          fade = 1.0 - (dist - fadeStart) / (fadeEnd - fadeStart);
          fade += fbm(gl_FragCoord.xy *.0001 + time * 0.01 )*.75; 
          fade = clamp(fade, 0.0, 1.0);
      }
      v *= fade;
    }

    // hue
    vec2 hStretch = vec2( gl_FragCoord.x * 0.027, gl_FragCoord.y * 0.017 );
    float hMod = v +  sin(time * 0.01) * clouds; // modulate hue with brightness and time
    float h = snoise(
        vec3(hStretch * 0.00178431 * hMod * v * lumin , sin(time * 0.025) + (cloudsTime  * .041) ) +
        vec3(hStretch * 0.004721 * hMod * v * lumin, cos(time * 0.01) + (cloudsTime * .051)) +
        vec3(hStretch * 0.013721 * hMod * v, sin(time * 0.04123) + (cloudsTime * .061))
    );
    h *= clouds * 0.5 + 0.5; // modulate hue with clouds


    // saturation
    vec2 sStretch = vec2( gl_FragCoord.x * 0.07, gl_FragCoord.y );
    float s = snoise(
        vec3(sStretch * 0.002 * v + clouds, sin(time * 0.05) * cloudsTime )
    );
    s = s*0.05 + 0.05; 


    // RGB conversion and output
    vec3 rgb = hsv2rgb(vec3(h, s, v));
    rgb = brightnessContrast(rgb, 0.00, 2.0); // adjust brightness and contrast

    rgb *= lumin; // apply luminance to the final color
    // rgb =vec3(lumin);

    gl_FragColor = vec4(rgb, 1.0);
}