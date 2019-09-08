var taxonId = window.caledna && window.caledna.gbif_id;

if (taxonId) {
  var map = L.map("gbif-occurrence-map", {
    center: L.latLng(30, 0),
    zoom: 1,
    maxZoom: 18
  });

  // map tiles
  L.tileLayer(
    "https://tile.gbif.org/3857/omt/{z}/{x}/{y}@2x.png?style=gbif-geyser"
  ).addTo(map);

  // gbif occurrences
  var hexPerTile = 50;
  var apiEndpoint =
    "https://api.gbif.org/v2/map/occurrence/density/{z}/{x}/{y}@2x.png?srs=EPSG:3857" +
    `&style=purpleYellow.poly&bin=hex&hexPerTile=${hexPerTile}&taxonKey=${taxonId}`;
  L.tileLayer(apiEndpoint).addTo(map);
}
