# Unit Testing with rspec-puppet

## The Problem

Take a look at the [foo::bar](foo/manifests/bar.pp) class, if you want to unit test this class there are a few dependencies that ideally we'd like to mock:

##### `does_something` function
This function is defined within the foo module, but we don't want to test its functionality in the tests for `foo::bar`, we would write a separate spec for this function

##### `hiera` function
Hiera is just another function but we still need to get some values out of it. There are a few ways of mocking hiera and we'll cover them later

##### functions from other modules
I haven't included one here, but a prime example would be using a function from stdlib. There are ways (like librarian puppet) of bringing down other modules during your tests, but again, ideally we only want to test this specific class and not any functions that the class depends on.

##### [foo::baz](foo/manifests/baz.pp) defined type
This is defined within the `foo` module so there's not a problem with it being missing, but `baz` references a class from another module. This isn't an ideal thing to do, but I think that sometimes it's necessary!?

Regardless of whether `foo::baz` contains classes from another module, classes from the same module, or no other classes at all, we still don't want to be testing `foo::baz` in the spec for `foo::bar`.

##### `foo::dependency` class
In this case `foo::dependency` is also in the `foo` module, but it's something that needs to be in the catalogue otherwise Puppet will throw an error. `foo::dependency` could also easily be `other::dependency` (again, not ideal, but possible).

## The Solution

See [bar_spec.rb](foo/spec/classes/bar_spec.rb)

There are two key parts:

##### 1. `let(:pre_condition)`

This is where we mock out the other classes or defined types
- `define foo::baz ($param1, $param2) {}` creates a mock `foo::baz` defined type and overrides the existing one from the module
- `define foo::dependency {}` creates a mock `foo::dependency` class
- `foo::dependency { "need me": }` adds a new "instance" of `foo::dependency` to the catalogue to satisfy the `require` relationship

This is nothing new, there are examples of `let(:pre_condition)` all over the place, I included them here to create a complete example

##### 2. `mock_function()`

The `mock_function()` method is defined within the [spec_helper.rb](foo/spec/spec_helper.rb) file. The rest of the file is pretty much the same as what gets generated when you run `rspec-puppet-init`.

The key part is the `newfunction` call which can be re-written like so

```ruby
Puppet::Parser::Functions.newfunction(name.to_sym, type_hash) do |args|
    mock_func.call(args)
end
```

If it looks familiar, that's `because` this is how you write custom functions for puppet. The difference is that all the function does is call the `call` method on your `mock_func` object and return the result.

So for example, if the class you're testing calls `my_func('a_string', 3)` and expects to get `penguin` in return (it's a weird function I know but just run with it!) then you can mock this by doing:

```ruby
my_func = mock_function('my_func', nil)

before(:each) {
  my_func.stubs(:call).with(['a_string'], 3).returns('penguin')
}
```

By passing `nil` as the second parameter to `mock_function`, the puppet function `my_func` will be created with `:type => :rvalue` by default

[bar_spec.rb](foo/spec/classes/bar_spec.rb) has some other examples for default values and other stuffs

## The End

You can use this same setup to mock classes, defined types, and functions within specs that test classes, defined types or functions

I'm new to rspec and rspec-puppet and still relatively new to ruby so there are probably nicer/better ways to do some of this stuff but it works for me so far.

Comments, questions and constructive criticism are all welcome!
