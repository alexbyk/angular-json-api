(function() {
  'use strict';
  var JsonApi, JsonApiBase, JsonApiBuilder, JsonApiItemsFactory, MSG_NOT_ARRAY, cloneHttp, objUtil, _RESERVED, _RESERVED_ROOT,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    __slice = [].slice;

  objUtil = null;

  MSG_NOT_ARRAY = 'items must be an array and have $isArray attribute eq true';

  angular.module('json-api', ['object-util']).provider('jsonApi', function() {
    var base, idKey;
    idKey = null;
    base = null;
    this.idKey = function(val) {
      if (val == null) {
        return idKey;
      }
      idKey = val;
      return this;
    };
    this.base = function(val) {
      if (val == null) {
        return base;
      }
      base = val;
      return this;
    };
    this.$get = ["jsonApiBuilder", function(jsonApiBuilder) {
      var client, opts;
      opts = {};
      if (idKey != null) {
        opts.idKey = idKey;
      }
      if (base != null) {
        opts.base = base;
      }
      return client = jsonApiBuilder.newClient(opts);
    }];
  }).factory('jsonApiBuilder', ["$http", "_ou", function($http, _ou) {
    var clientsBuilder;
    objUtil = _ou;
    return clientsBuilder = new JsonApiBuilder({
      idKey: 'id',
      http: $http,
      base: '/'
    });
  }]);

  _RESERVED_ROOT = ['meta', 'links', 'linked'];

  _RESERVED = {
    type: '$type',
    href: '$href',
    links: '$links'
  };

  JsonApiBase = (function() {
    function JsonApiBase(opts) {
      if (opts == null) {
        opts = {};
      }
      angular.extend(this, opts);
    }

    return JsonApiBase;

  })();

  JsonApiItemsFactory = (function(_super) {
    __extends(JsonApiItemsFactory, _super);

    function JsonApiItemsFactory() {
      return JsonApiItemsFactory.__super__.constructor.apply(this, arguments);
    }

    JsonApiItemsFactory.prototype.updatePristineAttributes = function(item) {
      return item.$pristineAttributes = this.getAttributes(item);
    };

    JsonApiItemsFactory.prototype.getAttributes = function(item) {
      return objUtil.filterKeysNot(item, /^\$/);
    };

    JsonApiItemsFactory.prototype.isUnchanged = function(item) {
      return angular.equals(this.getAttributes(item), item.$pristineAttributes);
    };

    JsonApiItemsFactory.prototype.toJson = function(item) {
      var data, json;
      json = {};
      data = objUtil.mapKeys(item, {
        $id: this.idKey
      });
      json[item.$type] = this.getAttributes(data);
      return angular.toJson(json);
    };

    JsonApiItemsFactory.prototype.reservedMap = function() {
      var map;
      map = angular.copy(_RESERVED);
      map[this.idKey] = '$id';
      return map;
    };

    JsonApiItemsFactory.prototype.fromJson = function(json) {
      var data, key, obj, root, type, _i, _len;
      obj = angular.fromJson(json);
      for (key in obj) {
        if (__indexOf.call(_RESERVED_ROOT, key) < 0) {
          type = key;
        }
      }
      data = objUtil.mapKeys(obj[type], this.reservedMap());
      root = {};
      for (_i = 0, _len = _RESERVED_ROOT.length; _i < _len; _i++) {
        key = _RESERVED_ROOT[_i];
        if (obj[key] != null) {
          root[key] = obj[key];
        }
      }
      if (root.linked) {
        root.linked = objUtil.mapKeys(root.linked, this.reservedMap());
      }
      return this.newItem({
        origin: obj,
        type: type,
        root: root
      }, data);
    };

    JsonApiItemsFactory.prototype.newItem = function(attrs, data) {
      var el, item, key, val, _i, _len;
      if (attrs == null) {
        attrs = {};
      }
      if (data == null) {
        data = {};
      }
      switch (false) {
        case !Array.isArray(data):
          item = [];
          angular.copy(data, item);
          item.$isArray = true;
          break;
        default:
          item = {};
          angular.copy(data, item);
          item.$isArray = false;
      }
      for (key in attrs) {
        val = attrs[key];
        item["$" + key] = val;
      }
      if (item.$isArray) {
        for (_i = 0, _len = item.length; _i < _len; _i++) {
          el = item[_i];
          el.$type = item.$type;
        }
      }
      this.updatePristineAttributes(item);
      return item;
    };

    JsonApiItemsFactory.prototype.getLinked = function(item, type, id) {
      var doc, val, _i, _len, _ref, _ref1, _ref2;
      switch (false) {
        case type == null:
          doc = (_ref = item.$root) != null ? (_ref1 = _ref.linked) != null ? _ref1[type] : void 0 : void 0;
          if (doc == null) {
            return;
          }
          switch (false) {
            case !id:
              for (_i = 0, _len = doc.length; _i < _len; _i++) {
                val = doc[_i];
                if (val.$id === id) {
                  return val;
                }
              }
              break;
            default:
              return doc;
          }
          break;
        default:
          return (_ref2 = item.$root) != null ? _ref2.linked : void 0;
      }
    };

    return JsonApiItemsFactory;

  })(JsonApiBase);

  JsonApi = (function(_super) {
    __extends(JsonApi, _super);

    function JsonApi() {
      return JsonApi.__super__.constructor.apply(this, arguments);
    }

    JsonApi.prototype.urlFor = function() {
      var id, opts, path, query, type, url;
      if (!arguments[0]) {
        return "" + this.base;
      }
      switch (false) {
        case !angular.isObject(arguments[0]):
          opts = arguments[0];
          break;
        default:
          opts = {
            type: arguments[0]
          };
      }
      switch (false) {
        case !angular.isObject(arguments[1]):
          opts.query = arguments[1];
          break;
        case arguments[1] == null:
          opts.id = arguments[1];
      }
      url = opts.url, id = opts.id, type = opts.type, query = opts.query;
      if (type == null) {
        type = opts.$type;
      }
      if (id == null) {
        id = opts.$id;
      }
      switch (false) {
        case url == null:
          return "" + this.base + url;
        case !((type != null) && (id != null)):
          return "" + this.base + type + "\/" + id;
        case type == null:
          path = "" + this.base + type;
          if (opts.query) {
            path = ("" + path + "?") + objUtil.objectToQuery(opts.query);
          }
          return path;
      }
    };

    JsonApi.prototype.updateIn = function() {
      var args, item, updArgs, _i;
      args = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), item = arguments[_i++];
      updArgs = args.length ? args.push(item) && args : [item];
      return this.update.apply(this, updArgs).then(function(resItem) {
        return objUtil.replace(item, resItem);
      });
    };

    JsonApi.prototype.createIn = function(opts, item) {
      return (this.create(opts, item)).then(function(resItem) {
        return objUtil.replace(item, resItem);
      });
    };

    JsonApi.prototype.getIn = function() {
      var args, item, _i;
      args = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), item = arguments[_i++];
      return (this.get.apply(this, args)).then(function(resItem) {
        return objUtil.replace(item, resItem);
      });
    };

    JsonApi.prototype.canLoadMore = function(items) {
      var count, _ref, _ref1;
      if (!items.$isArray) {
        throw new Error(MSG_NOT_ARRAY);
      }
      count = (_ref = items.$root) != null ? (_ref1 = _ref.meta) != null ? _ref1.count : void 0 : void 0;
      if (count == null) {
        return true;
      }
      if (!count) {
        return 0;
      }
      return items.$root.meta.count - items.length;
    };

    JsonApi.prototype.loadMore = function(items, limit) {
      var opts;
      if (!items.$isArray) {
        throw new Error(MSG_NOT_ARRAY);
      }
      opts = {};
      if (limit != null) {
        opts.limit = limit;
      }
      opts.skip = items.length;
      return this.get(items, opts).then((function(_this) {
        return function(data) {
          var extraLinked, k, v, _i, _len, _results;
          items.$root.meta = data.$root.meta;
          for (_i = 0, _len = data.length; _i < _len; _i++) {
            v = data[_i];
            items.push(v);
          }
          extraLinked = _this.getLinked(data);
          if (extraLinked) {
            if (!_this.getLinked(items) && extraLinked) {
              items.$root.linked = {};
            }
            _results = [];
            for (k in extraLinked) {
              if (!_this.getLinked(items)[k]) {
                _this.getLinked(items)[k] = [];
              }
              _results.push((function() {
                var _j, _len1, _ref, _results1;
                _ref = this.getLinked(data, k);
                _results1 = [];
                for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
                  v = _ref[_j];
                  _results1.push(this.getLinked(items)[k].push(v));
                }
                return _results1;
              }).call(_this));
            }
            return _results;
          }
        };
      })(this));
    };

    JsonApi.prototype.load = function(item) {
      return this.get(item).then(function(resItem) {
        return objUtil.replace(item, resItem);
      });
    };

    JsonApi.prototype.update = function() {
      var args, item, url, urlArgs, _i;
      args = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), item = arguments[_i++];
      urlArgs = args.length ? args : [item];
      url = this.urlFor.apply(this, urlArgs);
      return this.http.put(url, this.toJson(item)).then((function(_this) {
        return function(res) {
          return _this.fromJson(res.data);
        };
      })(this));
    };

    JsonApi.prototype["delete"] = function(item) {
      return this.http["delete"](this.urlFor({
        type: item.$type,
        id: item.$id
      })).then(function(res) {
        return true;
      });
    };

    JsonApi.prototype.create = function(opts, item) {
      if (item == null) {
        item = {};
      }
      return this.http.post(this.urlFor(opts), this.toJson(item)).then((function(_this) {
        return function(res) {
          return _this.fromJson(res.data);
        };
      })(this));
    };

    JsonApi.prototype.get = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return this.http.get(this.urlFor.apply(this, args)).then((function(_this) {
        return function(res) {
          return _this.fromJson(res.data);
        };
      })(this));
    };

    return JsonApi;

  })(JsonApiItemsFactory);

  cloneHttp = function(objF) {
    var f, httpAttrs, k, v;
    f = new Function(objF);
    httpAttrs = {};
    angular.copy(objF, httpAttrs);
    for (k in httpAttrs) {
      if (!__hasProp.call(httpAttrs, k)) continue;
      v = httpAttrs[k];
      f[k] = v;
    }
    return f;
  };

  JsonApiBuilder = (function() {
    function JsonApiBuilder(opts) {
      if (opts == null) {
        opts = {};
      }
      this.defaults = angular.extend({}, opts);
    }

    JsonApiBuilder.prototype.newClient = function(opts) {
      if (opts == null) {
        opts = {};
      }
      opts = angular.extend({}, this.defaults, opts);
      opts.http = cloneHttp(opts.http);
      return new JsonApi(opts);
    };

    return JsonApiBuilder;

  })();

}).call(this);
