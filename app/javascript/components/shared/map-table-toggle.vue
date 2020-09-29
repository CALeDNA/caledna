<template>
  <div class="btn-group" role="group">
    <a
      class="btn btn-default"
      :class="{ active: activeTab === 'map' }"
      @click="$emit('active-tab-event', 'map')"
    >
      <i class="fas fa-map-marker-alt"></i> Map
    </a>
    <a
      class="btn btn-default"
      :class="{ active: activeTab === 'table' }"
      @click="$emit('active-tab-event', 'table')"
    >
      <i class="far fa-list-alt"></i> List
    </a>
  </div>
</template>

<script>
export default {
  name: "MapTableToggle",
  props: ["activeTab"],
};
</script>
