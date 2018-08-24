import { callbackify } from "util";

// =============
// config map
// =============

var initialLat = 38.0;
var initialLng = -118.3;
var fillColor = '#5aa172';
var strokeColor = '#222';
var initialZoom = 6;
var maxZoom = 25;
var filteredSamplesData = []
var disableClustering = 15;
var currentMarkerFormat = 'cluster';
var apiEndpoint =  null;

var openstreetmap = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
  attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, Points &copy 2012 LINZ'
});

var accessToken = 'pk.eyJ1Ijoid3lraHVoIiwiYSI6ImNqY2gzMHJ3OTIyeW4zM210Zmgwd2ZoMXEifQ.p-v5zVFnVgvvdxKiVRpCRA';
var mapboxSatellite = L.tileLayer('https://api.mapbox.com/v4/mapbox.satellite/{z}/{x}/{y}.png?access_token=' + accessToken, {
    attribution: '© <a href="https://www.mapbox.com/feedback/">Mapbox</a> © <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
});

var cartoPositron= L.tileLayer('https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png', {
  attribution: 'Map tiles by <a href="https://carto.com/">Carto</a>, under CC BY 3.0. Data by <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>, under ODbL'
});


var thuderforestLandscape = L.tileLayer('https://tile.thunderforest.com/landscape/{z}/{x}/{y}.png?apikey=5354ed1fe58c49efb6b5e34ec3caf15e', {
  attribution: 'Maps © <a href="http://www.thunderforest.com/">Thunderforest</a>, Data © <a href="https://www.openstreetmap.org/copyright">OpenStreetMap contributors</a>'
});


var latlng = L.latLng(initialLat, initialLng);

var baseMaps = {
  Streets: openstreetmap,
  Satellite: mapboxSatellite,
  Terrain: thuderforestLandscape,
  Minimal: cartoPositron,
};

var individualMarkerLayer = L.layerGroup();

var markerClusterLayer = L.markerClusterGroup({
  disableClusteringAtZoom: disableClustering,
  spiderfyOnMaxZoom: false
});

// =============
// create markers
// =============

function createMap () {
  return L.map('mapid', {
    center: latlng,
    zoom: initialZoom,
    maxZoom: maxZoom,
    layers: [openstreetmap]
  })
}

function formatSamplesData(rawSample, asvsCount) {
  var sample = rawSample.attributes;
  var lat = sample.latitude;
  var lng = sample.longitude;

  if (sample.id) {
    var id = sample.id;
    var barcode = sample.barcode;
    var projectName = sample.field_data_project_name;
    var sampleLink = "<a href='/samples/" + sample.id + "'>" + barcode + "</a>";
    var status = sample.status;
    var asvsCount = asvsCount || '--';
    var body =
      '<b>Sample:</b> ' + sampleLink + '<br>' +
      '<b>Project:</b> ' + projectName + '<br>' +
      '<b>Lat/Long</b>: ' + lat + ', ' + lng + '<br>' +
      '<b>Status</b>: ' + status + '<br>' +
      '<b>Organism count</b>: ' + asvsCount + '<br>';
  } else {
    var body = null;
    var status = null;
  }


  return {
    lat: lat,
    lng: lng,
    barcode: barcode,
    body: body,
    status: status,
  }
}

function createCircleMarker (sample, customOptions) {
  var defaultOptions = {
    fillColor: fillColor,
    radius: 7,
    fillOpacity: .7,
    color: strokeColor,
    weight: 2
  };

  var options = customOptions ? customOptions : defaultOptions;

  var circleMarker = L.circleMarker(L.latLng(sample.lat, sample.lng), options);
  if (sample.body) {
    circleMarker.bindPopup(sample.body);
  }

  return circleMarker;
}

function createMarkerCluster(samples, createMarkerFn) {
  samples.forEach(function(sample) {
    var marker = createMarkerFn(sample)
    markerClusterLayer.addLayer(marker);
  });
  return markerClusterLayer;
}

function createMarkerLayer(samples, createMarkerFn) {
  var markers = samples.map(function(sample) {
    return createMarkerFn(sample)
  });
  individualMarkerLayer = L.layerGroup(markers)
}

function createRasterLayer(rasterFile) {
  var imgBounds = [[32.5325005393,-124.416666666],[42.0158338727,-114.125]];
  return new L.imageOverlay(rasterFile, imgBounds);
}

