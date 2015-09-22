"use strict";

var _interopRequireDefault = function (obj) { return obj && obj.__esModule ? obj : { "default": obj }; };

Object.defineProperty(exports, "__esModule", {
	value: true
});

var _Model = require("./model");

var _Model2 = _interopRequireDefault(_Model);

var _Cache = require("./cache");

var _Cache2 = _interopRequireDefault(_Cache);

var _Template = require("./template");

var _Template2 = _interopRequireDefault(_Template);

var _Collection = require("./collection");

var _Collection2 = _interopRequireDefault(_Collection);

var _defineProperty$defineAttribute$defineChannel = require("./property");

var _extend$settings$format = require("./helpers");

var _Channel = require("./channel");

var _Channel2 = _interopRequireDefault(_Channel);

var _BoundViewView = require("./views/bound_view_view");

var _BoundViewView2 = _interopRequireDefault(_BoundViewView);

var _CollectionView = require("./views/collection_view");

var _CollectionView2 = _interopRequireDefault(_CollectionView);

var _Element = require("./views/element");

var _Element2 = _interopRequireDefault(_Element);

var _HelperView = require("./views/helper_view");

var _HelperView2 = _interopRequireDefault(_HelperView);

var _IfView = require("./views/if_view");

var _IfView2 = _interopRequireDefault(_IfView);

var _InView = require("./views/in_view");

var _InView2 = _interopRequireDefault(_InView);

var _TemplateView = require("./views/template_view");

var _TemplateView2 = _interopRequireDefault(_TemplateView);

var _TextView = require("./views/text_view");

var _TextView2 = _interopRequireDefault(_TextView);

var _ContentView = require("./views/content_view");

var _ContentView2 = _interopRequireDefault(_ContentView);

var _UnlessView = require("./views/unless_view");

var _UnlessView2 = _interopRequireDefault(_UnlessView);

var _View = require("./views/view");

var _View2 = _interopRequireDefault(_View);

function Serenade(wrapped) {
	var object = Object.create(wrapped);
	for (var key in wrapped) {
		_defineProperty$defineAttribute$defineChannel.defineAttribute(object, key, { value: wrapped[key] });
	}
	return object;
};

if (typeof window !== "undefined") {
	_extend$settings$format.settings.document = window.document;
}

_extend$settings$format.extend(Serenade, Object.defineProperties({
	VERSION: "0.5.0",
	defineProperty: _defineProperty$defineAttribute$defineChannel.defineProperty,
	defineAttribute: _defineProperty$defineAttribute$defineChannel.defineAttribute,
	defineChannel: _defineProperty$defineAttribute$defineChannel.defineChannel,

	view: function view(name, fn) {
		return this.views[name] = function (ast, context) {
			return new fn(ast, context);
		};
	},

	helper: function helper(name, fn) {
		return this.views[name] = function (ast, context) {
			return new _HelperView2["default"](ast, context, fn);
		};
	},

	template: (function (_template) {
		function template(_x, _x2) {
			return _template.apply(this, arguments);
		}

		template.toString = function () {
			return _template.toString();
		};

		return template;
	})(function (nameOrTemplate, template) {
		if (template) {
			return this.templates[nameOrTemplate] = new _Template2["default"](nameOrTemplate, template);
		} else {
			return new _Template2["default"](void 0, nameOrTemplate);
		}
	}),

	render: function render(name, context) {
		return this.templates[name].render(context);
	},

	clearIdentityMap: function clearIdentityMap() {
		_Cache2["default"]._identityMap = {};
	},

	clearCache: function clearCache() {
		Serenade.clearIdentityMap();
	},

	unregisterAll: function unregisterAll() {
		Serenade.views = {};
		Serenade.templates = {};
	},

	format: _extend$settings$format.format,
	Model: _Model2["default"],
	Collection: _Collection2["default"],
	Cache: _Cache2["default"],
	Template: _Template2["default"],
	View: _View2["default"],
	Element: _Element2["default"],
	CollectionView: _CollectionView2["default"],
	Channel: _Channel2["default"] }, {
	async: {
		get: function () {
			return _extend$settings$format.settings.async;
		},
		set: function (value) {
			_extend$settings$format.settings.async = value;
		},
		configurable: true,
		enumerable: true
	},
	document: {
		get: function () {
			return _extend$settings$format.settings.document;
		},
		set: function (value) {
			_extend$settings$format.settings.document = value;
		},
		configurable: true,
		enumerable: true
	},
	views: {
		get: function () {
			return _extend$settings$format.settings.views;
		},
		set: function (value) {
			_extend$settings$format.settings.views = value;
		},
		configurable: true,
		enumerable: true
	},
	templates: {
		get: function () {
			return _extend$settings$format.settings.templates;
		},
		set: function (value) {
			_extend$settings$format.settings.templates = value;
		},
		configurable: true,
		enumerable: true
	}
}));

exports["default"] = Serenade;
module.exports = exports["default"];
