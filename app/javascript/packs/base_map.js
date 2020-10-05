import "leaflet-easybutton";

// =============
// config map
// =============

var initialLat = 38.0;
var initialLng = -118.3;
var fillColor = "#5aa172";
var strokeColor = "#222";
var initialZoom = 6;
var maxZoom = 25;
var disableClustering = 15;
var mapboxAccessToken =
  "pk.eyJ1Ijoid3lraHVoIiwiYSI6ImNqY2gzMHJ3OTIyeW4zM210Zmgwd2ZoMXEifQ.p-v5zVFnVgvvdxKiVRpCRA";

var latlng = L.latLng(initialLat, initialLng);

var defaultCircleOptions = {
  fillColor: fillColor,
  radius: 7,
  fillOpacity: 0.7,
  color: strokeColor,
  weight: 2,
};

// =============
// tile layers
// =============

var tileLayerOptions = {
  openstreetmap: {
    tile: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
    attribution:
      '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, Points &copy 2012 LINZ',
  },
  mapboxSatellite: {
    tile:
      "https://api.mapbox.com/v4/mapbox.satellite/{z}/{x}/{y}.png?access_token=" +
      mapboxAccessToken,
    attribution:
      '© <a href="https://www.mapbox.com/feedback/">Mapbox</a> © <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>',
  },
  cartoPositron: {
    tile:
      "https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png",
    attribution:
      'Map tiles by <a href="https://carto.com/">Carto</a>, under CC BY 3.0. Data by <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>, under ODbL',
  },
  thuderforestLandscape: {
    tile:
      "https://tile.thunderforest.com/landscape/{z}/{x}/{y}.png?apikey=5354ed1fe58c49efb6b5e34ec3caf15e",
    attribution:
      'Maps © <a href="http://www.thunderforest.com/">Thunderforest</a>, Data © <a href="https://www.openstreetmap.org/copyright">OpenStreetMap contributors</a>',
  },
};

var tileLayers = {
  Streets: L.tileLayer(tileLayerOptions.openstreetmap.tile, {
    attribution: tileLayerOptions.openstreetmap.attribution,
  }),
  Satellite: L.tileLayer(tileLayerOptions.mapboxSatellite.tile, {
    attribution: tileLayerOptions.mapboxSatellite.attribution,
  }),
  Terrain: L.tileLayer(tileLayerOptions.thuderforestLandscape.tile, {
    attribution: tileLayerOptions.thuderforestLandscape.attribution,
  }),
  Minimal: L.tileLayer(tileLayerOptions.cartoPositron.tile, {
    attribution: tileLayerOptions.cartoPositron.attribution,
  }),
};

function tileLayersFactory() {
  return {
    Streets: L.tileLayer(tileLayerOptions.openstreetmap.tile, {
      attribution: tileLayerOptions.openstreetmap.attribution,
    }),
    Satellite: L.tileLayer(tileLayerOptions.mapboxSatellite.tile, {
      attribution: tileLayerOptions.mapboxSatellite.attribution,
    }),
    Terrain: L.tileLayer(tileLayerOptions.thuderforestLandscape.tile, {
      attribution: tileLayerOptions.thuderforestLandscape.attribution,
    }),
    Minimal: L.tileLayer(tileLayerOptions.cartoPositron.tile, {
      attribution: tileLayerOptions.cartoPositron.attribution,
    }),
  }
}

// =============
// create markers
// =============

function createClusterGroup() {
  return L.markerClusterGroup({
    disableClusteringAtZoom: disableClustering,
    spiderfyOnMaxZoom: false,
  });
}

function createMap(customLatlng = null, customInitialZoom = null) {
  if (customLatlng) {
    latlng = customLatlng;
    initialLat = latlng.lat;
    initialLng = latlng.lng;
  }
  if (customInitialZoom) {
    initialZoom = customInitialZoom;
  }

  return L.map("mapid", {
    preferCanvas: true,
    center: latlng,
    zoom: initialZoom,
    maxZoom: maxZoom,
    layers: [tileLayers.Streets],
  });
}

