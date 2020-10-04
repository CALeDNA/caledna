import baseMap from "../packs/base_map.js";

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
      const samples = this.taxonSamplesData.filter(function (sample) {
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

export const mapZoomMixins = {
  /*
  ctx.map.getBounds()
  _northEast: LatLng
  lat: 35.290468565908775
  lng: -116.5155029296875
  _southWest: LatLng
  lat: 32.10118973232094
  lng: -120.02014160156251
  */
  methods: {
    calculateBoundingBox: function (latLngBounds, map) {
      // https://gist.github.com/neilkennedy/9227665
      var center = latLngBounds.getCenter();
      var latlngs = [];

      latlngs.push({
        lat: latLngBounds.getSouthWest().lat,
        lng: latLngBounds.getSouthWest().lng,
      }); //bottom left
      latlngs.push({ lat: latLngBounds.getSouth(), lng: center.lng }); //bottom center
      latlngs.push({
        lat: latLngBounds.getSouthEast().lat,
        lng: latLngBounds.getSouthEast().lng,
      }); //bottom right
      latlngs.push({ lat: center.lat, lng: latLngBounds.getEast() }); // center right
      latlngs.push({
        lat: latLngBounds.getNorthEast().lat,
        lng: latLngBounds.getNorthEast().lng,
      }); //top right
      latlngs.push({
        lat: latLngBounds.getNorth(),
        lng: map.getCenter().lng,
      }); //top center
      latlngs.push({
        lat: latLngBounds.getNorthWest().lat,
        lng: latLngBounds.getNorthWest().lng,
      }); //top left
      latlngs.push({
        lat: map.getCenter().lat,
        lng: latLngBounds.getWest(),
      }); //center left

      return latlngs;
    }
  }
}

