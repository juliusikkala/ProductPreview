<script>
  import { scene } from "./stores.js";

  let scenes = [
    { id: "puzzle", text: "Puzzle" },
    { id: "poster", text: "Metallic Poster" },
    { id: "tv", text: "TV Room" },
  ];
  let selected = "puzzle";
  $: scene.set(selected);
</script>

<style>
  #picker {
    display: flex;
    margin: 0em 1em 1em 1em;
    align-items: center;
  }

  select {
    flex-grow: 2;
    margin-left: 2em;
    margin-bottom: 0em;
  }

  label {
    color: #f0f0f0;
  }
</style>

<div id="picker">
  <label for="scene_selector">Scene:</label>
  <select id="scene_selector" bind:value={selected}>
    {#each scenes as scene}
      <option value={scene.id}>{scene.text}</option>
    {/each}
  </select>
</div>
