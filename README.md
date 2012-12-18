# Foundry.js

The simplest Factory implemenation that could possibly work. Objects
can be created in memory or optionally. persisted to storage.

Foundry is written in pure JS and should work in **node** and in the
**browser.**

## Features

* Define any number of factories
* Share common attributes with traits
* Factories can inherit from other factories
* Sequences
* Associations
* Ember-Data integration

## Node

`npm install foundry`

```javascript
Foundry = require('foundry').Foundry

factory = new Foundry();
```

## Browsers

Download the latest version from github

## Basic Use

```javascript
// Do what you need to get the Foundry global for 
// your env

foundry = new Foundry();

// Define a simple factory named "person"
foundry.define('person', {
  name: 'Adam Hawkins'
  twitter: 'twinturbo'
});


// Build a person
adam = foundry.build('person');

// Customize attributes to be built
paul = foundry.build('person', {
  name: 'Paul Cowan',
  twitter: 'dagda1',
  address: {
    street: '123 Scottish Street',
    postcode: 'AV881c'
  }
});

// You can also use functions

paul = foundry.build('person', {
  addedAt: function() { return new Date(); }
});
```

## Sequences

Sequences are defined at the factory level. They are incremented
everytime a factory definition is built. Sequences return the string
ID. You can pass a callback if you want to use the sequence for
something else.

```javascript
foundry = new Foundry();

foundry.define('counter', {
  id: foundry.sequence();
});

counter1 = foundry.build('counter');
counter1.id  // "1"

counter2 = foundry.build('counter');
counter2.id  // "2"

foundry.define('person', {
  email: foundry.sequence(function(i) { return "email" + i + "@example.com"})
});
```

## Traits

Traits are sets of attributes shared across multiple factories. You
define a trait with the `trait` method. After that, you can use the
trait in any factory.

```javascript
foundry = new Foundry();

foundry.trait('timestamps', {
  updatedAt: function(return new Date());
  createdAt: function(return new Date());
});

foundry.define('record', { traits: ['timestamps'] }, {
  name: 'Foo Bar'
});
```

## Inheritance

It's common you want to subclass or refine a factory. You can do this
by using the `from` option.


```javascript
foundry = new Foundry();

foundry.define('human', {
  location: 'Earth'
});

foundry.define('male', { from: 'human' }, {
  sex: 'male'
  height: '1.6m'
});

foundry.define('female', { from: 'human' }, {
  sex: 'female'
  height: 1.4m'
});

adam = foundry.build('male');
adam.sex  // 'male'
```

## Development

Node is used for development. It's easy to get up and running.

0. Install node and npm.
1. Clone this repo
2. `$ npm install`
3. `$ grunt`

All tests should be passing at this point. Now you're ready to go.

## Building

You can build Foundry from source if you like. First, follow all the
instructions under "Development". Run `grunt` inside the root
directory. This will output `foundry.js` and `foundry.min.js` into
`dist/`. You should only use these files in your project if all tests
passed. You can run tests by running `grunt test`.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
