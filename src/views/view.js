import { def } from "../helpers"

var View = (function() {
  function View(node) {
    this.node = node;
    this.children = [];
  }

  View.prototype.append = function(inside) {
    return inside.appendChild(this.node);
  };

  View.prototype.insertAfter = function(after) {
    return after.parentNode.insertBefore(this.node, after.nextSibling);
  };

  View.prototype.remove = function() {
    var _ref;
    if ((_ref = this.node.parentNode) != null) {
      _ref.removeChild(this.node);
    }
    return this.detach();
  };

  View.prototype.detach = function() {
    var child, event, fun, _i, _j, _len, _len1, _ref, _ref1, _ref2, _results;
    _ref = this.children;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      child = _ref[_i];
      child.detach();
    }
    if (this.boundEvents) {
      _ref1 = this.boundEvents;
      _results = [];
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        _ref2 = _ref1[_j], event = _ref2.event, fun = _ref2.fun;
        _results.push(event.unbind(fun));
      }
      return _results;
    }
  };

  def(View.prototype, "lastElement", {
    configurable: true,
    get: function() {
      return this.node;
    }
  });

  View.prototype._bindEvent = function(event, fun) {
    if (event) {
      this.boundEvents || (this.boundEvents = new Collection());
      this.boundEvents.push({
        event: event,
        fun: fun
      });
      return event.bind(fun);
    }
  };

  View.prototype._unbindEvent = function(event, fun) {
    if (event) {
      this.boundEvents || (this.boundEvents = new Collection());
      this.boundEvents["delete"](fun);
      return event.unbind(fun);
    }
  };

  View.prototype._bindToModel = function(name, fun) {
    var property, value;
    value = this.context[name];
    property = this.context["" + name + "_property"];
    if (property != null) {
      if (typeof property.registerGlobal === "function") {
        property.registerGlobal(value);
      }
    }
    this._bindEvent(property, function(_, value) {
      return fun(value);
    });
    return fun(value);
  };

  return View;

})();

export default View;
