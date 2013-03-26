Foundry = require('../dist/foundry').Foundry
assert = require 'assert'
strictEqual = assert.strictEqual

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
        id: '1',
        display_name: 'Ralph',
        status: 'prospect'

    it 'should create a default object with default values', ->
      contact = foundry.build 'Contact'

      strictEqual '1', contact.id
      strictEqual 'Ralph', contact.display_name
      strictEqual 'prospect', contact.status

    it 'default values can be overriden in new instance', ->
      contact = foundry.build 'Contact', 
        id: 2,
        display_name: 'Bob'

      strictEqual 2, contact.id
      strictEqual 'Bob', contact.display_name
      strictEqual 'prospect', contact.status

    it 'attributes can be function', ->
      contact = foundry.build 'Contact',
        company: -> 'Nokia'

      strictEqual 'Nokia', contact.company

    it 'attribute functions have access to the object', ->
      contact = foundry.build 'Contact',
        name: 'Adam',
        email: -> "#{@name}@radiumcrm.com"

      strictEqual "Adam@radiumcrm.com", contact.email

    it 'attribute can be nested', ->
      foundry.define 'ContactWithAddress', from: 'Contact',
        address:
          street: '123 Foo Bar',
          city: 'Baztown'

      contact = foundry.build 'ContactWithAddress',
        address:
          street: '456 Qux'

      strictEqual '456 Qux', contact.address.street
      strictEqual 'Baztown', contact.address.city

    it 'function attributes can be nested', ->
      foundry.define 'ContactWithAddress', from: 'Contact',
        address:
          street: '123 Foo Bar',
          city: 'Baztown'

      contact = foundry.build 'ContactWithAddress',
        address:
          street: -> '456 Qux'

      strictEqual '456 Qux', contact.address.street
      strictEqual 'Baztown', contact.address.city

  describe "Parents", ->
    beforeEach ->
      foundry.define 'Human', sex: 'Male'

    it 'a foundry can use a parent', ->
      foundry.define 'Adam', from: 'Human',
        name: 'Adam'

      adam = foundry.build 'Adam'

      strictEqual 'Adam', adam.name
      strictEqual 'Male', adam.sex

    it 'a foundry can define a parent and extend its defaults', ->
      foundry.define 'Female', from: 'Human',
        sex: 'Female'

      female = foundry.build 'Female'

      strictEqual 'Female', female.sex

    it 'uses the parent id sequence', ->
      foundry.define 'Female', from: 'Human',
        sex: 'Female'

      female = foundry.build 'Female'
      male = foundry.build 'Human'

      assert.notStrictEqual female.id, male.id

    it 'allows the id to be overridden', ->
      foundry.define 'Female', from: 'Human',
        sex: 'Female'
        id: 'anne'

      female = foundry.build 'Female'

      strictEqual 'anne', female.id

  describe 'Sequences', ->
    it 'attribute can autoincrement', ->
      foundry.define 'User',
        id: foundry.sequence()

      a = foundry.build 'User'
      b = foundry.build 'User'
      c = foundry.build 'User'

      strictEqual '1', a.id
      strictEqual '2', b.id
      strictEqual '3', c.id

    it 'sequences accept a callback', ->
      foundry.define 'User',
        id: foundry.sequence (i) -> "User #{i}"

      a = foundry.build 'User'
      b = foundry.build 'User'
      c = foundry.build 'User'

      strictEqual 'User 1', a.id
      strictEqual 'User 2', b.id
      strictEqual 'User 3', c.id

    it 'sequences defined in the parent work', ->
      foundry.define 'Parent',
        uuid: foundry.sequence()

      foundry.define 'Child', from: 'Parent',
        name: "Adam"

      a = foundry.build 'Child'
      b = foundry.build 'Child'
      c = foundry.build 'Child'

      strictEqual '1', a.id
      strictEqual '2', b.id
      strictEqual '3', c.id

    it 'an id sequence is added by default', ->
      foundry.define 'User',
        name: 'Adam'

      a = foundry.build 'User'
      b = foundry.build 'User'
      c = foundry.build 'User'

      strictEqual '1', a.id
      strictEqual '2', b.id
      strictEqual '3', c.id

  describe "create", ->
    beforeEach ->
      foundry.adapter = new Foundry.NullAdapter()

      foundry.define 'Todo',
        name: 'Todo'

    afterEach ->
      foundry.adapter = new Foundry.NullAdapter()

    it 'objects can be created with the null adapter', ->
      todo = foundry.create 'Todo'
      strictEqual "Todo", todo.name

    it 'create raise an error when there is no adapter', ->
      foundry.adapter = undefined

      assert.throws (-> foundry.create('todo')), /adapter/i

  describe "Traits", ->
    beforeEach ->
      foundry.trait 'timestamps',
        created: 'yesterday',
        updated: 'today'

    it 'raise an errors on unknown traits', ->
      foundry.define 'Todo',
       task: 'Todo'

      assert.throws (-> foundry.define('Todo', traits: 'fooBar'))

    it 'traits can be used a definition time', ->
      foundry.define 'Todo', traits: 'timestamps',
        task: 'Todo'

      todo = foundry.build 'Todo'

      strictEqual 'Todo', todo.task
      strictEqual 'yesterday', todo.created

    it 'traits can be defined in parent classes', ->
      foundry.define 'Task', traits: 'timestamps',
        due: 'tomorrow'

      foundry.define 'Todo', from: 'Task',
        task: 'Todo'

      todo = foundry.build 'Todo'

      strictEqual 'Todo', todo.task
      strictEqual 'yesterday', todo.created
      strictEqual 'today', todo.updated
