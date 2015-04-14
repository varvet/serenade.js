import DynamicView from "./dynamic_view"
import TemplateView from "./template_view"
import Compile from "../compile"
import Collection from "../collection"
import Transform from "../transform"

class CollectionView extends DynamicView {
  constructor(ast, context) {
    super(ast, context);

    this.update = this.update.bind(this);

    let items = this.context[ast.argument] || [];
    this.lastItems = items.map((i) => i)
    this.children = new Collection(items.map((item) => new TemplateView(ast.children || [], item, context)))
    this.cb = (_, after) => this.replace(after);
    this._bindEvent(this.context["" + ast.argument + "_property"], this.update);
    this._bindEvent(items.change, this.cb);
  }

  update(before, after) {
    this._unbindEvent(before && before.change, this.cb);
    this._bindEvent(after && after.change, this.cb);
    this.replace(after);
  }

  replace(items) {
    Transform(this.lastItems, items).forEach((operation) => {
      if(operation.type == "insert") {
        this._insertChild(operation.index, new TemplateView(this.ast.children || [], operation.value));
      } else if(operation.type == "remove") {
        this._deleteChild(operation.index);
      } else if(operation.type == "swap") {
        this._swapChildren(operation.index, operation["with"]);
      }
    });
    if(items) {
      this.lastItems = items.map((i) => i);
    } else {
      this.lastItems = [];
    }
  };

  _deleteChild(index) {
    this.children[index].remove();
    this.children.deleteAt(index);
  };

  _insertChild(index, view) {
    if(this.anchor.parentNode) {
      let previousChild = this.children[index - 1]
      let previousElement = (previousChild && previousChild.lastElement) || this.anchor;
      view.insertAfter(previousElement);
    }
    this.children.insertAt(index, view);
  };

  _swapChildren(fromIndex, toIndex) {
    var last, _ref, _ref1, _ref2;
    if (this.anchor.parentNode) {
      last = ((_ref = this.children[fromIndex - 1]) != null ? _ref.lastElement : void 0) || this.anchor;
      this.children[toIndex].insertAfter(last);
      last = ((_ref1 = this.children[toIndex - 1]) != null ? _ref1.lastElement : void 0) || this.anchor;
      this.children[fromIndex].insertAfter(last);
    }
    return _ref2 = [this.children[toIndex], this.children[fromIndex]], this.children[fromIndex] = _ref2[0], this.children[toIndex] = _ref2[1], _ref2;
  };

}

Compile.collection = function(ast, context) {
  return new CollectionView(ast, context);
};

export default CollectionView;
