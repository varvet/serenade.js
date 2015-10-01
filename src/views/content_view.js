import DynamicView from "./dynamic_view"
import TextView from "./text_view"
import Compile from "../compile"
import { format } from "../helpers"

class ContentView extends DynamicView {
  attach() {
    if(!this.attached) {
      let value;
      if(this.ast.bound && this.ast.value) {
        value = format(this.context, this.ast.value);
        let property = this.context[this.ast.value + "_property"];
        if(property && property.registerGlobal) {
          property.registerGlobal(value);
        }
        this._bindEvent(property, (_, value) => this.update(format(this.context, this.ast.value, value)))
      } else if(this.ast.value) {
        value = this.ast.value;
      } else {
        value = this.context;
      }
      this.update(value);
    }
    super.attach();
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
