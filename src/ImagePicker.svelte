<script>
	import { userImage } from './stores.js';

    let fileUrl;
    let files;
    $: {
        if(files && files[0]) {
            let reader = new FileReader();
            reader.onload = (e) => {
                fileUrl = e.target.result;
                userImage.set(fileUrl);
            }
            reader.readAsDataURL(files[0]);
        }
    }
</script>

<style>
    #picker {
        display: flex;
        flex-direction: column;
        width: 20em;
        margin: 0em 1em 0em 1em;
    }
    #container {
        width: 100%;
        max-height: 20em;
    }
    img {
        max-width: 100%;
        max-height: 100%;
    }

    input {
        color: #F0F0F0;
        border: none;
        padding: 0em;
    }
</style>

<div id="picker">
    <input type="file" accept="image/*" bind:files />
    {#if fileUrl}
        <div id="container">
            <img src={fileUrl} alt="The Chosen One." />
        </div>
    {/if}
</div>
