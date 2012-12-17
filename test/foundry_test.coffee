Foundry = require('../dist/foundry').Foundry
assert = require 'assert'

describe 'Foundry', ->
  foundry = null

  beforeEach ->
    foundry = new Foundry()

  afterEach ->
    foundry.tearDown()

  it 'raises exception for undefined foundry', ->
    assert.throws (-> foundry.build('Unkown')), "must throw error for unkown definition"

  it 'raise an error when redifining a foundry', ->
    foundry.define 'Contact'

    assert.throws (-> foundry.define('Contact', {})), "Redifining must throw an error"

  describe 'Default values', ->
    beforeEach ->
      foundry.define 'Contact',
        id: '1'
        display_name: 'Ralph'
        status: 'prospect'

    it 'should create a default object with default values', ->
      contact = foundry.build 'Contact'

      equal contact.id, '1'
      equal contact.display_name, 'Ralph'
      equal contact.status, 'prospect'

    it 'default values can be overriden in new instance', ->
      contact = foundry.build 'Contact',
        id: 2
        display_name: 'Bob'

      equal contact.id, '2'
      equal contact.display_name, 'Bob'
      equal contact.status, 'prospect'

    it 'attributes can be function', ->
      contact = foundry.build 'Contact', 
        company: -> 'Nokia'

      equal contact.company, 'Nokia'

    it 'attribute functions have access to the object', ->
      contact = foundry.build 'Contact',
        name: 'Adam'
        email: -> "#{@name}@radiumcrm.com"

      equal contact.email, "Adam@radiumcrm.com"

    it 'attribute can be nested', ->
      foundry.define 'ContactWithAddress', from: 'Contact',
        address:
          street: '123 Foo Bar'
          city: 'Baztown'

      contact = foundry.build 'ContactWithAddress',
        address:
          street: '456 Qux'

      equal contact.address.street, '456 Qux', 'Nested attributes override'
      equal contact.address.city, 'Baztown', 'Nested attributes maintained'

    it 'function attributes can be nested', ->
      foundry.define 'ContactWithAddress', from: 'Contact',
        address:
          street: '123 Foo Bar'
          city: 'Baztown'

      contact = foundry.build 'ContactWithAddress',
        address:
          street: -> '456 Qux'

      equal contact.address.street, '456 Qux', 'Nested attributes override'
      equal contact.address.city, 'Baztown', 'Nested attributes maintained'

  describe "Parents", ->
    beforeEach ->
      foundry.define 'Human',
        sex: 'Male'

    it 'a foundry can use a parent', ->
      foundry.define 'Adam', from: 'Human',
        name: 'Adam'

      adam = foundry.build 'Adam'

      equal adam.name, 'Adam', 'Defined attribute correct'
      equal adam.sex, 'Male', 'Parent attribute correct'

    it 'a foundry can define a parent and extend its defaults', ->
      foundry.define 'Female', from: 'Human',
        sex: 'Female'

      female = foundry.build 'Female'

      equal female.sex, 'Female', 'Parent attribute redefined'

  describe 'Sequences', ->
    it 'attribute can autoincrement', ->
      foundry.define 'User',
        id: foundry.sequence()

      a = foundry.build 'User'
      b = foundry.build 'User'
      c = foundry.build 'User'

      strictEqual a.id, '1', 'user sequence one'
      strictEqual b.id, '2', 'user sequence two'
      strictEqual c.id, '3', 'user sequence three'

    it 'sequences accept a callback', ->
      foundry.define 'User',
        id: foundry.sequence (i) -> "User #{i}"

      a = foundry.build 'User'
      b = foundry.build 'User'
      c = foundry.build 'User'

      strictEqual a.id, 'User 1', 'user sequence one'
      strictEqual b.id, 'User 2', 'user sequence two'
      strictEqual c.id, 'User 3', 'user sequence three'

    it 'sequences defined in the parent work', ->
      foundry.define 'Parent',
        uuid: foundry.sequence()

      foundry.define 'Child', from: 'Parent',
        name: "Adam"

      a = foundry.build 'Child'
      b = foundry.build 'Child'
      c = foundry.build 'Child'

      strictEqual a.id, '1', 'child with parent sequence one'
      strictEqual b.id, '2', 'child with parent sequence two'
      strictEqual c.id, '3', 'child with parent sequence three'

    it 'an id sequence is added by default', ->
      foundry.define 'User'
        name: 'Adam'

      a = foundry.build 'User'
      b = foundry.build 'User'
      c = foundry.build 'User'

      strictEqual a.id, '1', 'rookie sequence one'
      strictEqual b.id, '2', 'rookie sequence two'
      strictEqual c.id, '3', 'rookie sequence three'

  describe "create", ->
    beforeEach ->
      foundry.adapter = new Foundry.NullAdapter()

      foundry.define 'Todo', 
        name: 'Todo'

    afterEach ->
      foundry.adapter = new Foundry.NullAdapter()

  it 'objects can be created with the null adapter', ->
    todo = foundry.create 'Todo'
    equal todo.name, "Todo"

  it 'create raise an error when there is no adapter', ->
    foundry.adapter = undefined

    raises (-> foundry.create('todo')), /adapter/i

  describe "Traits", ->
    beforeEach ->
      foundry.trait 'timestamps',
        created: 'yesterday',
        updated: 'today'

    it 'raise an errors on unknown traits', ->
      foundry.define 'Todo',
        task: 'Todo'

      raises (-> foundry.define('Todo', traits: 'fooBar'))

    it 'traits can be used a definition time', ->
      foundry.define 'Todo', traits: 'timestamps',
        task: 'Todo'

      todo = foundry.build 'Todo'

      equal todo.task, 'Todo', 'Record build correctly'
      equal todo.created, 'yesterday', 'Trait built correctly'

    it 'traits can be defined in parent classes', ->
      foundry.define 'Task', traits: 'timestamps',
        due: 'tomorrow'

      foundry.define 'Todo', from: 'Task',
        task: 'Todo'

      todo = foundry.build 'Todo'

      equal todo.task, 'Todo', 'Record build correctly'
      equal todo.created, 'yesterday', 'Trait built correctly'
      equal todo.updated, 'today', 'Trait built correctly'
