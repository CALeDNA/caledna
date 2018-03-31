<template>
  <div class="field-unit">
    <label :for="field" class="field-unit__label">
      {{label}}
    </label>
    <div class="field-unit__field">
      <input type="text" :disabled="disabled" :id="field" v-model="model[field]">
    </div>
  </div>
</template>

<script>
  export default {
    props: ['model', 'label', 'field', 'disabled'],
  }
</script>
