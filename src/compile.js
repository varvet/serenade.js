import Channel from "./channel"
import DynamicView from "./views/dynamic_view"
import View from "./views/view"
import TextView from "./views/text_view"

export function toView(object) {
  if(object && object.isView) {
    return object;
  } else if(object && object.isChannel) {
    let view = new DynamicView();
    view.bind(object, (value) => {
      view.replace([].concat(value || []).map(toView));
    });
    return view;
  } else if(object && object.nodeType === 1) {
    return new View(object);
  } else if(object && object.nodeType === 3) {
    return new TextView(object.nodeValue);
  } else {
    return new TextView(object);
  }
}

var Compile = {
  parameter(ast, context) {
    if(ast.bound) {
      if(ast.value === "this") {
        return Channel.static(context);
      } else {
        let value = context && context[ast.value];
        if(value && value.isChannel) {
          return value;
        } else {
          return Channel.static(value);
        }
      }
    } else {
      return Channel.static(ast.value);
    }
  }
}

export default Compile;
