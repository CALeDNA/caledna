import * as d3 from "d3";
import convertFlatJsonToFlareJson from "../utils/flare_json";
import baseTree from "./base_tree.js";
import data from "../data/la_river_taxa_tree.json";
import * as spec from "../vega_specs/tree_map.json";

// =====================
// setup
// =====================
const TREE1 = "#asv-tree1";
const TREE2 = "#asv-tree2";

const tree2El = document.querySelector(TREE2);
const tree1El = document.querySelector(TREE1);

let flareData = convertFlatJsonToFlareJson(data, "id");

let viewerWidth = baseTree.viewerWidth;
let longestLabelFactor = 10;
let nodeHeightFactor = 45;

const initOptions = {
  myCircleRadius: 14,
  myNodeTextXOffset: 17,
  myCircleFontSize: "20px",
};
baseTree.init(initOptions);

// =====================
// create tree
// =====================

let svgOptions = {
  selector: TREE1,
};
const svg = baseTree.createSvg(svgOptions);
let tree = d3.tree();
const root = baseTree.createRoot(flareData);
const longestLabelLength = baseTree.calculateLongestLabelLength(data);
const maxLabelLength = longestLabelLength * longestLabelFactor;

// Collapse after the second level
root.children.forEach(baseTree.collapse);

update(root, root);
baseTree.centerNode(root, svg);

// =====================
// set up vega static tree
// =====================

var stratifySettings = spec.data[0].transform.filter(
  (item) => item.type == "stratify"
)[0];
var textSettings = spec.marks.filter((mark) => mark.type == "text")[0];

spec.height = data.length * 16;
spec.width = 3000;
spec.data[0].values = data;
stratifySettings.key = "id";
stratifySettings.parentKey = "parent_id";
textSettings.encode.enter.text.field = "name";
textSettings.encode.enter.fontSize.value = 14;

var view = new vega.View(vega.parse(spec), {
  renderer: "svg",
  container: TREE2,
});

view.runAsync().then(() => {
  if (tree2El) {
    tree2El.style.display = "none";
  }
});

// =====================
// create interactive buttons
// =====================

d3.select(".js-interactive").on("click", () => {
  if (tree2El && tree1El) {
    tree2El.style.display = "none";
    tree1El.style.display = "block";
  }
});

d3.select(".js-static").on("click", () => {
  if (tree2El && tree1El) {
    tree2El.style.display = "block";
    tree1El.style.display = "none";
  }
});

// =====================
// functions
// =====================

function update(source, rootNode) {
  // tree, viewerWidth, longestLabelLength, svg, toggleChildren
  let nodesPerLevel = [1];
  baseTree.updateNodeCount(0, rootNode, nodesPerLevel);

  let newHeight = d3.max(nodesPerLevel) * nodeHeightFactor;
  tree = tree.size([newHeight, viewerWidth]);

  // Assigns the x and y position for the nodes
  let treeData = tree(rootNode);

  // Compute the new tree layout.
  let nodes = treeData.descendants();
  let links = treeData.descendants().slice(1);

  baseTree.setLevelWidth(nodes, maxLabelLength);
  baseTree.handleNodes(svg, source, nodes, toggleChildren);
  baseTree.handleLinks(svg, source, links);
}

function toggleChildren(source) {
  if (source.children) {
    // close nodes
    source._children = source.children;
    source.children = null;
  } else {
    // open child nodes
    source.children = source._children;
    source._children = null;
  }
  update(source, root);
  baseTree.centerNode(source, svg);
}
