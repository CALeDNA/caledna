import baseMap from "../../../packs/base_map.js";

function getRandomColor() {
  var letters = "0123456789ABCDEF";
  var color = "#";
  for (var i = 0; i < 6; i++) {
    color += letters[Math.floor(Math.random() * 16)];
  }
  return color;
}

export const mapMixins = {
  methods: {
    addMapOverlays(map) {
      baseMap.createOverlayEventListeners(map);
      baseMap.createOverlays(map);
      baseMap.addMapLayerModal(map);
    },
  },
};

export const taxonLayerMixins = {
  methods: {
    toggleTaxonLayer() {
      if (this.showTaxonLayer) {
        this.removeTaxonLayer();
        this.showTaxonLayer = false;
      } else {
        this.addTaxonLayer();
        this.showTaxonLayer = true;
      }
    },

    // NOTE: redraw taxonLayer so it is on top
    redrawTaxonLayer() {
      if (this.showTaxonLayer) {
        this.taxonLayer.clearLayers();
        this.addTaxonLayer();
      }
    },

    removeTaxonLayer() {
      if (this.taxonLayer) {
        this.taxonLayer.clearLayers();
      }
    },

    addTaxonLayer() {
      const samples = this.taxonSamplesData.filter(function(sample) {
        return sample.latitude && sample.longitude;
      });

      this.taxonLayer = baseMap.renderCirclesLayer(samples, this.map);
    },
  },
};

export const baseLayerMixins = {
  methods: {
    toggleBaseLayer() {
      this.showBaseLayer = !this.showBaseLayer;

      if (this.showBaseLayer) {
        this.addBaseLayer();
        this.redrawTaxonLayer();
      } else {
        this.removeBaseLayer();
      }
    },

    removeBaseLayer() {
      if (this.baseLayer) {
        this.baseLayer.clearLayers();
      }
    },

    addBaseLayer() {
      this.baseLayer = baseMap.renderCirclesLayer(
        this.baseSamplesData,
        this.map,
        { fillColor: "#ddd", color: "#777" }
      );
    },
  },
};

export const secondaryLayerMixins = {
  methods: {
    toggleSecondaryLayer() {
      this.showSecondaryLayer = !this.showSecondaryLayer;

      if (this.showSecondaryLayer) {
        this.addSecondaryLayer();
        this.redrawTaxonLayer();
      } else {
        this.removeSecondaryLayer();
      }
    },

    removeSecondaryLayer() {
      if (this.secondaryLayer) {
        this.secondaryLayer.clearLayers();
      }
    },

    addSecondaryLayer() {
      this.secondaryLayer = baseMap.renderCirclesLayer(
        this.secondarySamplesData,
        this.map
      );
    },
  },
};
