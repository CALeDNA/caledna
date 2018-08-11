(function(){
  var initialLat = 38.0;
  var initialLng = -118.3;
  var initialZoom = 6;
  var maxZoom = 18;

  var tiles = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: maxZoom,
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, Points &copy 2012 LINZ'
  });
  var latlng = L.latLng(initialLat, initialLng);
  var map = L.map('mapid', {center: latlng, zoom: initialZoom, layers: [tiles]});

  map.on('zoomend', function() {
    var currentZoom = map.getZoom();
    if (currentZoom > 15) {
        map.removeLayer(icons);
        map.addLayer(icons2);
    }
  });

  $.get("/data/uc_reserves.geojson", function(data) {

    L.geoJSON(JSON.parse(data)).addTo(map);
  })

  function addMarker(rawSample) {
    var sample = rawSample.attributes;
    var lat = sample.latitude;
    var lng = sample.longitude;

    var id = sample.id;
    var barcode = sample.barcode;
    var projectName = sample.field_data_project_name;
    var sampleLink = "<a href='samples/" + sample.id + "'>" + barcode + "</a>";
    var status = sample.status;
    var asvsCount = 0;
    var body =
      '<b>Sample:</b> ' + sampleLink + '<br>' +
      '<b>Project:</b> ' + projectName + '<br>' +
      '<b>Lat/Long</b>: ' + lat + ', ' + lng + '<br>' +
      '<b>Status</b>: ' + status + '<br>' +
      '<b>Organism count</b>: ' + asvsCount + '<br>';

    var marker = L.marker(L.latLng(lat, lng), { title: 'Sample ' + barcode });
    marker.bindPopup(body);
    map.addLayer(marker);
  }

  function onEachFeatureHandler(feature, layer) {
    if (feature.properties && feature.properties.AgencyName) {
      var body = '<b>Name:</b> ' + feature.properties.Name + '<br>';
      body += '<b>County:</b> ' + feature.properties.COUNTY;
      layer.bindPopup(body);
    }
  }

  $.get("/data/uc_reserves.geojson", function(data) {
    L.geoJSON(JSON.parse(data), {
      onEachFeature: onEachFeatureHandler
    }).addTo(map);
  })

  $.get( "/api/v1/samples", function(data) {
    var samples = data.samples.data;

    samples.filter(function(rawSample) {
      var sample = rawSample.attributes;
      return sample.latitude && sample.longitude;
    }).forEach(addMarker);
  });

})()
