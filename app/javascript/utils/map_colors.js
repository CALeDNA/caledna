import { ckmeans } from 'simple-statistics'

// https://colorbrewer2.org/
let oneColorSchemes = [
  ['#eff3ff', '#bdd7e7', '#6baed6', '#3182bd', '#08519c'], // Blues
  ['#edf8e9', '#bae4b3', '#74c476', '#31a354', '#006d2c'], // Greens
  ['#f7f7f7', '#cccccc', '#969696', '#636363', '#252525'], // Greys
  ['#feedde', '#fdbe85', '#fd8d3c', '#e6550d', '#a63603'], // Oranges
  ['#f2f0f7', '#cbc9e2', '#9e9ac8', '#756bb1', '#54278f'], // Purples
  ['#fee5d9', '#fcae91', '#fb6a4a', '#de2d26', '#a50f15'], // Reds
];

let multiColorsSchemes = [
  ["#edf8fb", "#b2e2e2", "#66c2a4", "#2ca25f", "#006d2c"], // BuGn
  ["#edf8fb", "#b3cde3", "#8c96c6", "#8856a7", "#810f7c"], // BuPu
  ["#f0f9e8", "#bae4bc", "#7bccc4", "#43a2ca", "#0868ac"], // GnBu
  ["#fef0d9", "#fdcc8a", "#fc8d59", "#e34a33", "#b30000"], // OrRd
  ["#f1eef6", "#bdc9e1", "#74a9cf", "#2b8cbe", "#045a8d"], // PuBu
  ["#f6eff7", "#bdc9e1", "#67a9cf", "#1c9099", "#016c59"], // PuBuGn
  ["#f1eef6", "#d7b5d8", "#df65b0", "#dd1c77", "#980043"], // PuRd
  ["#feebe2", "#fbb4b9", "#f768a1", "#c51b8a", "#7a0177"], // RdPu
  ["#ffffcc", "#c2e699", "#78c679", "#31a354", "#006837"], // YlGn
  ["#ffffcc", "#a1dab4", "#41b6c4", "#2c7fb8", "#253494"], // YlGnBu
  ["#ffffd4", "#fed98e", "#fe9929", "#d95f0e", "#993404"], // YlOrBr
  ["#ffffb2", "#fecc5c", "#fd8d3c", "#f03b20", "#bd0026"], // YlOrRd
];

let siteColorSchemes = [
  ['#eff3ff', '#bdd7e7', '#6baed6', '#3182bd', '#08519c'], // Blues
  ['#edf8e9', '#bae4b3', '#74c476', '#31a354', '#006d2c'], // Greens
  ["#f1eef6", "#d7b5d8", "#df65b0", "#dd1c77", "#980043"], // PuRd
  ['#f7f7f7', '#cccccc', '#969696', '#636363', '#252525'], // Greys
  ['#feedde', '#fdbe85', '#fd8d3c', '#e6550d', '#a63603'], // Oranges
  ['#f2f0f7', '#cbc9e2', '#9e9ac8', '#756bb1', '#54278f'], // Purples
  ['#fee5d9', '#fcae91', '#fb6a4a', '#de2d26', '#a50f15'], // Reds
  ["#feebe2", "#fbb4b9", "#f768a1", "#c51b8a", "#7a0177"], // RdPu
];

let colors = ['#543005', '#f6e8c3', '#35978f', '#8c510a', '#f5f5f5',
  '#01665e', '#bf812d', '#c7eae5', '#003c30', '#dfc27d', '#80cdc1'
]

export function formatClassifications(values) {
  let dataClasses = 5;
  let uniqueValues = new Set(values);
  let clusterCount = uniqueValues.size >= dataClasses ? dataClasses : uniqueValues.size;
  let clusters = ckmeans(values, clusterCount);

  return clusters.map((cluster, index) => {
    return {
      begin: cluster[0],
      end: cluster[cluster.length - 1]
    }
  })
}


export function findClassificationColor(value, classifications, colors) {
  if (classifications[0] && value <= classifications[0].end) {
    return colors[0];
  } else if (classifications[1] && value <= classifications[1].end) {
    return colors[1];
  } else if (classifications[2] && value <= classifications[2].end) {
    return colors[2];
  } else if (classifications[3] && value <= classifications[3].end) {
    return colors[3];
  } else if(classifications[4]) {
    return colors[4];
  }
}

export function randomColor() {
  return colors[getRandomInt(colors.length)]
}

export function targetColor(number) {
  return colors[number]
}


// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Math/random
// results do not include max
function getRandomInt(max) {
  return Math.floor(Math.random() * Math.floor(max));
}

function randomHslaColor() {
  return `hsla(${Math.floor(Math.random() * 360)}, 90%, 50%, 1)`;
}

function randomHslRange() {
  let rand = Math.floor(Math.random() * 360);
  return [
    `hsla(${rand}, 80%, 90%, 1)`,
    `hsla(${rand}, 80%, 70%, 1)`,
    `hsla(${rand}, 80%, 50%, 1)`,
    `hsla(${rand}, 80%, 30%, 1)`,
    `hsla(${rand}, 80%, 10%, 1)`,
  ];
}

export function randomColorRange() {
  let int = getRandomInt(siteColorSchemes.length);
  return siteColorSchemes[int];
}

export function targetColorRange(number) {
  let int = number % siteColorSchemes.length;
  return siteColorSchemes[int];
}
