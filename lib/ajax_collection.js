(function() {
  var Collection,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Collection = require('./collection').Collection;

  exports.AjaxCollection = (function(_super) {

    __extends(AjaxCollection, _super);

    function AjaxCollection(constructor, url, list) {
      var _ref;
      this.constructor = constructor;
      this.url = url;
      this.list = list != null ? list : [];
      this.expires = new Date(new Date().getTime() + ((_ref = this.constructor._storeOptions) != null ? _ref.expires : void 0));
      AjaxCollection.__super__.constructor.call(this, this.list);
    }

    AjaxCollection.prototype.refresh = function() {};

    AjaxCollection.prototype.isStale = function() {
      return this.expires < new Date();
    };

    return AjaxCollection;

  })(Collection);

}).call(this);
