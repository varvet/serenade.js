import DynamicView from "./dynamic_view"
import Compile from "../compile"

class BoundViewView extends DynamicView {
  constructor(ast, context) {
    super(ast, context);
    this._bindToModel(ast.argument, (value) => {
        let view = Serenade.templates[value].render(context).view;
        this.replace([view]);
    });
  }
}

Compile.view = function(ast, context) {
  if (ast.bound) {
    return new BoundViewView(ast, context);
  } else {
    return Serenade.templates[ast.argument].render(context).view;
  }
};

export default BoundViewView;
