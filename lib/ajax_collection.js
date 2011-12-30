(function() {
  var Collection,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Collection = require('./collection').Collection;

  exports.AjaxCollection = (function(_super) {

    __extends(AjaxCollection, _super);

    function AjaxCollection(constructor, url) {
      this.constructor = constructor;
      this.url = url;
      AjaxCollection.__super__.constructor.call(this, []);
    }

    return AjaxCollection;

  })(Collection);

}).call(this);
