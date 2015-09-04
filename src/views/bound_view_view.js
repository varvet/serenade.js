import DynamicView from "./dynamic_view"
import Compile from "../compile"
import { settings } from "../helpers"

class BoundViewView extends DynamicView {
  constructor(ast, context) {
    super(ast, context);

    this._bind(Compile.parameter(ast.arguments[0], context), (value) => {
      let view = settings.templates[value].render(context).view;
      this.replace([view]);
    });
  }
}

Compile.view = function(ast, context) {
  if(ast.arguments.length !== 1) {
    throw(new Error("`if` must take exactly one argument"))
  }

  if (ast.arguments[0].bound) {
    return new BoundViewView(ast, context);
  } else {
    return settings.templates[ast.arguments[0].value].render(context).view;
  }
};

export default BoundViewView;
