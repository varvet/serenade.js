(function() {
  var Monkey;

  Monkey = require('./monkey').Monkey;

  Monkey.Collection = (function() {

    Collection.prototype.collection = true;

    Monkey.extend(Collection.prototype, Monkey.Events);

    function Collection(list) {
      this.list = list;
    }

    Collection.prototype.get = function(index) {
      return this.list[index];
    };

    Collection.prototype.set = function(index, value) {
      this.trigger("change:" + index);
      this.trigger("change");
      return this.list[index] = value;
    };

    Collection.prototype.push = function(element) {
      return this.list.push(element);
    };

    Collection.prototype.update = function(list) {
      return this.list = list;
    };

    Collection.prototype.forEach = function(fun) {
      return Monkey.each(this.list, fun);
    };

    return Collection;

  })();

}).call(this);
