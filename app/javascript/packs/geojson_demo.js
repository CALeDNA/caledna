(function(){
  // =============
  // config map
  // =============

  var initialLat = 38.0;
  var initialLng = -118.3;
  var initialZoom = 6;
  var maxZoom = 25;

  var openstreetmap = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, Points &copy 2012 LINZ'
  });

  var latlng = L.latLng(initialLat, initialLng);
  var map = L.map('mapid', {
    center: latlng,
    zoom: initialZoom,
    maxZoom: maxZoom,
    layers: [openstreetmap]
  });


// =============
// fetch data
// =============

  function ecoRegionHandler(feature, layer) {
    if (feature.properties && feature.properties.ECOSYSTEM) {
      var body = '<b>Name:</b> ' + feature.properties.ECOSYSTEM + '<br>';
      layer.bindPopup(body);
    }
  }

  function fireHandler(feature, layer) {
    if (feature.properties && feature.properties.LATITUDE) {
      var body = '<b>Lat:</b> ' + feature.properties.LATITUDE + '<br>';
      body += '<b>Long:</b> ' + feature.properties.LONGITUDE + '<br>';
      body += '<b>Brightness:</b> ' + feature.properties.BRIGHTNESS + '<br>';
      layer.bindPopup(body);
    }
  }

  $.get("/data/demo_map_layers/MODIS_C6_CA_ActiveFire_7d_18.07.16.geojson", function(data) {
    var fires = L.geoJSON(JSON.parse(data),
      { onEachFeature: fireHandler });

    $.get("/data/demo_map_layers/CA_Ecoregions_Fish&WildlifeServices.geojson", function(data) {
      var ecoregions = L.geoJSON(JSON.parse(data),
        { onEachFeature: ecoRegionHandler });

      var overlayMaps = {
        'Modis Fires July 16, 2018': fires,
        'Fish & Wildlife Regions': ecoregions
      }

      var baseMaps = {};

      L.control.layers(baseMaps, overlayMaps).addTo(map);
    })
  })
})()
