types = "Boolean Number String Function Array Date RegExp Object".split(" ")
TYPE_MAP = []

for type in types
  TYPE_MAP[ "[object " + type + "]" ] = type.toLowerCase()

class Foundry
  constructor: ->
    @definitions = {}
    @traits = {}

  sequence: (callback) ->
    counter = 0
    callback ?= (i) -> "#{i}"

    -> callback(++counter)

  trait: (name, attributes) ->
    @traits[name] = attributes

  typeOf: (item) ->
    if item == null or item == undefined
      String(item) 
    else
      TYPE_MAP[Object::toString.call(item)] || 'object'

  define: (klass, options, attributes) ->
    if @definitions.hasOwnProperty klass
      throw new Error("there is an existing factory definition for #{klass}")

    if arguments.length == 2
      attributes = options
      options = {}
    else if arguments.length == 3
      options ||= {}
    else if arguments.length == 1
      options = {}
      attributes = {}

    attributes ||= {}
    attributes.id ||= @sequence()

    parent = options.from

    if parent and @definitions.hasOwnProperty(parent)
      attributes = $.extend {}, @definitions[parent], attributes
    else if parent and !@definitions.hasOwnProperty(parent)
      throw new Error("Undefined factory: #{parent}")

    options.traits ||= []
    options.traits = [options.traits] if typeof(options.traits) == 'string'

    for trait in options.traits
      unless @traits.hasOwnProperty trait
        throw new Error("there is no trait definition for #{trait}")
      attributes = $.extend true, {}, @traits[trait], attributes

    @definitions[klass] = attributes

  build: (klass, attributes = {}) ->
    unless @definitions.hasOwnProperty klass
      throw new Error("there is no factory definition for #{klass}")

    definition = @definitions[klass]
    instance = $.extend true, {}, definition, attributes

    @_evaluateFunctions instance


  _evaluateFunctions: (record) ->
    for k, v of record
      switch @typeOf v
        when 'function'
          result = record[k]()
          delete record[k]
          record[k] = result
        when 'object'
          record[k] = @_evaluateFunctions v
        else
          record

    record


  create: (klass, attributes = {}) ->
    throw new Error("Cannot create without an adapter!") unless @adapter

    object = @build klass, attributes
    @adapter.save klass, object

  tearDown: ->
    for k, v of @definitions
      delete @definitions[k]
    for k, v of @traits
      delete @traits[k]

exports.Foundry = Foundry
