<script>
	export let name;
    import Viewer from './Viewer.svelte';
    import OptionPanel from './OptionPanel.svelte';
</script>

<main>
    <div id="layout">
        <Viewer />
        <OptionPanel />
    </div>
</main>

<style>
	main {
		text-align: center;
        height: 100%;
	}

	@media (min-width: 640px) {
		main {
			max-width: none;
		}
	}

    #layout {
        display: flex;
        height: 100%;
        align-items: center;
    }
</style>
