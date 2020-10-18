<template>
  <div class="my-modal-mask">
    <div class="modal-container">
      <div class="modal-header">
        <button
          class="modal-default-button btn btn-default"
          @click="$emit('close')"
        >
          ×
        </button>
        <slot name="header"> default header </slot>
      </div>

      <div class="modal-body">
        <slot name="body"> default body </slot>
      </div>
    </div>
  </div>
</template>
<script>
export default {
  name: "modal",
};
</script>
