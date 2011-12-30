(function() {
  var Monkey, extend, forEach, _ref;

  Monkey = require('./monkey').Monkey;

  _ref = require('./helpers'), extend = _ref.extend, forEach = _ref.forEach;

  Monkey.Collection = (function() {

    extend(Collection.prototype, Monkey.Events);

    function Collection(list) {
      var _this = this;
      this.list = list;
      this.length = this.list.length;
      this.bind("change", function() {
        return _this.length = _this.list.length;
      });
    }

    Collection.prototype.get = function(index) {
      return this.list[index];
    };

    Collection.prototype.set = function(index, value) {
      this.list[index] = value;
      this.trigger("change:" + index, value);
      this.trigger("set", index, value);
      return this.trigger("change", this.list);
    };

    Collection.prototype.push = function(element) {
      this.list.push(element);
      this.trigger("add", element);
      return this.trigger("change", this.list);
    };

    Collection.prototype.update = function(list) {
      this.list = list;
      this.trigger("update", list);
      return this.trigger("change", this.list);
    };

    Collection.prototype.forEach = function(fun) {
      return forEach(this.list, fun);
    };

    Collection.prototype.indexOf = function(item) {
      return this.list.indexOf(item);
    };

    Collection.prototype.deleteAt = function(index) {
      this.list.splice(index, 1);
      this.trigger("delete", index);
      return this.trigger("change", this.list);
    };

    Collection.prototype["delete"] = function(item) {
      return this.deleteAt(this.indexOf(item));
    };

    return Collection;

  })();

}).call(this);
