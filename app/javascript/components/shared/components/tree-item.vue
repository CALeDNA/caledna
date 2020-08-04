<template>
  <li>
    <span @click="toggle" class="tree-item">
      <span v-if="hasChildren">[{{ isOpen ? "-" : "+" }}] </span>
      {{ displayName }}
    </span>
    <a v-if="showLink" :href="`/taxa/${itemData.id}`">(link)</a>
    <ul v-show="isOpen" v-if="hasChildren">
      <tree-item
        v-for="child in itemData.children"
        :itemData="child"
        v-bind:key="child.id"
      ></tree-item>
    </ul>
  </li>
</template>

<script>
  export default {
    name: "tree-item",
    props: {
      itemData: Object,
    },
    computed: {
      hasChildren: function () {
        return this.itemData.children && this.itemData.children.length;
      },
      displayName: function () {
        if (this.itemData.name == "Life") {
          return this.itemData.name;
        } else if (this.itemData.name.includes(" for ")) {
          return this.itemData.name;
        } else {
          return `${this.itemData.rank}: ${this.itemData.name}`;
        }
      },
      showLink: function () {
        if (this.itemData.name == "Life") {
          return false;
        } else if (this.itemData.rank == "kingdom") {
          return false;
        } else if (this.itemData.name.includes(" for ")) {
          return false;
        } else {
          return true;
        }
      },
    },
    data() {
      return {
        isOpen: this.itemData.name == "Life" || false,
      };
    },
    methods: {
      toggle: function () {
        if (this.hasChildren) {
          this.isOpen = !this.isOpen;
        }
      },
    },
  };
</script>
