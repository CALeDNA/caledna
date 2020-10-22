import L from "leaflet";
import "leaflet-svg-shape-markers";

// import { ecotopesJson } from "./data/ecotopes.js";
import { riversJson } from "../data/rivers";
import { watershedJson } from "../data/watershed";
import { LARWMPJson } from "../data/sites_2018";
import base_map from "./base_map";
import { formatClassifications, findClassificationColor } from '../utils/map_colors';

export function initMap(selector = "map", customLayer) {
  let tiles = base_map.tileLayersFactory();
  tiles["None"] = L.tileLayer('');
  let defaultLayer = customLayer ? customLayer : tiles.Minimal;

  let map = L.map(selector, {
    zoomControl: true,
    maxZoom: 18,
    minZoom: 6,
    layers: [defaultLayer],
  }).fitBounds([
    [33.679246670913905, -118.6974911092205],
    [34.45898102165338, -117.94488821092733],
  ]);

  L.control.layers(tiles).addTo(map);

  return map;
}


export function createTaxonClassifications(items) {
  if (items.length === 0) { return [] }

  let values = items.map(s => (s.count));
  return formatClassifications(values)
}

export function createAnalyteClassifications(analyte) {
  let values = LARWMPJson.features
    .filter((feature) => { return feature.properties[analyte] })
    .map((feature) => { return feature.properties[analyte] })

  return formatClassifications(values);
}

function formatFloats(value, precision) {
  if (typeof (value) === 'number' && !Number.isInteger(value)) {
    return Number((value).toFixed(precision));
  } else {
    return value;
  }
}

export function createMapLegend(classifications, colors, title) {
  let legend = L.control({ position: "bottomleft" });
  legend.onAdd = function () {
    var div = L.DomUtil.create("div", "map-legend");
    div.innerHTML = title;

    classifications.forEach((classification, index) => {
      div.innerHTML += `
      <div>
        <svg width="20" height="20">
          <rect width="18" height="18"
            style="fill:${colors[index]};stroke-width:1;stroke:${colors[3]}" />
        </svg>
        <span>${classification.begin} - ${classification.end}</span>
      </div>
      `;
    });

    return div;
  };
  return legend;
}


function LARWMP_popup(feature, analyte) {
  let value = feature.properties[analyte];
  return `
    <p>${analyte}</p>
    <table class="map-popup">
      <tr>
        <th scope="row">Name</th>
        <td>${feature.properties["FieldSampleID"]}</td>
      </tr>
      <tr>
        <th scope="row">Latitude</th>
        <td>${feature.properties["NominalLatitude"]}</td>
      </tr>
      <tr>
        <th scope="row">Longitude</th>
        <td>${feature.properties["NominalLongitude"]}</td>
      </tr>
      <tr>
        <th scope="row">${analyte}</th>
        <td>${value}</td>
      </tr>
    </table>
  `;
}

// output: geoJson
export function createAnalyteLayer(analyte, classifications, colors) {
  let filteredData = LARWMPJson.features.filter(feature => {
    return feature.properties[analyte]
  })

  function create_popup(feature, layer) {
    let popup = LARWMP_popup(feature, analyte);
    layer.bindPopup(popup);
  }

  function create_style(feature) {
    let color = findClassificationColor(feature.properties[analyte], classifications, colors);
    return {
      shape: "square",
      radius: 7,
      opacity: 0.9,
      weight: 1,
      fillOpacity: 0.9,
      color: "#222",
      fillColor: color,
    };
  }

  return new L.geoJson(filteredData, {
    onEachFeature: create_popup,
    pointToLayer: function (feature, latlng) {
      return L.shapeMarker(latlng, create_style(feature));
    },
  });
}

// output: geoJson
export function createRiverLayer() {
  var style = {
    opacity: .8,
    color: "rgba(19,133,255,1.0)",
    weight: 1.75,
  };

  function createPopup(feature, layer) {
    let popup = `
      <p>LA River Watershed</p>
      <table class="map-popup">
        <tr>
          <th scope="row">Name</th>
          <td>${feature.properties["GNIS_NAME"]}</td>
        </tr>
      </table>
    `;

    layer.bindPopup(popup, { maxHeight: 400 });
  }

  return new L.geoJson(riversJson, {
    style: style,
    onEachFeature: createPopup,
    interactive: true,
  });
}

// output: geoJson
export function createWatershedLayer() {
  var style = {
    opacity: 1,
    color: "rgba(100,100,100,1)",
    weight: 2.0,
    fillOpacity: 0.3,
    fillColor: "rgba(190,190,190,0.9)",
    interactive: false,
  };

  return new L.geoJson(watershedJson, {
    style: style,
  });
}

// output: featureGroup
export function pourLocationsLayer(places) {
  var pointStyle = {
    shape: "triangle",
    radius: 6,
    color: "#222",
    fillColor: "#5aa172",
    fillOpacity: 0.9,
    weight: 2,
  };

  let markers = places.map((place) => {
    let popup = `
      <p>Protecting Our River</p>

      <table class="map-popup">
        <tr>
          <th scope="row">Name</th>
          <td><a href="/places/${place.id}">${place.name}</a></td>
        </tr>
        <tr>
          <th scope="row">Latitude</th>
          <td>${place.latitude}</td>
        </tr>
        <tr>
          <th scope="row">Longitude</th>
          <td>${place.longitude}</td>
        </tr>
      </table>
    `;
    let marker = L.shapeMarker([place.latitude, place.longitude], pointStyle);
    marker.bindPopup(popup);
    return marker;
  });
  return L.featureGroup(markers);
}

