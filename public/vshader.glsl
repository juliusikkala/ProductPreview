#version 300 es
in vec4 pos;
out vec2 uv;

void main() {
    uv = (vec2(pos.x, -pos.y)+1.0)/2.0;
    gl_Position = pos;
}
