<script>
    import { onMount } from 'svelte';
    import { PNG } from 'pngjs/browser';
    import { Buffer } from 'buffer';

    let canvas;
    let error;

    async function getShader(gl, type, name) {
        let res = await fetch(name);
        let src = await res.text();
        let shader = gl.createShader(type);
        gl.shaderSource(shader, src);
        gl.compileShader(shader);
        if(!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
            throw new Error(`Failed to compile shader: ${gl.getShaderInfoLog(shader)}`);
        }
        return shader;
    }

    function createProgram(gl, vert, frag) {
        let program = gl.createProgram();
        gl.attachShader(program, vert);
        gl.attachShader(program, frag);
        gl.linkProgram(program);
        if(!gl.getProgramParameter(program, gl.LINK_STATUS)) {
            throw new Error(`Failed to link shader program: ${gl.getProgramInfoLog(program)}`);
        }
        return program;
    }


    async function loadTexture(gl, name) {
        let res = await fetch(name);
        let arr = await res.arrayBuffer();
        let buf = new Buffer(arr.byteLength);
        const view = new Uint8Array(arr);
        for(let i = 0; i < buf.length; ++i) {
            buf[i] = view[i];
        }

        let png = PNG.sync.read(buf, {
            filterType: -1,
            colorType: 6,
            skipRescale: true
        });

        let pixelData = new Float32Array(png.width * png.height * 4);
        let i = 0;
        for(let y = 0; y < png.height; y++) {
            for(let x = 0; x < png.width; x++) {
                pixelData[i] = png.data[i] / 65535; i++;
                pixelData[i] = png.data[i] / 65535; i++;
                pixelData[i] = png.data[i] / 65535; i++;
                pixelData[i] = png.data[i] / 65535; i++;
            }
        }

        let tex = gl.createTexture();
        gl.bindTexture(gl.TEXTURE_2D, tex);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);

        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA32F, png.width, png.height, 0, gl.RGBA, gl.FLOAT, pixelData);
        return tex;
    }

    onMount(async () => {
        const gl = canvas.getContext('webgl2');
        if(!gl) {
            error = "Unable to get a WebGL context!";
            return;
        }
        let ext = gl.getExtension("EXT_color_buffer_float");
        if(!ext) {
            error = "This demo requires EXT_color_buffer_float support.";
            return;
        }

        let frag;
        let vert;
        let prog;
        let vbo;

        try {
            let diffuseTex = await loadTexture(gl, 'diffuse_linear.png');
            let glossyTex = await loadTexture(gl, 'glossy_linear.png');
            let uvMaskTex = await loadTexture(gl, 'uv_mask.png');

            frag = await getShader(gl, gl.FRAGMENT_SHADER, 'fshader.glsl');
            vert = await getShader(gl, gl.VERTEX_SHADER, 'vshader.glsl');
            prog = createProgram(gl, vert, frag);

            vbo = gl.createBuffer();
            gl.bindBuffer(gl.ARRAY_BUFFER, vbo);
            const pos_data = [
                -1, -1,
                -1, 1,
                1, -1,
                -1, 1,
                1, -1,
                1, 1
            ]
            gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(pos_data), gl.STATIC_DRAW);
            gl.viewport(0, 0, gl.canvas.width, gl.canvas.height);

            gl.clearColor(0,0,0,1);
            gl.clear(gl.COLOR_BUFFER_BIT);
            gl.useProgram(prog);

            let posAttr = gl.getAttribLocation(prog, "pos");
            gl.enableVertexAttribArray(posAttr);
            gl.vertexAttribPointer(posAttr, 2, gl.FLOAT, false, 0, 0);
            gl.bindBuffer(gl.ARRAY_BUFFER, vbo);

            let diffuseLocation = gl.getUniformLocation(prog, "diffuse_tex");
            let glossyLocation = gl.getUniformLocation(prog, "glossy_tex");
            let uvMaskLocation = gl.getUniformLocation(prog, "uv_mask_tex");

            gl.activeTexture(gl.TEXTURE0);
            gl.bindTexture(gl.TEXTURE_2D, diffuseTex);
            gl.uniform1i(diffuseLocation, 0);

            gl.activeTexture(gl.TEXTURE1);
            gl.bindTexture(gl.TEXTURE_2D, glossyTex);
            gl.uniform1i(glossyLocation, 1);

            gl.activeTexture(gl.TEXTURE2);
            gl.bindTexture(gl.TEXTURE_2D, uvMaskTex);
            gl.uniform1i(uvMaskLocation, 2);

            gl.drawArrays(gl.TRIANGLES, 0, 6);
        } catch(e) {
            error = e.message;
            return;
        }

        return () => {
            gl.deleteBuffer(vbo);
            gl.deleteProgram(program);
            gl.deleteShader(frag);
            gl.deleteShader(vert);
        };
    });
</script>

<style>
    .container {
        position: relative;
    }
    canvas {
        position: relative;
        left: 0;
        top: 0;
        width: 100%;
        z-index: 0;
    }
    .error {
        display: flex;
        justify-content: center;
        align-items: center;
        position: absolute;
        left: 0;
        top: 0;
        width: 100%;
        height: 100%;
        z-index: 1;
        background-color: #000000c0;
    }
    h1 {
        font-size: 3em;
		color: #f0f0f0;
		font-weight: 700;
    }
    p {
        white-space: pre-wrap;
        font-size: 1.5em;
		color: #f0f0f0;
		font-weight: 400;
        text-align: left;
    }
</style>

<div class="container">
    <canvas bind:this={canvas} width={1920} height={1080}>
    </canvas>
    {#if error}
    <div class="error">
        <div>
            <h1>Error:</h1>
            <p>{error}</p>
        </div>
    </div>
    {/if}
</div>
