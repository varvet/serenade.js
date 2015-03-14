import View from "./view"
import Compile from "../compile"
import { assignUnlessEqual } from "../helpers"

class TextView extends View {
  constructor(ast, context) {
    let value;
    this.ast = ast;
    this.context = context;

    if(ast.bound && ast.value) {
      value = this.context[ast.value];
      let property = this.context[ast.value + "_property"];
      if(property && property.registerGlobal) {
        property.registerGlobal(value);
      }
      this._bindEvent(property, (_, value) => this.update(value))
    } else if(ast.value) {
      value = ast.value;
    } else {
      value = context;
    }
    super(Serenade.document.createTextNode(""));
    this.update(value);
  }

  update(value) {
    if (value === 0) {
      value = "0";
    }
    assignUnlessEqual(this.node, "nodeValue", value || "");
  }
}

Compile.text = function(ast, context) {
  return new TextView(ast, context);
};

export default TextView;