function createLegend (legendImg) {
  var div = L.DomUtil.create('div', 'info legend');
  div.innerHTML += '<img src="' + legendImg + '" alt="legend" width="80px">';
  return div;
}

function renderMarkerCluster(samples, map) {
  createMarkerCluster(samples, createCircleMarker)
  map.addLayer(markerClusterLayer);
}

function renderIndividualMarkers (samples, map) {
  createMarkerLayer(samples, createCircleMarker)
  individualMarkerLayer.addTo(map)
  return individualMarkerLayer
}

function renderBasicIndividualMarkers (samples, map) {
  createMarkerLayer(samples, function(sample) {
    return createCircleMarker(sample, {
      fillColor: '#ddd',
      radius: 7,
      fillOpacity: .7,
      color: '#777',
      weight: 2
    })
  })
  individualMarkerLayer.addTo(map)
  return individualMarkerLayer
}


// =============
// geojson layers
// =============

function onEachFeatureHandler(feature, layer) {
  if (feature.properties && feature.properties.AgencyName) {
    var body = '<b>Name:</b> ' + feature.properties.Name + '<br>';
    body += '<b>County:</b> ' + feature.properties.COUNTY;
    layer.bindPopup(body);
  }
}

// =============
// map layers
// =============

var bldfie = createRasterLayer('/data/map_rasters/bldfie_0.png')
var clyppt = createRasterLayer('/data/map_rasters/clyppt_1.png')
var sndppt = createRasterLayer('/data/map_rasters/sndppt_2.png')
var sltppt = createRasterLayer('/data/map_rasters/sltppt_3.png')
var hii = createRasterLayer('/data/map_rasters/hii_4.png')

var meixiOverlays = {
  "bldfie (bulk density)": bldfie,
  "clyppt (amount clay)": clyppt,
  "sltppt (amount silt)": sltppt,
  "sndppt (amount sand)": sndppt,
  "hii (human impact)": hii
}

var legend = L.control({position: 'bottomright'});

function createOverlayEventListeners(map) {
  map.on('overlayadd', function (eventLayer) {
    map.removeControl(legend);

    if (eventLayer.name === "bldfie (bulk density)") {
      legend.onAdd = function () {
        return createLegend('/data/map_rasters/bldfie_legend.png')
      }
      legend.addTo(map);

    } else if (eventLayer.name === "clyppt (amount clay)") {
      legend.onAdd = function () {
        return createLegend('/data/map_rasters/clyppt_legend.png')
      }
      legend.addTo(map);

    } else if (eventLayer.name === "sltppt (amount silt)") {
      legend.onAdd = function () {
        return createLegend('/data/map_rasters/sltppt_legend.png')
      }
      legend.addTo(map);

    } else if (eventLayer.name === "sndppt (amount sand)") {
      legend.onAdd = function () {
        return createLegend('/data/map_rasters/sndppt_legend.png')
      }
      legend.addTo(map);

    } else if (eventLayer.name === "hii (human impact)") {
      legend.onAdd = function () {
        return createLegend('/data/map_rasters/hii_legend.png')
      }
      legend.addTo(map);
    }
  });


  map.on('overlayremove', function (eventLayer) {
    map.removeControl(legend);
  });

}

function createOverlays (map) {
  $.get("/data/map_layers/uc_reserves.geojson", function(data) {
    var uc_reserves = L.geoJSON(JSON.parse(data), {
      onEachFeature: onEachFeatureHandler
    });

    $.get("/data/map_layers/HyspIRI_CA.geojson", function(data) {
      var geojsonMarkerOptions = {
        radius: 1,
        fillColor: "#000",
        color: "#000",
        weight: 1,
        opacity: 1,
        fillOpacity: 0.8
      };

      var HyspIRI_CA = L.geoJSON(JSON.parse(data), {
        pointToLayer: function (feature, latlng) {
          return L.circleMarker(latlng, geojsonMarkerOptions);
        }
      });

      var overlayMaps = {
        "HyspIRI": HyspIRI_CA,
        "UC Reserves": uc_reserves,
        ...meixiOverlays
      };

      L.control.layers(baseMaps, overlayMaps ).addTo(map);
    })
  })
}


// =============
// fetch data
// =============

