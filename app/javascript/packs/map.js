(function(){
  var initialLat = 38.0;
  var initialLng = -118.3;
  var initialZoom = 6;
  var maxZoom = 18;
  window.markerType = 'circle';

  var tiles = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: maxZoom,
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, Points &copy 2012 LINZ'
  });
  var latlng = L.latLng(initialLat, initialLng);
  var map = L.map('mapid-advance', {center: latlng, zoom: initialZoom, layers: [tiles]});

  map.on('zoomend', zoomHandler);

  function zoomHandler () {
    var currentZoom = map.getZoom();
    var currentMarkerType = getMarkerType();
    console.log('boo', currentZoom, currentMarkerType)

    if(currentZoom > 9 && currentMarkerType == 'circle') {
      addMarkers(samplesData, addIconMarker, 'icon')

    } else if(currentZoom <= 9 && currentMarkerType == 'icon') {
      addMarkers(samplesData, addCircleMarker, 'circle')
    }
  }



  function getMarkerType() {
    console.log('getMarkerType', markerType)
    return markerType
  }

  function formatSamplesData(rawSample) {
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

    return {
      lat: lat,
      lng: lng,
      barcode: barcode,
      body: body

    }
  }

  var samplesData = []
  var markers = []

  function addIconMarker (sample) {
    var marker = L.marker(L.latLng(sample.lat, sample.lng), { title: 'Sample ' + sample.barcode });
    marker.bindPopup(sample.body);
    map.addLayer(marker);
    return marker;
  }

  function addCircleMarker (sample) {
    var options = {fillColor: '#333', radius: 7, fillOpacity: .3, color: '#ccc', weight: 1};
    var circleMarker = L.circleMarker(L.latLng(sample.lat, sample.lng), options)
      .addTo(map);
    circleMarker.bindPopup(sample.body);
    return circleMarker;
  }

  function addMarkers(samplesData, markerFn, markerType) {
    resetMarkers()
    window.markerType = markerType;
    console.log('addMarkers', window.markerType)
    markers = samplesData.map(markerFn);
  }

  function resetMarkers() {
    markers.forEach(function(marker){
      map.removeLayer(marker);
    });
    markers = [];
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

    samplesData = samples.filter(function(rawSample) {
      var sample = rawSample.attributes;
      return sample.latitude && sample.longitude;
    }).map(formatSamplesData)

    addMarkers(samplesData, addCircleMarker, 'circle')
  });

})()
