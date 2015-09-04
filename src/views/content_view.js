import DynamicView from "./dynamic_view"
import TextView from "./text_view"
import Compile from "../compile"

class ContentView extends DynamicView {
  constructor(ast, context) {
    let value;
    super(ast, context);

    let channel = Compile.parameter(ast, context);

    this._bind(channel, (value) => {
      this.update(value);
    });
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
