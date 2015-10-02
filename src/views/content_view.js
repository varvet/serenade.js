import DynamicView from "./dynamic_view"
import TextView from "./text_view"
import Compile from "../compile"
import { format } from "../helpers"

class ContentView extends DynamicView {
  constructor(channel) {
    super();
    this.bind(channel, (value) => {
      if(value && value.isView) {
        this.replace([value]);
      } else {
        this.replace([new TextView(value)]);
      }
    });
  }
}

Compile.content = function(ast, context) {
  return new ContentView(ast, context);
};

export default ContentView;