function createCircleMarker(record, customOptions = {}) {
  var options = { ...defaultCircleOptions, ...customOptions };

  if (record.color) {
    options.fillColor = record.color;
  }

  var circleMarker = L.circleMarker(L.latLng(record.lat, record.lng), options);
  if (record.body) {
    circleMarker.bindPopup(record.body);
  }

  return circleMarker;
}

function createIconMarker(sample, map) {
  if (!sample.lat || !sample.lng) {
    return;
  }

  var icon = L.marker([sample.lat, sample.lng]);
  if (sample.body) {
    icon.bindPopup(sample.body);
  }
  return icon;
}

function createMarkerCluster(samples, createMarkerFn) {
  let markerClusterGroup = createClusterGroup();
  samples
    .filter((sample) => sample.lat && sample.lng)
    .forEach(function (sample) {
      var marker = createMarkerFn(sample);
      markerClusterGroup.addLayer(marker);
    });
  return markerClusterGroup;
}

function renderClusterLayer(data, map) {
  let layer = createMarkerCluster(data, createCircleMarker);
  map.addLayer(layer);
  return layer;
}

function createMarkerLayer(samples, createMarkerFn) {
  var markers = samples.map(function (sample) {
    return createMarkerFn(sample);
  });
  return L.layerGroup(markers);
}

function renderCirclesLayer(rawSamples, map, options = {}) {
  let samples = rawSamples.filter((sample) => sample.lat && sample);
  return createMarkerLayer(samples, function (sample) {
    return createCircleMarker(sample, {
      ...addMapLayerModal.defaultCircleOptions,
      ...options,
    });
  }).addTo(map);
}

function renderIconsLayer(samples, map) {
  return createMarkerLayer(samples, createIconMarker).addTo(map);
}

// =============
// format data
// =============

function formatSamplesData(rawSample) {
  var sample = rawSample.attributes || rawSample;
  var body;

  if (sample.id) {
    var sampleLink = `<a href='/samples/${sample.id}'>${sample.barcode}</a>`;
    body = `<b>Site:</b> ${sampleLink} <br>
      <b>Lat/Long</b>: ${sample.latitude} , ${sample.longitude} <br>
      <b>Status</b>: ${sample.status} <br>
      <b>Organism count</b>: ${sample.taxa_count} <br>`;
  } else {
    body = null;
  }

  return {
    ...sample,
    lat: sample.latitude,
    lng: sample.longitude,
    body: body,
  };
}

function formatGBIFData(sample, options) {
  var colors = {
    Animalia: "rgb(30, 144, 255)",
    Archaea: "rgb(30, 30, 30)",
    Bacteria: "rgb(30, 30, 30)",
    Chromista: "rgb(153, 51, 0)",
    Fungi: "rgb(255, 20, 147)",
    Plantae: "rgb(115, 172, 19)",
    Protozoa: "",
    Viruses: "rgb(30, 30, 30)",
  };

  var lat = sample.latitude;
  var lng = sample.longitude;
  var color;
  var body;
  var sample_id = sample.id || sample.gbif_id;
  var sample_name = sample.species || sample.name;

  if (sample_id) {
    var sampleLink = `<a href='https://www.gbif.org/occurrence/${sample_id}'>${sample_id}</a>`;

    body =
      "<b>GBIF Link:</b> " +
      sampleLink +
      "<br>" +
      "<b>Lat/Long</b>: " +
      lat +
      ", " +
      lng +
      "<br>" +
      "<b>Kingdom</b>: " +
      sample.kingdom +
      "<br>" +
      `<b>${sample.taxon_rank}</b>: ${sample_name}`;
  }

  if (sample.kingdom) {
    color = options.fillColor || colors[sample.kingdom];
  }

  return {
    lat: lat,
    lng: lng,
    body: body,
    color: color,
  };
}

function formatInatData(rawRecord) {
  var record = rawRecord.attributes;
  var lat = record.latitude;
  var lng = record.longitude;
  var body;

  if (record.observation_id) {
    var recordLink = `<a href="${record.url}">${record.observation_id}</a>`;
    body =
      `<b>iNaturalist:</b> ${recordLink}` +
      "<br>" +
      `<b>Lat/Long</b>: ${lat}, ${lng}` +
      "<br>" +
      `<b>${record.rank}</b>: ${record.canonical_name} (${record.common_name})`;
  }

  return {
    lat: lat,
    lng: lng,
    body: body,
    color: "orange",
  };
}

