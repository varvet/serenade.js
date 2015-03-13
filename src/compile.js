import BoundViewView from "./views/bound_view_view"
import TextView from "./views/bound_view_view"
import CollectionView from "./views/collection_view"
import InView from "./views/in_view"
import IfView from "./views/if_view"
import UnlessView from "./views/unless_view"

var Compile;

Compile = {
  element: function(ast, context) {
    return Serenade.renderView(ast, context);
  },
  view: function(ast, context) {
    if (ast.bound) {
      return new BoundViewView(ast, context);
    } else {
      return Serenade.templates[ast.argument].render(context).view;
    }
  },
  text: function(ast, context) {
    return new TextView(ast, context);
  },
  collection: function(ast, context) {
    return new CollectionView(ast, context);
  },
  "in": function(ast, context) {
    return new InView(ast, context);
  },
  "if": function(ast, context) {
    return new IfView(ast, context);
  },
  unless: function(ast, context) {
    return new UnlessView(ast, context);
  }
};

export default Compile;
