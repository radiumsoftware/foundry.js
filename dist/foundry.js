(function() {
  var Foundry, TYPE_MAP, type, types, _i, _len;

  types = "Boolean Number String Function Array Date RegExp Object".split(" ");

  TYPE_MAP = [];

  for (_i = 0, _len = types.length; _i < _len; _i++) {
    type = types[_i];
    TYPE_MAP["[object " + type + "]"] = type.toLowerCase();
  }

  Foundry = (function() {

    function Foundry() {
      this.definitions = {};
      this.traits = {};
    }

    Foundry.prototype.sequence = function(callback) {
      var counter;
      counter = 0;
      if (callback == null) {
        callback = function(i) {
          return "" + i;
        };
      }
      return function() {
        return callback(++counter);
      };
    };

    Foundry.prototype.trait = function(name, attributes) {
      return this.traits[name] = attributes;
    };

    Foundry.prototype.typeOf = function(item) {
      if (item === null || item === void 0) {
        return String(item);
      } else {
        return TYPE_MAP[Object.prototype.toString.call(item)] || 'object';
      }
    };

    Foundry.prototype.define = function(klass, options, attributes) {
      var parent, trait, _j, _len1, _ref;
      if (this.definitions.hasOwnProperty(klass)) {
        throw new Error("there is an existing factory definition for " + klass);
      }
      if (arguments.length === 2) {
        attributes = options;
        options = {};
      } else if (arguments.length === 3) {
        options || (options = {});
      } else if (arguments.length === 1) {
        options = {};
        attributes = {};
      }
      attributes || (attributes = {});
      attributes.id || (attributes.id = this.sequence());
      parent = options.from;
      if (parent && this.definitions.hasOwnProperty(parent)) {
        attributes = $.extend({}, this.definitions[parent], attributes);
      } else if (parent && !this.definitions.hasOwnProperty(parent)) {
        throw new Error("Undefined factory: " + parent);
      }
      options.traits || (options.traits = []);
      if (typeof options.traits === 'string') {
        options.traits = [options.traits];
      }
      _ref = options.traits;
      for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
        trait = _ref[_j];
        if (!this.traits.hasOwnProperty(trait)) {
          throw new Error("there is no trait definition for " + trait);
        }
        attributes = $.extend(true, {}, this.traits[trait], attributes);
      }
      return this.definitions[klass] = attributes;
    };

    Foundry.prototype.build = function(klass, attributes) {
      var definition, instance;
      if (attributes == null) {
        attributes = {};
      }
      if (!this.definitions.hasOwnProperty(klass)) {
        throw new Error("there is no factory definition for " + klass);
      }
      definition = this.definitions[klass];
      instance = $.extend(true, {}, definition, attributes);
      return this._evaluateFunctions(instance);
    };

    Foundry.prototype._evaluateFunctions = function(record) {
      var k, result, v;
      for (k in record) {
        v = record[k];
        switch (this.typeOf(v)) {
          case 'function':
            result = record[k]();
            delete record[k];
            record[k] = result;
            break;
          case 'object':
            record[k] = this._evaluateFunctions(v);
            break;
          default:
            record;

        }
      }
      return record;
    };

    Foundry.prototype.create = function(klass, attributes) {
      var object;
      if (attributes == null) {
        attributes = {};
      }
      if (!this.adapter) {
        throw new Error("Cannot create without an adapter!");
      }
      object = this.build(klass, attributes);
      return this.adapter.save(klass, object);
    };

    Foundry.prototype.tearDown = function() {
      var k, v, _ref, _ref1, _results;
      _ref = this.definitions;
      for (k in _ref) {
        v = _ref[k];
        delete this.definitions[k];
      }
      _ref1 = this.traits;
      _results = [];
      for (k in _ref1) {
        v = _ref1[k];
        _results.push(delete this.traits[k]);
      }
      return _results;
    };

    return Foundry;

  })();

  exports.Foundry = Foundry;

}).call(this);

(function() {
  var NullAdapter;

  NullAdapter = (function() {

    function NullAdapter() {}

    NullAdapter.prototype.save = function(klass, record) {
      return record;
    };

    return NullAdapter;

  })();

  exports.Foundry || (exports.Foundry = {});

  exports.Foundry.NullAdapter = NullAdapter;

}).call(this);
