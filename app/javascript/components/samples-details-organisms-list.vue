<template>
  <div>
    <div class="kingdom-submenu">
      <a class="btn my-btn-default" data-kingdom="All" @click="toggleList">
        All Kingdoms
      </a>
      <a
        v-for="kingdom in kingdoms"
        :key="kingdom"
        class="btn my-btn-default"
        :data-kingdom="kingdom"
        @click="toggleList"
      >
        <img
          :src="`/images/taxa_icons/${slugify(kingdom)}.png`"
          class="kingdom-icon"
          :data-kingdom="kingdom"
        />
        {{ kingdom }}
      </a>
    </div>
    <ol class="organism-list">
      <li
        :title="formatTooltip(taxon)"
        v-for="taxon in taxaList"
        :key="taxon.taxon_id"
        :ref="slugify(taxon.division_name)"
      >
        <span v-if="is_threatened(taxon)">
          (Name not shown because this species is {{ taxon.iucn_status }})
        </span>
        <span v-else>
          {{ taxon.rank }}:
          <a :href="`/taxa/${taxon.taxon_id}`">{{ formatTaxonName(taxon) }}</a>
          {{ formatCommonName(taxon) }}
        </span>
      </li>
    </ol>
  </div>
</template>

<script>
export default {
  name: "SamplesDetailOrganismsList",
  data() {
    return {
      taxaList: [],
      kingdoms: [
        "Animalia",
        "Archaea",
        "Bacteria",
        "Chromista",
        "Environmental Samples",
        "Fungi",
        "Plantae",
        "Protozoa",
      ],
    };
  },

  created() {
    this.taxaList = this.$root.taxa_list;
  },

  mounted() {},

  methods: {
    slugify: function (value) {
      if (!value) return;
      return value.toLowerCase().replace(" ", "_");
    },
    formatCommonName: function (taxon) {
      if (taxon.common_names) {
        return `(${taxon.common_names.split("|").slice(0, 3)})`;
      }
    },
    formatTooltip: function (taxon) {
      let hierarchy = {
        kingdom: taxon.division_name,
        phylum: taxon.phylum,
        class: taxon.class,
        order: taxon.order,
        family: taxon.family,
        genus: taxon.genus,
        species: taxon.species,
      };
      let keys = Object.keys(hierarchy);
      let results = [];

      Object.values(hierarchy).forEach((value, index) => {
        if (value) {
          results.push(`${keys[index]}: ${value}`);
        }
      });
      return results.join(", ");
    },
    formatTaxonName: function (taxon) {
      return [
        taxon.division_name,
        taxon.phylum,
        taxon.class,
        taxon.order,
        taxon.family,
        taxon.genus,
        taxon.species,
      ]
        .filter((i) => i !== null)
        .join(", ");
    },
    is_threatened: function (taxon) {
      return [
        "extinct",
        "extinct in the wild",
        "critically endangered",
        "endangered",
        "endangered species",
        "associated species",
      ].includes(taxon.iucn_status);
    },
    toggleList: function (e) {
      var targetKingdom = this.slugify(e.target.dataset.kingdom);

      this.kingdoms.forEach((rawKingdom) => {
        let kingdom = this.slugify(rawKingdom);

        if (targetKingdom == "all") {
          this.$refs[kingdom] &&
            this.$refs[kingdom].forEach(
              (el) => (el.style.display = "list-item")
            );
        } else if (kingdom == targetKingdom) {
          this.$refs[kingdom] &&
            this.$refs[kingdom].forEach(
              (el) => (el.style.display = "list-item")
            );
        } else {
          this.$refs[kingdom] &&
            this.$refs[kingdom].forEach((el) => (el.style.display = "none"));
        }
      });
    },
  },
};
</script>