// output: geoJson
export function LARWMPLocationsLayer() {
  var pointStyle = {
    shape: "triangle",
    radius: 6,
    color: "#222",
    fillColor: "orange",
    fillOpacity: 0.9,
    weight: 2,
  };

  function createPopup(feature, layer) {
    let popup = `
      <p>Los Angeles River Watershed Monitoring Program</p>

      <table class="map-popup">
        <tr>
          <th scope="row">Name</th>
          <td>${feature.properties["FieldSampleID"]}</td>
        </tr>
        <tr>
          <th scope="row">Station Type</th>
          <td>${feature.properties["StationType"]}</td>
        </tr>
        <tr>
          <th scope="row">Latitude</th>
          <td>${feature.properties["NominalLatitude"]}</td>
        </tr>
        <tr>
          <th scope="row">Longitude</th>
          <td>${feature.properties["NominalLongitude"]}</td>
        </tr>
      </table>
    `;

    layer.bindPopup(popup, { maxHeight: 400 });
  }

  return new L.geoJson(LARWMPJson, {
    onEachFeature: createPopup,
    pointToLayer: function (_feature, latlng) {
      return L.shapeMarker(latlng, pointStyle);
    },
  });
}

function createEdnaPopup(sample, taxonName) {
  return `<p>eDNA Site for ${taxonName}</p>

  <table class="map-popup">
    <tr>
      <th scope="row">Name</th>
      <td><a href="/samples/${sample.id}">${sample.barcode}</a></td>
    </tr>
    <tr>
      <th scope="row">Latitude</th>
      <td>${sample.latitude}</td>
    </tr>
    <tr>
      <th scope="row">Longitude</th>
      <td>${sample.longitude}</td>
    </tr>
    <tr>
      <th scope="row">Collection Period</th>
      <td>${sample.metadata.collection_period}</td>
    </tr>
  </table>`;
}

// output: featureGroup
export function taxonEdnaLayer(groupedEdnaSamples, taxonName) {
  let markers = []

  for (const period in groupedEdnaSamples) {
    const sampleGroup = groupedEdnaSamples[period];
    sampleGroup.samples.forEach((sample) => {
      let popup = createEdnaPopup(sample, taxonName, period)
      sample["body"] = popup;
      markers.push(base_map.createCircleMarker(sample, { fillColor: sampleGroup.color, weight: 1 }));
    })
  }

  return L.featureGroup(markers);
}

// output: featureGroup
export function taxonGbifLayer(items, classifications, colors, taxonName) {
  let markers = items.map((item) => {
    function createPopup(feature, layer) {
      let popup = `
      <p>iNaturalist Observations for ${taxonName}</p>

      <table class="map-popup">
        <tr>
          <th scope="row">Count</th>
          <td>${item.count} observations</td>
        </tr>
        <tr>
          <th scope="row">Latitude</th>
          <td>${item.latitude}</td>
        </tr>
        <tr>
          <th scope="row">Longitude</th>
          <td>${item.longitude}</td>
        </tr>
        <tr>
          <th scope="row">Hexagon ID</th>
          <td>${item.id}</td>
        </tr>
      </table>
      `;

      layer.bindPopup(popup, { maxHeight: 400 });
    }

    let color = findClassificationColor(item.count, classifications, colors);

    var myStyle = {
      color: colors[2],
      fillColor: color,
      fillOpacity: 0.9,
      weight: 1,
      opacity: 0.9,
    };

    return L.geoJSON(JSON.parse(item.geom), {
      onEachFeature: createPopup,
      style: myStyle,
    });
  });
  return L.featureGroup(markers);
}

// output: featureGroup
export function createMapgridLayer(items, classifications, colors, type) {
  let markers = items.map((item) => {
    function createPopup(feature, layer) {
      let popup = `
        <table class="map-popup">
          <tr>
            <th scope="row">Count</th>
            <td>${item.count} ${type}</td>
          </tr>
          <tr>
            <th scope="row">Latitude</th>
            <td>${item.latitude}</td>
          </tr>
          <tr>
            <th scope="row">Longitude</th>
            <td>${item.longitude}</td>
          </tr>
          <tr>
            <th scope="row">Hexagon ID</th>
            <td>${item.id}</td>
          </tr>
        </table>
      `;
      layer.bindPopup(popup);
    }

    let color = findClassificationColor(item.count, classifications, colors);

    var myStyle = {
      color: colors[3],
      weight: .5,
      opacity: 1,
      fillColor: color,
      fillOpacity: 0.9,
    };

    return L.geoJSON(JSON.parse(item.geom), {
      onEachFeature: createPopup,
      style: myStyle,
    });
  });
  return L.featureGroup(markers);
}

