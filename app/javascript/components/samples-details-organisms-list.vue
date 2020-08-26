<template>
  <div>
    <div class="kingdom-submenu">
      <a
        :class="{ active: 'All' == activeKingdom }"
        class="btn my-btn-default"
        data-kingdom="All"
        @click="toggleList"
      >
        All Kingdoms
      </a>
      <a
        v-for="kingdom in kingdoms"
        :key="kingdom"
        :class="{ active: kingdom == activeKingdom }"
        class="btn my-btn-default"
        :data-kingdom="kingdom"
        @click="toggleList"
      >
        <img
          :src="`/images/taxa_icons/${slugify(kingdom)}.png`"
          class="kingdom-icon"
        />
        {{ kingdom }}
      </a>
    </div>
    <ol class="organism-list">
      <li
        v-for="taxon in taxaList"
        :key="taxon.taxon_id"
        :ref="slugify(taxon.division_name)"
      >
        <span v-if="is_threatened(taxon)">
          (Name not shown because this {{ taxon.rank }} is
          {{ taxon.iucn_status }})
        </span>
        <span v-else>
          <b>{{ taxon.rank }}:</b>
          <span v-html="formatTaxonName(taxon)"></span>
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
      activeKingdom: "All",
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
        return `(${taxon.common_names.split("|").slice(0, 3).join(", ")})`;
      }
    },
    formatTaxonName: function (taxon) {
      let hierarchy = {
        kingdom: taxon.division_name,
        phylum: taxon.phylum,
        class: taxon.class,
        order: taxon.order,
        family: taxon.family,
        genus: taxon.genus,
        species: taxon.species,
      };
      let ranks = Object.keys(hierarchy);

      return Object.values(hierarchy)
        .map((taxon, index) => {
          if (taxon) {
            if (taxon.includes("|")) {
              const parts = taxon.split("|");
              return `<a title="${ranks[index]}" href="/taxa/${parts[1]}">${parts[0]}</a>`;
            } else {
              return taxon;
            }
          }
        })
        .filter((taxon) => taxon !== undefined)
        .join(" &#8250; ");
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
      this.activeKingdom = e.target.dataset.kingdom;

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
