import DynamicView from "./dynamic_view"
import Compile from "../compile"
import { settings } from "../helpers"

class BoundViewView extends DynamicView {
  attach() {
    if(!this.attached) {
      this._bindToModel(this.ast.argument, (value) => {
        let view = settings.templates[value].render(this.context).view;
        this.replace([view]);
      });
    }
    super.attach();
  }
}

Compile.view = function(ast, context) {
  if (ast.bound) {
    return new BoundViewView(ast, context);
  } else {
    return settings.templates[ast.argument].render(context).view;
  }
};

export default BoundViewView;
