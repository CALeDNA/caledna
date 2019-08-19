// Collapsible tree diagram in v4
// https://bl.ocks.org/d3noob/43a860bc0024792f8803bba8ca0d5ecd

// change height
//https://stackoverflow.com/a/14145316
// https://codepen.io/marxtseng/pen/oBVjvB?editors=1010

// https://observablehq.com/@d3/collapsible-tree

import * as d3 from "d3";
import convertFlatJsonToFlareJson from "../utils/flare_json";

var data = window.caledna.asv_tree;
var treeData = convertFlatJsonToFlareJson(data, "id");

// Set the dimensions and margins of the diagram
let margin = { top: 20, right: 90, bottom: 30, left: 90 };
let i = 0;
let duration = 750;
var maxLabelLength = 0;
var viewerWidth = window.innerWidth * 1.5;
var viewerHeight = window.innerHeight * 2;

const svg = d3
  .select("#asv-tree")
  .append("svg")
  .attr("width", viewerWidth)
  .attr("height", viewerHeight)
  .call(
    d3
      .zoom()
      .filter(function() {
        // disable double click
        return !d3.event.button && d3.event.type != "dblclick";
      })
      .on("zoom", zoom)
  )
  .call(responsivefy)
  .append("g");

var tree = d3.tree();

const root = d3.hierarchy(treeData, function(d) {
  return d.children;
});
root.x0 = 0;
root.y0 = 0;

// Collapse after the second level
root.children.forEach(collapse);

// find the longest name
data.forEach(datum => {
  if (datum.name) {
    maxLabelLength = Math.max(datum.name.length, maxLabelLength);
  }
});

update(root);
centerNode(root);

function update(source, rootNode = root) {
  var nodesPerLevel = [1];
  updateNodeCount(0, root, nodesPerLevel);

  var newHeight = d3.max(nodesPerLevel) * 40; // 25 pixels per line
  tree = tree.size([newHeight, viewerWidth]);

  // Assigns the x and y position for the nodes
  var treeData = tree(rootNode);

  // Compute the new tree layout.
  var nodes = treeData.descendants();
  var links = treeData.descendants().slice(1);

  // Set widths between levels based on maxLabelLength.
  nodes.forEach(function(d) {
    d.y = d.depth * (maxLabelLength * 10); //maxLabelLength * <x>px
    // alternatively to keep a fixed scale one can set a fixed depth per level
    // d.y = (d.depth * 500); //500px per level.
  });

  // ****************** Nodes section ***************************

  // Update the nodes...
  var node = svg.selectAll("g.node").data(nodes, function(d) {
    return d.id || (d.id = ++i);
  });

  // Enter any new modes at the parent's previous position.
  var nodeEnter = node
    .enter()
    .append("g")
    .attr("class", "node")
    .attr("transform", function(d) {
      return "translate(" + source.y0 + "," + source.x0 + ")";
    })
    .on("click", toggleChildren);

  // Add Circle for the nodes
  nodeEnter
    .append("circle")
    .attr("class", "node")
    .attr("r", 1e-6)
    .style("fill", function(d) {
      return d._children ? "lightsteelblue" : "#fff";
    });

  // Add labels for the nodes
  nodeEnter
    .append("text")
    .attr("dy", ".35em")
    .attr("x", function(d) {
      return d.children || d._children ? -10 : 10;
    })
    .attr("text-anchor", function(d) {
      return d.children || d._children ? "end" : "start";
    })
    .text(function(d) {
      return d.data.name;
    });

  // UPDATE
  var nodeUpdate = nodeEnter.merge(node);

  // Transition to the proper position for the node
  nodeUpdate
    .transition()
    .duration(duration)
    .attr("transform", function(d) {
      return "translate(" + d.y + "," + d.x + ")";
    });

  // Update the node attributes and style
  nodeUpdate
    .select("circle.node")
    .attr("r", 7)
    .style("fill", function(d) {
      return d._children ? "lightsteelblue" : "#fff";
    })
    .attr("cursor", "pointer");

  // Remove any exiting nodes
  var nodeExit = node
    .exit()
    .transition()
    .duration(duration)
    .attr("transform", function(d) {
      return "translate(" + source.y + "," + source.x + ")";
    })
    .remove();

  // On exit reduce the node circles size to 0
  nodeExit.select("circle").attr("r", 1e-6);

  // On exit reduce the opacity of text labels
  nodeExit.select("text").style("fill-opacity", 1e-6);

  // ****************** links section ***************************

  // Update the links...
  var link = svg.selectAll("path.link").data(links, function(d) {
    return d.id;
  });

  // Enter any new links at the parent's previous position.
  var linkEnter = link
    .enter()
    .insert("path", "g")
    .attr("class", "link")
    .attr("d", function(d) {
      var o = { x: source.x0, y: source.y0 };
      return diagonal(o, o);
    });

  // UPDATE
  var linkUpdate = linkEnter.merge(link);

  // Transition back to the parent element position
  linkUpdate
    .transition()
    .duration(duration)
    .attr("d", function(d) {
      return diagonal(d, d.parent);
    });

  // Remove any exiting links
  var linkExit = link
    .exit()
    .transition()
    .duration(duration)
    .attr("d", function(d) {
      var o = { x: source.x, y: source.y };
      return diagonal(o, o);
    })
    .remove();

  // Store the old positions for transition.
  nodes.forEach(function(d) {
    d.x0 = d.x;
    d.y0 = d.y;
  });
}

