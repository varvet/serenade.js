import DynamicView from "./dynamic_view"
import TemplateView from "./template_view"
import TextView from "./text_view"
import Collection from "../collection"
import Transform from "../transform"

class CollectionView extends DynamicView {
  constructor(channel, template) {
    super();

    this.template = template

    this.bind(channel, (values) => {
      if(values && values.length) {
        if(this.lastItems && this.lastItems.length) {
          this.replace(values);
        } else {
          this.children = new Collection(values.map(this._toView.bind(this)))
          this.rebuild()
        }
        this.lastItems = values.map((i) => i);
      } else if(this.lastItems && this.lastItems.length) {
        this.clear()
        this.lastItems = undefined;
      }
    });
  }

  replace(items) {
    Transform(this.lastItems, items).forEach((operation) => {
      if(operation.type == "insert") {
        this._insertChild(operation.index, this._toView(operation.value));
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
  }

  _toView(item) {
    if(this.template) {
      return this.template.render(item);
    } else if(item && item.isView) {
      return item;
    } else {
      return new TextView(item);
    }
  }

  _deleteChild(index) {
    this.children[index].remove();
    this.children.deleteAt(index);
  }

  _insertChild(index, view) {
    if(this.node.parentNode) {
      let previousChild = this.children[index - 1]
      let previousElement = (previousChild && previousChild.lastElement) || this.node;
      view.insertAfter(previousElement);
    }
    this.children.insertAt(index, view);
  }

  _swapChildren(fromIndex, toIndex) {
    var last, _ref, _ref1, _ref2;
    if (this.node.parentNode) {
      last = ((_ref = this.children[fromIndex - 1]) != null ? _ref.lastElement : void 0) || this.node;
      this.children[toIndex].insertAfter(last);
      last = ((_ref1 = this.children[toIndex - 1]) != null ? _ref1.lastElement : void 0) || this.node;
      this.children[fromIndex].insertAfter(last);
    }
    return _ref2 = [this.children[toIndex], this.children[fromIndex]], this.children[fromIndex] = _ref2[0], this.children[toIndex] = _ref2[1], _ref2;
  }
}

export default CollectionView;
