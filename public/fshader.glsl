#version 300 es
precision mediump float;

uniform sampler2D diffuse_tex;
uniform sampler2D glossy_tex;
uniform sampler2D uv_mask_tex;
uniform sampler2D user_tex;
in vec2 uv;
out vec4 out_color;

void main() {
    ivec2 p = ivec2(gl_FragCoord.xy);
    p.y = textureSize(diffuse_tex, 0).y-1-p.y;
    vec4 diffuse_col = texelFetch(diffuse_tex, p, 0);
    vec4 glossy_col = texelFetch(glossy_tex, p, 0);

    vec3 uv0 = texelFetch(uv_mask_tex, p*2+ivec2(0, 0), 0).rga;
    vec3 uv1 = texelFetch(uv_mask_tex, p*2+ivec2(1, 0), 0).rga;
    vec3 uv2 = texelFetch(uv_mask_tex, p*2+ivec2(0, 1), 0).rga;
    vec3 uv3 = texelFetch(uv_mask_tex, p*2+ivec2(1, 1), 0).rga;

    float sum_mask = uv0.b + uv1.b + uv2.b + uv3.b;
    vec2 avg_uv = uv0.rg * uv0.b + uv1.rg * uv1.b + uv2.rg * uv2.b + uv3.rg * uv3.b;

    vec4 diffuse = vec4(1);

    if(sum_mask > 0.0)
    {
        avg_uv /= sum_mask;
        avg_uv = avg_uv.yx;
        vec4 user_col = texture(user_tex, avg_uv);
        diffuse = vec4(user_col.rgb * user_col.a, 1.0);
    }

    vec4 composite = diffuse_col * diffuse + glossy_col;

    out_color = vec4(pow(composite.rgb, vec3(1.0/2.2)), 1.0);
}
