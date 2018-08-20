(function(){
  // =============
  // config map
  // =============

  var initialLat = 38.0;
  var initialLng = -118.3;
  var fillColor = '#5aa172';
  var strokeColor = '#222';
  var initialZoom = 6;
  var maxZoom = 25;
  var samplesData = []
  var filteredSamplesData = []
  var disableClustering = 15;
  var currentMarkerFormat = 'cluster';

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
  var map = L.map('mapid-advance', {
    center: latlng,
    zoom: initialZoom,
    maxZoom: maxZoom,
    layers: [openstreetmap]
  });

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

  function formatSamplesData(rawSample, asvsCount) {
    var sample = rawSample.attributes;
    var lat = sample.latitude;
    var lng = sample.longitude;
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

    return {
      lat: lat,
      lng: lng,
      barcode: barcode,
      body: body,
      status: status,
    }
  }

  function createCircleMarker (sample) {
    var options = {fillColor: fillColor, radius: 7, fillOpacity: .7, color: strokeColor, weight: 2};
    var circleMarker = L.circleMarker(L.latLng(sample.lat, sample.lng), options);
    circleMarker.bindPopup(sample.body);
    return circleMarker;
  }

  function createMarkerCluster(samples, createMarkerFn) {
    samples.forEach(function(sample) {
      var marker = createMarkerFn(sample)
      markerClusterLayer.addLayer(marker);
    });
  }

  function createMarkerLayer(samples, createMarkerFn) {
    var markers = samples.map(function(sample) {
      return createMarkerFn(sample)
    });
    individualMarkerLayer = L.layerGroup(markers)
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
// fetch data
// =============

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
        "HyspIRI CA": HyspIRI_CA,
        "UC Reserves": uc_reserves
      };

      L.control.layers(baseMaps, overlayMaps ).addTo(map);

    })
  })

  $.get( "/api/v1/samples", function(data) {
    var samples = data.samples.data;
    var asvsCounts = data.asvs_count;

    samplesData = samples.filter(function(rawSample) {
      var sample = rawSample.attributes;
      return sample.latitude && sample.longitude;
    }).map(function(sample) {
      var asvs_count = findAsvCount(sample, asvsCounts);
      return formatSamplesData(sample, asvs_count)
    })

    filteredSamplesData = samplesData

    createMarkerCluster(filteredSamplesData, createCircleMarker)
    map.addLayer(markerClusterLayer);
  });

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

  markerFormatEls.forEach(function(el){
    el.addEventListener('click', function(event) {
      var format = event.target.value

      if(format == 'cluster' && currentMarkerFormat == 'individual') {
        currentMarkerFormat = 'cluster'

        map.removeLayer(individualMarkerLayer);
        renderMarkerCluster(filteredSamplesData)
      } else if (format == 'individual' && currentMarkerFormat == 'cluster') {
        currentMarkerFormat = 'individual'

        map.removeLayer(markerClusterLayer);
        renderIndividualMarkers(filteredSamplesData)
      }
    });
  });


  sampleStatusEl.addEventListener('change', function(event) {
    var status = event.target.value;
    filteredSamplesData = retrieveSamplesByStatus(status, samplesData)

    if(currentMarkerFormat == 'cluster') {
      renderMarkerCluster(filteredSamplesData)
    } else {
      renderIndividualMarkers(filteredSamplesData)
    }
  })

  searchEl.addEventListener('submit', function(event){
    event.preventDefault()
    var keyword = searchKeywordEl.value

    if(isSampleBarcode(keyword)) {
      // highlight one sample
      filteredSamplesData = filterSamplesByBarcode(samplesData, keyword)
      if(currentMarkerFormat == 'cluster') {
        renderMarkerCluster(filteredSamplesData)
      } else {
        renderIndividualMarkers(filteredSamplesData)
      }
    } else {
      // search taxa
      console.log('search taxa')
    }

  })



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

  function renderMarkerCluster(samples) {
    markerClusterLayer.clearLayers()
    createMarkerCluster(samples, createCircleMarker)
    map.addLayer(markerClusterLayer);
  }

  function renderIndividualMarkers (samples) {
    map.removeLayer(individualMarkerLayer);
    createMarkerLayer(samples, createCircleMarker)
    individualMarkerLayer.addTo(map)
  }

  function retrieveSamplesByStatus(status, samples) {
    if(status == 'approved') {
      return filterSamplesByStatus(samples, 'approved')
    } else if(status == 'processing_sample') {
      var processed = filterSamplesByStatus(samples, 'processing_sample')
      var assigned = filterSamplesByStatus(samples, 'assigned')
      return processed.concat(assigned)
    } else if(event.target.value == 'results_completed') {
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

})()