// Collapse the node and all it's children
function collapse(d) {
  if (d.children) {
    d._children = d.children;
    d._children.forEach(collapse);
    d.children = null;
  }
}

// Toggle children on click.
function toggleChildren(d) {
  if (d.children) {
    // close the  node
    d._children = d.children;
    d.children = null;
  } else {
    // open the node
    d.children = d._children;
    d._children = null;
  }
  update(d);
  centerNode(d);
}

// Creates a curved (diagonal) path from parent to the child nodes
function diagonal(s, d) {
  var path = `M ${s.y} ${s.x}
            C ${(s.y + d.y) / 2} ${s.x},
              ${(s.y + d.y) / 2} ${d.x},
              ${d.y} ${d.x}`;

  return path;
}

function updateNodeCount(level, n, childPerLevel) {
  if (n.children && n.children.length > 0) {
    if (childPerLevel.length <= level + 1) {
      childPerLevel.push(0);
    }

    childPerLevel[level + 1] += n.children.length;
    n.children.forEach(function(d) {
      updateNodeCount(level + 1, d, childPerLevel);
    });
  }
}

function responsivefy(svg) {
  // https://benclinkinbeard.com/
  // d3tips/make-any-chart-responsive-with-one-function/

  // container will be the DOM element
  // that the svg is appended to
  // we then measure the container
  // and find its aspect ratio
  const container = d3.select(svg.node().parentNode),
    width = parseInt(svg.style("width"), 10),
    height = parseInt(svg.style("height"), 10),
    aspect = width / height;

  // set viewBox attribute to the initial size
  // control scaling with preserveAspectRatio
  // resize svg on inital page load
  svg
    .attr("viewBox", `0 0 ${width} ${height}`)
    .attr("preserveAspectRatio", "xMinYMid")
    .call(resize);

  // add a listener so the chart will be resized
  // when the window resizes
  // multiple listeners for the same event type
  // requires a namespace, i.e., 'click.foo'
  // api docs: https://goo.gl/F3ZCFr
  d3.select(window).on("resize." + container.attr("id"), resize);

  // this is the code that resizes the chart
  // it will be called on load
  // and in response to window resizes
  // gets the width of the container
  // and resizes the svg to fill it
  // while maintaining a consistent aspect ratio
  function resize() {
    const w = parseInt(container.style("width"));
    svg.attr("width", w);
    svg.attr("height", Math.round(w / aspect));
  }
}
function centerNode(source) {
  function zoom() {
    if (d3.event.transform != null) {
      svg.attr("transform", d3.event.transform);
    }
  }
  var zoomListener = d3
    .zoom()
    .scaleExtent([0.1, 3])
    .on("zoom", zoom);

  let t = d3.zoomTransform(svg.node());
  let x = -source.y0;
  let y = -source.x0;
  x = x * t.k + viewerWidth / 2;
  y = y * t.k + viewerHeight / 2;
  d3.select("svg")
    .transition()
    .duration(duration)
    .call(zoomListener.transform, d3.zoomIdentity.translate(x, y).scale(t.k));
}

function expand(d) {
  if (d._children) {
    d.children = d._children;
    d.children.forEach(expand);
    d._children = null;
  }
}

function zoom() {
  svg.attr("transform", d3.event.transform);
}
