(function() {
  var Monkey;

  Monkey = require('./monkey').Monkey;

  Monkey.Collection = (function() {

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

    return Collection;

  })();

}).call(this);
