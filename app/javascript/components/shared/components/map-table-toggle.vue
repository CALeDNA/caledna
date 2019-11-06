<template>
  <div class="btn-group" role="group">
    <a
      class="btn btn-default"
      :class="{ active: activeTab === 'map' }"
      @click="$emit('active-tab-event', 'map')"
    >
      <span class="glyphicon glyphicon-map-marker" aria-hidden="true"></span> Map
    </a>
    <a
      class="btn btn-default"
      :class="{ active: activeTab === 'table' }"
      @click="$emit('active-tab-event', 'table')"
    >
      <span class="glyphicon glyphicon-list-alt" aria-hidden="true"></span> List
    </a>
  </div>
</template>

<script>
export default {
  name: "MapTableToggle",
  props: ["activeTab"]
};
</script>
