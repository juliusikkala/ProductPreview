<script>
  import Viewer from "./Viewer.svelte";
  import OptionPanel from "./OptionPanel.svelte";
</script>

<style>
  main {
    text-align: center;
    height: 100%;
  }

  #layout {
    display: flex;
    height: 100%;
    align-items: center;
  }
</style>

<main>
  <div id="layout">
    <Viewer />
    <OptionPanel />
  </div>
</main>
