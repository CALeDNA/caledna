import * as d3 from "d3";

import { Spinner } from "spin.js";
import baseTree from "./base_tree.js";

// =================
// setup
// =================

const endpoint = `/api/v1${window.location.pathname}/taxa_list`;
let root;
let longestLabelLength;
let maxLabelLength;
let svg;
let tree;
// Set the dimensions and margins of the diagram
let viewerWidth = baseTree.viewerWidth;
let longestLabelFactor = 10;
let nodeHeightFactor = 45;

const treeOptions = {
  myCircleRadius: 14,
  myNodeTextXOffset: 17,
  myCircleFontSize: "20px",
};
const spinnerOptions = { color: "#333", left: "50%", scale: 1.75 };
let svgOptions = {
  selector: "#js-asv-tree",
};

// =================
// methods
// =================

export function asv_tree_init(data, nestedData) {
  baseTree.init(treeOptions);

  let spinner = new Spinner(spinnerOptions).spin(
    document.querySelector("#js-asv-tree")
  );

  svg = baseTree.createSvg(svgOptions);
  tree = d3.tree();

  root = baseTree.createRoot(nestedData);
  longestLabelLength = baseTree.calculateLongestLabelLength(data);
  maxLabelLength = longestLabelLength * longestLabelFactor;

  // Collapse after the second level
  root.children.forEach(baseTree.collapse);

  update(root, root);
  baseTree.centerNode(root, svg);

  spinner.stop();
}

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
