const taxonId = window.caledna && window.caledna.gbif_id;

if (taxonId) {
  const map = L.map("gbif-occurrence-map", {
    center: L.latLng(0, 0),
    zoom: 1,
    minZoom: 1,
    maxZoom: 18
  });

  // gbif map tiles
  L.tileLayer(
    "https://tile.gbif.org/3857/omt/{z}/{x}/{y}@2x.png?style=gbif-geyser"
  ).addTo(map);

  // gbif occurrences
  const hexPerTile = 50;
  const apiEndpoint =
    "https://api.gbif.org/v2/map/occurrence/density/{z}/{x}/{y}@2x.png?srs=EPSG:3857" +
    `&style=purpleYellow.poly&bin=hex&hexPerTile=${hexPerTile}&taxonKey=${taxonId}`;
  L.tileLayer(apiEndpoint).addTo(map);
}
