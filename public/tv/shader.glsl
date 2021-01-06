#version 300 es
precision mediump float;

uniform sampler2D base_tex;
uniform sampler2D emission_tex;
uniform sampler2D uv_mask_tex;
uniform sampler2D user_tex;
in vec2 uv;
out vec4 out_color;

void main() {
    ivec2 p = ivec2(gl_FragCoord.xy);
    p.y = textureSize(base_tex, 0).y-1-p.y;
    vec4 base_col = texelFetch(base_tex, p, 0);
    vec4 emission_col = texelFetch(emission_tex, p, 0);

    vec3 uv0 = texelFetch(uv_mask_tex, p*2+ivec2(0, 0), 0).rga;
    vec3 uv1 = texelFetch(uv_mask_tex, p*2+ivec2(1, 0), 0).rga;
    vec3 uv2 = texelFetch(uv_mask_tex, p*2+ivec2(0, 1), 0).rga;
    vec3 uv3 = texelFetch(uv_mask_tex, p*2+ivec2(1, 1), 0).rga;

    float sum_mask = uv0.b + uv1.b + uv2.b + uv3.b;
    vec3 avg_color = vec3(0);
    if(uv0.b > 0.0)
    {
        vec4 col = textureLod(user_tex, uv0.yx, 0.0);
        avg_color += pow(col.rgb, vec3(2.2)) * col.a;
    }

    if(uv1.b > 0.0)
    {
        vec4 col = textureLod(user_tex, uv1.yx, 0.0);
        avg_color += pow(col.rgb, vec3(2.2)) * col.a;
    }

    if(uv2.b > 0.0)
    {
        vec4 col = textureLod(user_tex, uv2.yx, 0.0);
        avg_color += pow(col.rgb, vec3(2.2)) * col.a;
    }

    if(uv3.b > 0.0) 
    {
        vec4 col = textureLod(user_tex, uv3.yx, 0.0);
        avg_color += pow(col.rgb, vec3(2.2)) * col.a;
    }

    float tv_brightness = 2.0;
    vec4 emit = vec4(tv_brightness * avg_color * 0.25, 1);
    vec4 user_col = tv_brightness * textureLod(user_tex, vec2(0.5), 1000.0);
    user_col.rgb *= user_col.a;

    vec4 composite = base_col + emission_col * user_col + emit;

    out_color = vec4(pow(composite.rgb, vec3(1.0/2.2)), 1.0);
}
