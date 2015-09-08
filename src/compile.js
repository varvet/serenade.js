import Channel from "./channel"

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
