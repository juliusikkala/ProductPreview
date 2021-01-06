<script>
    import ImagePicker from './ImagePicker.svelte';
    import ScenePicker from './ScenePicker.svelte';
</script>

<div id="panel">
    <h1>Options</h1>
    <ScenePicker />
    <ImagePicker />
</div>

<style>
    #panel {
        display: flex;
        flex-direction: column;
        background-color: #303030;
        height: 100%;
        box-shadow: 0px 0px 20px #101010;
    }
    h1 {
        color: #F0F0F0;
    }
</style>