function fetchSamples(apiEndpoint, map, cb) {
  $.get(apiEndpoint, function(data) {
    var samples = data.samples ? data.samples.data : [data.sample.data];
    var asvsCounts = data.asvs_count;
    var baseSamples = data.base_samples && data.base_samples.data;
    var samplesData;
    var baseSamplesData;

    samplesData = samples.filter(function(rawSample) {
      var sample = rawSample.attributes;
      return sample.latitude && sample.longitude;
    }).map(function(sample) {
      var asvs_count = findAsvCount(sample, asvsCounts);
      return formatSamplesData(sample, asvs_count)
    })
    filteredSamplesData = samplesData

    if (baseSamples) {
      baseSamplesData = baseSamples.filter(function(rawSample) {
        var sample = rawSample.attributes;
        return sample.latitude && sample.longitude;
      }).map(function(sample) {
        var asvs_count = null;
        return formatSamplesData(sample, asvs_count)
      })
    }

    cb({ samplesData, baseSamplesData })
  });

}


// =============
// config event listeners
// =============

var markerFormatEls = document.querySelectorAll('.js-marker-format');
var sampleStatusEl = document.querySelector('.js-sample-status');
var searchEl = document.querySelector('.js-map-search');
var searchKeywordEl = document.querySelector('.js-map-search-keyword');

// =============
// event listeners
// =============

function addEventListener(map, samplesData) {
  if(markerFormatEls) {
    markerFormatEls.forEach(function(el){
      el.addEventListener('click', function(event) {
        var format = event.target.value

        if(format == 'cluster' && currentMarkerFormat == 'individual') {
          currentMarkerFormat = 'cluster'

          map.removeLayer(individualMarkerLayer);
          markerClusterLayer.clearLayers()

          renderMarkerCluster(filteredSamplesData, map)
        } else if (format == 'individual' && currentMarkerFormat == 'cluster') {
          currentMarkerFormat = 'individual'

          map.removeLayer(markerClusterLayer);
          renderIndividualMarkers(filteredSamplesData, map)
        }
      });
    });
  }

  if (sampleStatusEl) {
    sampleStatusEl.addEventListener('change', function(event) {
      var status = event.target.value;
      filteredSamplesData = retrieveSamplesByStatus(status, samplesData)

      if(currentMarkerFormat == 'cluster') {
        markerClusterLayer.clearLayers()
        renderMarkerCluster(filteredSamplesData, map)
      } else {
        map.removeLayer(individualMarkerLayer);
        renderIndividualMarkers(filteredSamplesData, map)
      }
    })
  }

  if (searchEl) {
    searchEl.addEventListener('submit', function(event){
      event.preventDefault()
      var keyword = searchKeywordEl.value

      if(isSampleBarcode(keyword)) {
        // highlight one sample
        filteredSamplesData = filterSamplesByBarcode(samplesData, keyword)
        if(currentMarkerFormat == 'cluster') {
          renderMarkerCluster(filteredSamplesData, map)
        } else {
          renderIndividualMarkers(filteredSamplesData, map)
        }
      } else {
        // search taxa
        console.log('search taxa')
      }
    })
  }

}

// =============
// misc
// =============

function isSampleBarcode(string) {
  return /^k\d{4}-l(a|b|c)-s(1|2)$/.test(string.toLowerCase())
}

function filterSamplesByBarcode(samples, barcode) {
  return samples.filter(function(sample) {
    return sample.barcode == barcode
  })
}

function findAsvCount(sample, asvsCounts) {
  var asvs_data = asvsCounts.filter(function(counts) {
    return counts.sample_id == sample.id
  })[0]
  return asvs_data ? asvs_data.count : null;
}


function retrieveSamplesByStatus(status, samples) {
  if(status == 'approved') {
    return filterSamplesByStatus(samples, 'approved')
  } else if(status == 'processing_sample') {
    var processed = filterSamplesByStatus(samples, 'processing_sample')
    var assigned = filterSamplesByStatus(samples, 'assigned')
    return processed.concat(assigned)
  } else if(status == 'results_completed') {
    return filterSamplesByStatus(samples, 'results_completed')
  } else {
    return samples
  }
}

function filterSamplesByStatus(samples, status) {
  return samples.filter(function(sample) {
    return sample.status == status
  })
}


export default {
  fetchSamples,
  createMap,
  addEventListener,
  createOverlays,
  createOverlayEventListeners,
  createMarkerCluster,
  createCircleMarker,
  renderBasicIndividualMarkers,
  renderIndividualMarkers
};
