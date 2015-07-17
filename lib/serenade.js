"use strict";

Object.defineProperty(exports, "__esModule", {
	value: true
});

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

var _model = require("./model");

var _model2 = _interopRequireDefault(_model);

var _cache = require("./cache");

var _cache2 = _interopRequireDefault(_cache);

var _template2 = require("./template");

var _template3 = _interopRequireDefault(_template2);

var _collection = require("./collection");

var _collection2 = _interopRequireDefault(_collection);

var _property = require("./property");

var _property2 = _interopRequireDefault(_property);

var _event = require("./event");

var _event2 = _interopRequireDefault(_event);

var _helpers = require("./helpers");

var _viewsBound_view_view = require("./views/bound_view_view");

var _viewsBound_view_view2 = _interopRequireDefault(_viewsBound_view_view);

var _viewsCollection_view = require("./views/collection_view");

var _viewsCollection_view2 = _interopRequireDefault(_viewsCollection_view);

var _viewsElement = require("./views/element");

var _viewsElement2 = _interopRequireDefault(_viewsElement);

var _viewsHelper_view = require("./views/helper_view");

var _viewsHelper_view2 = _interopRequireDefault(_viewsHelper_view);

var _viewsIf_view = require("./views/if_view");

var _viewsIf_view2 = _interopRequireDefault(_viewsIf_view);

var _viewsIn_view = require("./views/in_view");

var _viewsIn_view2 = _interopRequireDefault(_viewsIn_view);

var _viewsTemplate_view = require("./views/template_view");

var _viewsTemplate_view2 = _interopRequireDefault(_viewsTemplate_view);

var _viewsText_view = require("./views/text_view");

var _viewsText_view2 = _interopRequireDefault(_viewsText_view);

var _viewsContent_view = require("./views/content_view");

var _viewsContent_view2 = _interopRequireDefault(_viewsContent_view);

var _viewsUnless_view = require("./views/unless_view");

var _viewsUnless_view2 = _interopRequireDefault(_viewsUnless_view);

var _viewsView = require("./views/view");

var _viewsView2 = _interopRequireDefault(_viewsView);

function Serenade(wrapped) {
	var object = Object.create(wrapped);
	for (var key in wrapped) {
		(0, _property2["default"])(object, key, { value: wrapped[key] });
	}
	return object;
};

if (typeof window !== "undefined") {
	_helpers.settings.document = window.document;
}

(0, _helpers.extend)(Serenade, Object.defineProperties({
	VERSION: "0.5.0",
	defineProperty: _property2["default"],
	defineEvent: _event2["default"],

	view: function view(name, fn) {
		return this.views[name] = function (ast, context) {
			return new fn(ast, context);
		};
	},

	helper: function helper(name, fn) {
		return this.views[name] = function (ast, context) {
			return new _viewsHelper_view2["default"](ast, context, fn);
		};
	},

	template: function template(nameOrTemplate, _template) {
		if (_template) {
			return this.templates[nameOrTemplate] = new _template3["default"](nameOrTemplate, _template);
		} else {
			return new _template3["default"](void 0, nameOrTemplate);
		}
	},

	render: function render(name, context) {
		return this.templates[name].render(context);
	},

	clearIdentityMap: function clearIdentityMap() {
		_cache2["default"]._identityMap = {};
	},

	clearCache: function clearCache() {
		Serenade.clearIdentityMap();
	},

	unregisterAll: function unregisterAll() {
		Serenade.views = {};
		Serenade.templates = {};
	},

	Model: _model2["default"],
	Collection: _collection2["default"],
	Cache: _cache2["default"],
	Template: _template3["default"],
	View: _viewsView2["default"],
	Element: _viewsElement2["default"],
	CollectionView: _viewsCollection_view2["default"]

}, {
	async: {
		get: function get() {
			return _helpers.settings.async;
		},
		set: function set(value) {
			_helpers.settings.async = value;
		},
		configurable: true,
		enumerable: true
	},
	document: {
		get: function get() {
			return _helpers.settings.document;
		},
		set: function set(value) {
			_helpers.settings.document = value;
		},
		configurable: true,
		enumerable: true
	},
	views: {
		get: function get() {
			return _helpers.settings.views;
		},
		set: function set(value) {
			_helpers.settings.views = value;
		},
		configurable: true,
		enumerable: true
	},
	templates: {
		get: function get() {
			return _helpers.settings.templates;
		},
		set: function set(value) {
			_helpers.settings.templates = value;
		},
		configurable: true,
		enumerable: true
	}
}));

exports["default"] = Serenade;
module.exports = exports["default"];
