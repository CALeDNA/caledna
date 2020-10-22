<template>
  <div class="loading-spinner"></div>
</template>

<script>
export default { name: "Spinner" };
</script>

<style>
/*
https://stephanwagner.me/only-css-loading-spinner
 */
@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

.loading-spinner:before {
  content: "";
  box-sizing: border-box;
  position: fixed;
  top: calc(50% - 50px);
  left: calc(50% - 50px);
  width: 100px;
  height: 100px;
  border-radius: 50%;
  border: 10px solid #ccc;
  border-top-color: #5aa172;
  animation: spinner 0.8s linear infinite;
  z-index: 500;
}
</style>
