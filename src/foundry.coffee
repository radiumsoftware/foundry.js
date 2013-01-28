class Foundry
  constructor: ->
    @definitions = {}
    @traits = {}

  merge: (base, object) ->
    clone = {}

    for name, value of base
      clone[name] = value

    for name, copy of object
      if copy && copy.constructor == Object
        newBase = base[name] || {}
        clone[name] = @merge newBase, copy
      else if copy
        clone[name] = copy

    clone

  sequence: (callback) ->
    counter = 0
    callback ?= (i) -> "#{i}"

    -> callback(++counter)

  trait: (name, attributes) ->
    @traits[name] = attributes

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
      attributes = @merge @definitions[parent], attributes
    else if parent and !@definitions.hasOwnProperty(parent)
      throw new Error("Undefined factory: #{parent}")

    options.traits ||= []
    options.traits = [options.traits] if typeof(options.traits) == 'string'

    for trait in options.traits
      unless @traits.hasOwnProperty trait
        throw new Error("there is no trait definition for #{trait}")
      attributes = @merge @traits[trait], attributes

    @definitions[klass] = attributes

  build: (klass, attributes = {}) ->
    unless @definitions.hasOwnProperty klass
      throw new Error("there is no factory definition for #{klass}")

    definition = @definitions[klass]
    instance = @merge definition, attributes

    @_evaluateFunctions instance


  _evaluateFunctions: (record) ->
    for k, v of record
      if v.constructor == Function
        result = record[k]()
        delete record[k]
        record[k] = result
      else if v.constructor == Object
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


if exports != undefined
  exports.Foundry = Foundry
else if window != undefined
  window.Foundry = Foundry

