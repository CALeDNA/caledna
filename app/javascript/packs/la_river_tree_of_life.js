import * as d3 from "d3";
import convertFlatJsonToFlareJson from "../utils/flare_json";
import baseTree from "./base_tree.js";

// Set the dimensions and margins of the diagram
let viewerWidth = baseTree.viewerWidth;

const initOptions = {
  myCircleRadius: 14,
  myNodeTextXOffset: 17,
  myCircleFontSize: "20px"
};
baseTree.init(initOptions);

let enpoint = `/api/v1/la_river/tree_of_life`;
$.get(enpoint, function(data) {
  let flareData = convertFlatJsonToFlareJson(data, "id");

  let svgOptions = {
    selector: "#asv-tree"
  };
  const svg = baseTree.createSvg(svgOptions);
  let tree = d3.tree();
  const root = baseTree.createRoot(flareData);
  const longestLabelLength = baseTree.calculateLongestLabelLength(data);
  const maxLabelLength = longestLabelLength * 10;

  // Collapse after the second level
  root.children.forEach(baseTree.collapse);

  update(root, root);
  baseTree.centerNode(root, svg);

  function update(source, rootNode) {
    // tree, viewerWidth, longestLabelLength, svg, toggleChildren
    let nodesPerLevel = [1];
    baseTree.updateNodeCount(0, rootNode, nodesPerLevel);

    let newHeight = d3.max(nodesPerLevel) * 40; // xx pixels per line
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
});
