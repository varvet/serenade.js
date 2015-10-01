import DynamicView from "./dynamic_view"
import TemplateView from "./template_view"
import Compile from "../compile"

class InView extends DynamicView {
  attach() {
    if(!this.attached) {
      this._bindToModel(this.ast.argument, (value) => {
        if (value) {
          this.replace([new TemplateView(this.ast.children, value)]);
        } else {
          this.clear();
        }
      });
    }
    super.attach();
  }
}

Compile.in = function(ast, context) {
  return new InView(ast, context);
};

export default InView;
