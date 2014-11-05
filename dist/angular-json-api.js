(function() {
  'use strict';
  var JsonApi, JsonApiBase, JsonApiBuilder, JsonApiItemsFactory, cloneHttp, objUtil, _RESERVED, _RESERVED_ROOT,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  objUtil = null;

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
      var json;
      json = {};
      json[item.$type] = this.getAttributes(item);
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

    JsonApi.prototype.urlFor = function(opts) {
      var id, type, url;
      if (opts.$href) {
        return opts.$href;
      }
      url = opts.url, id = opts.id, type = opts.type;
      if (url == null) {
        url = opts.$href;
      }
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
          return "" + this.base + type;
      }
    };

    JsonApi.prototype.updateIn = function(item) {
      return (this.update(item)).then(function(resItem) {
        return objUtil.replace(item, resItem);
      });
    };

    JsonApi.prototype.createIn = function(opts, item) {
      return (this.create(opts, item)).then(function(resItem) {
        return objUtil.replace(item, resItem);
      });
    };

    JsonApi.prototype.getIn = function(opts, item) {
      return (this.get(opts)).then(function(resItem) {
        return objUtil.replace(item, resItem);
      });
    };

    JsonApi.prototype.load = function(item) {
      return this.get({
        id: item.$id,
        type: item.$type
      }).then(function(resItem) {
        return objUtil.replace(item, resItem);
      });
    };

    JsonApi.prototype.update = function(item) {
      return this.http.put(this.urlFor(item), this.toJson(item)).then((function(_this) {
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

    JsonApi.prototype.get = function(opts) {
      return this.http.get(this.urlFor(opts)).then((function(_this) {
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
