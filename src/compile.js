import StaticChannel from "./channel/static_channel"

var Compile = {
  parameter(ast, context) {
    if(ast.bound) {
      if(ast.value === "this") {
        return new StaticChannel(context);
      } else {
        let value = context[ast.value];
        if(value && value.isChannel) {
          return value;
        } else {
          return new StaticChannel(value);
        }
      }
    } else {
      return new StaticChannel(ast.value);
    }
  }
}

export default Compile;
