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
  var markerLayer;
  var disableClustering = 15;

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

  var markerCluster = L.markerClusterGroup({
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
      markerCluster.addLayer(marker);
    });
  }

  function createMarkerLayer(samples, createMarkerFn) {
    var markers = samples.map(function(sample) {
      return createMarkerFn(sample)
    });
    markerLayer = L.layerGroup(markers)
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

  $.get("/data/uc_reserves.geojson", function(data) {
    var uc_reserves = L.geoJSON(JSON.parse(data), {
      onEachFeature: onEachFeatureHandler
    });

    var overlayMaps = {
      "UC Reserves": uc_reserves
    };

    L.control.layers(baseMaps, overlayMaps ).addTo(map);

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
    map.addLayer(markerCluster);
  });

  // =============
  // config event listeners
  // =============

  var clusterMarkersEls = document.querySelectorAll('.js-marker-type');

  // =============
  // event listeners
  // =============

  clusterMarkersEls.forEach(function(el){
    el.addEventListener('click', function(event) {
      var type = event.target.value
      if(type == 'cluster') {
        // turn on clustering
        map.removeLayer(markerLayer);
        map.addLayer(markerCluster);
      } else {
        // turn off clustering
        map.removeLayer(markerCluster);
        createMarkerLayer(filteredSamplesData, createCircleMarker)
        markerLayer.addTo(map)
      }
    });
  });


  // =============
  // misc
  // =============

  function findAsvCount(sample, asvsCounts) {
    var asvs_data = asvsCounts.filter(function(counts) {
      return counts.sample_id == sample.id
    })[0]
    return asvs_data ? asvs_data.count : null;
  }

})()
