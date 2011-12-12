(function() {
  var Monkey;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  Monkey = require('./monkey').Monkey;
  Monkey.Collection = (function() {
    Collection.prototype.collection = true;
    Monkey.extend(Collection.prototype, Monkey.Events);
    function Collection(list) {
      this.list = list;
      this.length = this.list.length;
      this.bind("change", __bind(function() {
        return this.length = this.list.length;
      }, this));
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
      return Monkey.each(this.list, fun);
    };
    Collection.prototype.indexOf = function(item) {
      return this.list.indexOf(item);
    };
    Collection.prototype["delete"] = function(index) {
      this.list.splice(index, 1);
      this.trigger("delete", index);
      return this.trigger("change", this.list);
    };
    return Collection;
  })();
}).call(this);
