export default function convertFlatJsonToFlareJson(flatJson, nestedKey) {
  // Generate (multilevel) flare.json data format from flat json
  // https://stackoverflow.com/a/17849353

  const dataMap = flatJson.reduce(function (map, node) {
    map[node[nestedKey]] = node;
    return map;
  }, {});

  const treeData = [];
  flatJson.forEach(function (node) {
    // add to parent
    const parent = dataMap[node.parent_id];
    if (parent) {
      // create child array if it doesn't exist
      (parent.children || (parent.children = []))
        // add node to child array
        .push(node);

      // sort the children
      parent.children.sort((a, b) => a.name.localeCompare(b.name));
    } else {
      // parent is null or missing
      treeData.push(node);
    }
  });

  return treeData[0];
}
