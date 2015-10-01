import DynamicView from "./dynamic_view"
import TemplateView from "./template_view"
import Compile from "../compile"

class UnlessView extends DynamicView {
  attach() {
    if(!this.attached) {
      this._bindToModel(this.ast.argument, (value) => {
        if (value) {
          return this.clear();
        } else {
          return this.replace([new TemplateView(this.ast.children, this.context)]);
        }
      });
    }
    super.attach();
  }
}

Compile.unless = function(ast, context) {
  return new UnlessView(ast, context);
};

export default UnlessView;
