<template>
  <div id="app">
    <ColorMe/>
  </div>
</template>

<script>
import ColorMe from './components/ColorMe'

export default {
  name: 'app',
  components: {
    ColorMe
  }
}
</script>

<style>
#app {
  font-size: 16px;
  font-family: 'Oxygen', sans-serif;
  margin-top: 120px;
}
</style>
