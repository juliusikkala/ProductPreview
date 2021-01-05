<script>
    import { createEventDispatcher } from 'svelte';

	const dispatch = createEventDispatcher();

    let fileUrl;
    let files;
    $: {
        if(files && files[0]) {
            let reader = new FileReader();
            reader.onload = (e) => {
                fileUrl = e.target.result;
                dispatch('picked', fileUrl);
            }
            reader.readAsDataURL(files[0]);
        }
    }
</script>

<style>
    #picker {
        display: flex;
        flex-direction: column;
        width: 40em;
        margin: 0em 1em 0em 1em;
    }
    #container {
        width: 100%
    }
    img {
        width: 100%
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