function formatMapData(data) {
  var samples = data.samples ? data.samples.data : [data.sample.data];
  var baseSamples = data.base_samples && data.base_samples.data;
  var taxonSamplesData;
  var baseSamplesData;

  taxonSamplesData = samples.map(function (sample) {
    return formatSamplesData(sample);
  });

  if (baseSamples) {
    baseSamplesData = baseSamples.map(function (sample) {
      return formatSamplesData(sample);
    });
  }

  return { taxonSamplesData, baseSamplesData };
}

// =============
// fetch data
// =============

function fetchSamples(apiEndpoint, map, cb) {
  var spinner = addSpinner(map);

  $.get(apiEndpoint, function (data) {
    var samples = data.samples ? data.samples.data : [data.sample.data];
    var baseSamples = data.base_samples && data.base_samples.data;
    var samplesData;
    var baseSamplesData;
    var researchProjectData = data.research_project_data;

    samplesData = samples.map(function (sample) {
      return formatSamplesData(sample);
    });

    if (baseSamples) {
      baseSamplesData = baseSamples.map(function (sample) {
        return formatSamplesData(sample);
      });
    }

    map.removeLayer(spinner);

    cb({ samplesData, baseSamplesData, researchProjectData });
  });
}

// =============
// overlays
// =============

function createRasterLayer(rasterFile) {
  var imgBounds = [
    [32.5325005393, -124.416666666],
    [42.0158338727, -114.125],
  ];
  return new L.imageOverlay(rasterFile, imgBounds);
}

function createLegend(legendImg) {
  var div = L.DomUtil.create("div", "info legend");
  div.innerHTML += '<img src="' + legendImg + '" alt="legend" width="100px">';
  return div;
}

var bldfie = createRasterLayer("/data/map_rasters/bldfie_0.png");
var clyppt = createRasterLayer("/data/map_rasters/clyppt_1.png");
var sndppt = createRasterLayer("/data/map_rasters/sndppt_2.png");
var sltppt = createRasterLayer("/data/map_rasters/sltppt_3.png");
var hii = createRasterLayer("/data/map_rasters/hii_4.png");
var elevation = createRasterLayer("/data/map_rasters/elevation_0.png");
var precipitation = createRasterLayer("/data/map_rasters/precipitation_0.png");
var popdens_geo = createRasterLayer("/data/map_rasters/popdens_geo_2.png");

var environmentLayers = {
  "bldfie (bulk density)": { layer: bldfie, legend: "legend_bldfie.png" },
  "clyppt (amount clay)": { layer: clyppt, legend: "legend_clyppt.png" },
  "sltppt (amount silt)": { layer: sltppt, legend: "legend_sltppt.png" },
  "sndppt (amount sand)": { layer: sndppt, legend: "legend_sndppt.png" },
  "hii (human impact)": { layer: hii, legend: "legend_hii.png" },
  elevation: { layer: elevation, legend: "legend_elevation.png" },
  precipitation: { layer: precipitation, legend: "legend_precipitation.png" },
  "population density": {
    layer: popdens_geo,
    legend: "legend_popdens_geo.png",
  },
};

var legend = L.control({ position: "bottomright" });

// NOTE: toggle the legend for each overlay
function createOverlayEventListeners(map) {
  map.on("overlayadd", function (eventLayer) {
    map.removeControl(legend);

    if (environmentLayers[eventLayer.name]) {
      legend.onAdd = function () {
        return createLegend(
          "/data/map_rasters/" + environmentLayers[eventLayer.name].legend
        );
      };
      legend.addTo(map);
    }
  });

  map.on("overlayremove", function (eventLayer) {
    map.removeControl(legend);
  });
}

// NOTE: add popoup for each UC reserve
function onEachFeatureHandler(feature, layer) {
  if (feature.properties && feature.properties.AgencyName) {
    var body = "<b>Name:</b> " + feature.properties.Name + "<br>";
    body += "<b>County:</b> " + feature.properties.COUNTY;
    layer.bindPopup(body);
  }
}

