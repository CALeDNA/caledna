var data = window.caledna.asv_tree;
import * as spec from "../vega_specs/tree_map.json";

var stratifySettings = spec.data[0].transform.filter(
  item => item.type == "stratify"
)[0];
var textSettings = spec.marks.filter(mark => mark.type == "text")[0];

spec.height = window.caledna.asv_count * 18;
spec.width = 2000;
spec.data[0].values = data;
stratifySettings.key = "id";
stratifySettings.parentKey = "parent";
textSettings.encode.enter.text.field = "name";
textSettings.encode.enter.fontSize.value = 14;

var view = new vega.View(vega.parse(spec), {
  renderer: "svg",
  container: "#asv-tree"
});
view.runAsync();
