#version 300 es
precision mediump float;

uniform sampler2D base_tex;
uniform sampler2D metallic_tex;
uniform sampler2D uv_mask_tex;
uniform sampler2D user_tex;
in vec2 uv;
out vec4 out_color;

vec4 userRead(vec2 uv) {
    vec2 local_uv = ((uv*2.0f - 1.0f)*1.2f)*vec2(0.5f, -0.5f) + 0.5f;
    if(local_uv.x < 0.0 || local_uv.x > 1.0 || local_uv.y < 0.0 || local_uv.y > 1.0)
        return vec4(0);
    vec4 col = textureLod(user_tex, local_uv.xy, 0.0);
    return col;
}

void main() {
    ivec2 p = ivec2(gl_FragCoord.xy);
    p.y = textureSize(base_tex, 0).y-1-p.y;
    vec4 base_col = texelFetch(base_tex, p, 0);
    vec4 metallic_col = texelFetch(metallic_tex, p, 0);

    vec3 uv0 = texelFetch(uv_mask_tex, p*2+ivec2(0, 0), 0).rga;
    vec3 uv1 = texelFetch(uv_mask_tex, p*2+ivec2(1, 0), 0).rga;
    vec3 uv2 = texelFetch(uv_mask_tex, p*2+ivec2(0, 1), 0).rga;
    vec3 uv3 = texelFetch(uv_mask_tex, p*2+ivec2(1, 1), 0).rga;

    float sum_mask = uv0.b + uv1.b + uv2.b + uv3.b;
    vec4 avg_color = vec4(0);
    if(uv0.b > 0.0)
    {
        vec4 col = userRead(uv0.xy);
        avg_color += vec4(pow(col.rgb, vec3(2.2)), col.a);
    }

    if(uv1.b > 0.0)
    {
        vec4 col = userRead(uv1.xy);
        avg_color += vec4(pow(col.rgb, vec3(2.2)), col.a);
    }

    if(uv2.b > 0.0)
    {
        vec4 col = userRead(uv2.xy);
        avg_color += vec4(pow(col.rgb, vec3(2.2)), col.a);
    }

    if(uv3.b > 0.0) 
    {
        vec4 col = userRead(uv3.xy);
        avg_color += vec4(pow(col.rgb, vec3(2.2)), col.a);
    }

    if(sum_mask > 0.0)
        avg_color /= sum_mask;

    vec4 composite = mix(base_col, metallic_col * avg_color, avg_color.a);
    out_color = vec4(pow(composite.rgb, vec3(1.0/2.2)), 1.0);
}

