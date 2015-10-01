import DynamicView from "./dynamic_view"
import TemplateView from "./template_view"
import Compile from "../compile"

class IfView extends DynamicView {
  attach() {
    if(!this.attached) {
      this._bindToModel(this.ast.argument, (value) => {
        if(value) {
          this.replace([new TemplateView(this.ast.children, this.context)]);
        } else if(this.ast.else) {
          this.replace([new TemplateView(this.ast.else.children, this.context)]);
        } else {
          this.clear();
        }
      });
    }
    super.attach();
  }
}

Compile.if = function(ast, context) {
  return new IfView(ast, context);
};

export default IfView;
