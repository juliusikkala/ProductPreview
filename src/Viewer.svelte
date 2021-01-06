<script>
    import { onMount, onDestroy } from 'svelte';
	import { fade } from 'svelte/transition';
    import { get } from 'svelte/store';
    import { PNG } from 'pngjs/browser';
    import { Buffer } from 'buffer';
	import { userImage, scene } from './stores.js';

    let canvas;
    let error;
    let gl;
    let userTex;
    let userTexIndex = 0;
    let releaseMemory = () => {};
    let ready = false;

    async function getShader(type, name) {
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

    function createProgram(vert, frag) {
        let program = gl.createProgram();
        gl.attachShader(program, vert);
        gl.attachShader(program, frag);
        gl.linkProgram(program);
        if(!gl.getProgramParameter(program, gl.LINK_STATUS)) {
            throw new Error(`Failed to link shader program: ${gl.getProgramInfoLog(program)}`);
        }
        return program;
    }

    function refreshUserTexture(imagePath) {
        let image = new Image();
        image.src = imagePath;
        image.onload = () => {
            if(!ready) return;

            if(userTex) {
                gl.deleteTexture(userTex);
            }

            gl.activeTexture(gl.TEXTURE0 + userTexIndex);
            userTex = gl.createTexture();
            gl.bindTexture(gl.TEXTURE_2D, userTex);
            gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, image);
            gl.generateMipmap(gl.TEXTURE_2D);
            gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
            gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
            gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR);
            gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);

            drawFrame();
        };
    }

    async function loadTexture(name) {
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

    function drawFrame() {
        gl.drawArrays(gl.TRIANGLES, 0, 6);
    }
    
    async function setupGenericScene(
        fragShaderPath,
        texturePaths,
        textureNames
    ) {
        releaseMemory();
        ready = false;
        error = "";
        userTexIndex = 0;

        try {
            let textures = [];
            for(const path of texturePaths) {
                textures.push(await loadTexture(path));
            }

            let frag = await getShader(gl.FRAGMENT_SHADER, fragShaderPath);
            let vert = await getShader(gl.VERTEX_SHADER, 'vshader.glsl');
            let prog = createProgram(vert, frag);

            let vbo = gl.createBuffer();
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

            let posAttr = gl.getAttribLocation(prog, 'pos');
            gl.enableVertexAttribArray(posAttr);
            gl.vertexAttribPointer(posAttr, 2, gl.FLOAT, false, 0, 0);
            gl.bindBuffer(gl.ARRAY_BUFFER, vbo);

            for(const name of textureNames) {
                let loc = gl.getUniformLocation(prog, name);
                let index = userTexIndex++;
                gl.activeTexture(gl.TEXTURE0 + index);
                gl.bindTexture(gl.TEXTURE_2D, textures[index]);
                gl.uniform1i(loc, index);
            }

            let userTexLocation = gl.getUniformLocation(prog, 'user_tex');
            gl.uniform1i(userTexLocation, userTexIndex);

            ready = true;
            refreshUserTexture(get(userImage));

            releaseMemory = () => {
                for(const tex of textures)
                    gl.deleteTexture(tex);
                gl.deleteBuffer(vbo);
                gl.deleteProgram(prog);
                gl.deleteShader(frag);
                gl.deleteShader(vert);
                releaseMemory = () => {};
            };
        } catch(e) {
            error = e.message;
        }
    }

    async function setupPuzzleScene() {
        await setupGenericScene(
            'puzzle/shader.glsl',
            ['puzzle/diffuse_linear.png', 'puzzle/glossy_linear.png', 'puzzle/uv_mask.png'],
            ['diffuse_tex', 'glossy_tex', 'uv_mask_tex']
        );
    }

    async function setupTVScene() {
        await setupGenericScene(
            'tv/shader.glsl',
            ['tv/base.png', 'tv/emission2.png', 'tv/uv_mask.png'],
            ['base_tex', 'emission_tex', 'uv_mask_tex']
        );
    }

    async function setupScene(scene) {
        if(scene == 'puzzle')
            await setupPuzzleScene();
        else if(scene == 'tv')
            await setupTVScene();
    }

    onMount(async () => {
        gl = canvas.getContext('webgl2');
        if(!gl) {
            error = "Unable to get a WebGL context!";
            return;
        }
        let ext = gl.getExtension("EXT_color_buffer_float");
        if(!ext) {
            error = "This demo requires EXT_color_buffer_float support.";
            return;
        }

        scene.subscribe(async (selected) => await setupScene(selected));
        userImage.subscribe(imagePath => refreshUserTexture(imagePath));
    });

    onDestroy(() => {
        if(userTex) {
            gl.deleteTexture(userTex);
        }
        releaseMemory();
    });
</script>

<style>
    .stretchContainer {
        position: relative;
        flex-grow: 1;
        display: block;
    }

    .container {
        position: relative;
        margin: 1em;
        height: calc(100vh - 2em);
        display: block;
        padding: 0;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: space-around;
    }

    .oneMoreContainer {
        position: relative;
        max-height: 100%;
        display: block;
    }

    canvas {
        max-width: 1920px;
        max-width: 100%;
        max-height: 100%;
        box-shadow: 0px 0px 20px #101010;
        z-index: 0;
        display: inline-block;
    }

    .error, .loading {
        display: flex;
        justify-content: center;
        align-items: center;
        position: absolute;
        width: calc(min(min((100vh - 2em) * 16 / 9, 1920px, 100%)));
        margin-left: auto;
        margin-right: auto;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
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

<div class="stretchContainer">
    <div class="container">
        <div class="oneMoreContainer">
            <canvas bind:this={canvas} width={1920} height={1080}>
            </canvas>
            {#if error}
            <div class="error">
                <div>
                    <h1>Error:</h1>
                    <p>{error}</p>
                </div>
            </div>
            {:else if !ready}
            <div class="loading" transition:fade>
                <h1>Loading...</h1>
            </div>
            {/if}
        </div> 
    </div>
</div>
