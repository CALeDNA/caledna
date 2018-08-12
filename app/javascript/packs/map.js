(function(){
  // =============
  // config event listeners
  // =============
  var clusterMarkersEl = document.querySelector('.js-cluster-markers');

  // =============
  // event listeners
  // =============

  clusterMarkersEl.addEventListener('click', function(event) {
    if(event.target.checked) {
      // turn on clustering
      map.removeLayer(markerLayer);
      map.addLayer(markerCluster);
    } else {
      // turn off clustering
      map.removeLayer(markerCluster);
      createMarkerLayer(samplesData, createCircleMarker)
      markerLayer.addTo(map)
    }
  })


  // =============
  // config map
  // =============

  var initialLat = 38.0;
  var initialLng = -118.3;
  var darkColor = '#5aa172';
  var lightColor = '#444';
  var initialZoom = 6;
  var maxZoom = 30;
  var samplesData = []
  var markerLayer;
  var disableClustering = 15;

  var openstreetmap = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: maxZoom,
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, Points &copy 2012 LINZ'
  });

  var accessToken = 'pk.eyJ1Ijoid3lraHVoIiwiYSI6ImNqY2gzMHJ3OTIyeW4zM210Zmgwd2ZoMXEifQ.p-v5zVFnVgvvdxKiVRpCRA';
  var mapboxSatellite = L.tileLayer('https://api.mapbox.com/v4/mapbox.satellite/{z}/{x}/{y}.png?access_token=' + accessToken, {
      attribution: '© <a href="https://www.mapbox.com/feedback/">Mapbox</a> © <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
  });

  var latlng = L.latLng(initialLat, initialLng);
  var map = L.map('mapid-advance', {
    center: latlng,
    zoom: initialZoom,
    maxZoom: maxZoom,
    layers: [openstreetmap]
  });

  var baseMaps = {
    Normal: openstreetmap,
    Satellite: mapboxSatellite,
  };

  var markerCluster = L.markerClusterGroup({
    disableClusteringAtZoom: disableClustering,
    spiderfyOnMaxZoom: false
  });

  // =============
  // create markers
  // =============

  function formatSamplesData(rawSample) {
    var sample = rawSample.attributes;
    var lat = sample.latitude;
    var lng = sample.longitude;
    var id = sample.id;
    var barcode = sample.barcode;
    var projectName = sample.field_data_project_name;
    var sampleLink = "<a href='/samples/" + sample.id + "'>" + barcode + "</a>";
    var status = sample.status;
    var asvsCount = 0;
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
    var options = {fillColor: darkColor, radius: 7, fillOpacity: .5, color: lightColor, weight: 2};
    var circleMarker = L.circleMarker(L.latLng(sample.lat, sample.lng), options);
    circleMarker.bindPopup(sample.body);
    return circleMarker;
  }

  function createMarkerCluster(samplesData, createMarkerFn) {
    samplesData.forEach(function(sample) {
      var marker = createMarkerFn(sample)
      markerCluster.addLayer(marker);
    });
  }

  function createMarkerLayer(samplesData, createMarkerFn) {
    var markers = samplesData.map(function(sample) {
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

    samplesData = samples.filter(function(rawSample) {
      var sample = rawSample.attributes;
      return sample.latitude && sample.longitude;
    }).map(formatSamplesData)

    createMarkerCluster(samplesData, createCircleMarker)
    map.addLayer(markerCluster);
  });

})()