// NOTE: add each overlay to the map
function createOverlays(map) {
  $.get("/data/map_layers/uc_reserves.geojson", function (data) {
    var uc_reserves = L.geoJSON(JSON.parse(data), {
      onEachFeature: onEachFeatureHandler,
    });

    $.get("/data/map_layers/HyspIRI_CA.geojson", function (data) {
      var geojsonMarkerOptions = {
        radius: 1,
        fillColor: "#000",
        color: "#000",
        weight: 1,
        opacity: 1,
        fillOpacity: 0.8,
      };

      var HyspIRI_CA = L.geoJSON(JSON.parse(data), {
        pointToLayer: function (feature, latlng) {
          return L.circleMarker(latlng, geojsonMarkerOptions);
        },
      });

      var overlayMaps = {
        HyspIRI: HyspIRI_CA,
        "UC Reserves": uc_reserves,
      };

      Object.keys(environmentLayers).map(function (layer) {
        overlayMaps[layer] = environmentLayers[layer].layer;
      });

      L.control.layers(tileLayers, overlayMaps).addTo(map);
    });
  });
}

// NOTE: show the modal that explains the various map overlays
function addMapLayerModal(map) {
  // NOTE: can't use font awesome because it makes d3 tree have buggy anomation
  L.easyButton(
    "map-button-info",
    function (btn, map) {
      $("#map-layer-modal").modal("show");
    },
    "Map info"
  ).addTo(map);
}

// =============
// event listeners
// =============

function addEventListener(map, samplesData) {
  if (markerFormatEls) {
    markerFormatEls.forEach(function (el) {
      el.addEventListener("click", function (event) {
        var format = event.target.value;

        if (format == "cluster" && currentMarkerFormat == "individual") {
          currentMarkerFormat = "cluster";

          map.removeLayer(individualMarkerLayer);
          markerClusterLayer.clearLayers();

          renderMarkerCluster(filteredSamplesData, map);
        } else if (format == "individual" && currentMarkerFormat == "cluster") {
          currentMarkerFormat = "individual";

          map.removeLayer(markerClusterLayer);
          renderCirclesLayer(filteredSamplesData, map);
        }
      });
    });
  }

  if (sampleStatusEl) {
    sampleStatusEl.addEventListener("change", function (event) {
      var status = event.target.value;
      filteredSamplesData = retrieveSamplesByStatus(status, samplesData);

      if (currentMarkerFormat == "cluster") {
        markerClusterLayer.clearLayers();
        renderMarkerCluster(filteredSamplesData, map);
      } else {
        map.removeLayer(individualMarkerLayer);
        renderCirclesLayer(filteredSamplesData, map);
      }
    });
  }
}

// =============
// misc
// =============

// NOTE: not using font awesome spinner because dynamically adding spinner
// causes page to scroll to the top
// https://stackoverflow.com/questions/55738409/adding-font-awesome-icon-dynamically-causes-page-to-scroll-to-top
function addSpinner(map) {
  return L.marker([initialLat, initialLng], {
    icon: L.divIcon({
      html: '<div class="spinner"></div>',
      iconSize: [0, 0],
    }),
  }).addTo(map);
}

function retrieveSamplesByStatus(status, samples) {
  if (status == "approved") {
    return filterSamplesByStatus(samples, "approved");
  } else if (status == "results_completed") {
    return filterSamplesByStatus(samples, "results_completed");
  } else {
    return samples;
  }
}

function filterSamplesByStatus(samples, status) {
  return samples.filter(function (sample) {
    return sample.status == status;
  });
}

export default {
  renderClusterLayer,
  fetchSamples,
  createMap,
  addEventListener,
  createOverlays,
  createOverlayEventListeners,
  createMarkerCluster,
  createCircleMarker,
  renderCirclesLayer,
  renderIconsLayer,
  formatGBIFData,
  formatInatData,
  createIconMarker,
  addMapLayerModal,
  formatSamplesData,
  tileLayerOptions,
  formatMapData,
  tileLayersFactory,
};
