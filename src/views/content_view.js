import DynamicView from "./dynamic_view"
import TextView from "./text_view"
import Compile from "../compile"

class ContentView extends DynamicView {
  constructor(ast, context) {
    let value;
    super(ast, context);

    if(ast.bound && ast.value) {
      value = context[ast.value];
      let property = context[ast.value + "_property"];
      if(property && property.registerGlobal) {
        property.registerGlobal(value);
      }
      this._bindEvent(property, (_, value) => this.update(value))
    } else if(ast.value) {
      value = ast.value;
    } else {
      value = context;
    }
    this.update(value);
  }

  update(value) {
    if(value && value.isView) {
      this.replace([value]);
    } else {
      this.replace([new TextView(value)]);
    }
  }
}

Compile.content = function(ast, context) {
  return new ContentView(ast, context);
};

export default ContentView;
