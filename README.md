# Unit Testing with rspec-puppet

### Update:

I've created a gem for this that includes a `MockFunction` class and a `TemplateHarness` for testing templates. I'll refactor this sample project later, but for now, look at the [rspec-puppet-utils](https://github.com/Accuity/rspec-puppet-utils) project

## The Problem

Take a look at the `foo::bar` class ([modules/foo/manifests/bar.pp](modules/foo/manifests/bar.pp)), if you want to unit test this class there are a few dependencies that ideally we'd like to mock:

##### `does_something` function
This function is defined within the foo module, but we don't want to test its functionality in the tests for `foo::bar`, we would write a separate spec for this function

##### `hiera` function
There are a few ways of handling Hiera with `rspec-puppet` and [`rspec-hiera-puppet`](https://github.com/amfranz/rspec-hiera-puppet), really `hiera` is just another function but we still need to get some values out of it.

##### functions from other modules
I haven't included one here, but a prime example would be using a function from `stdlib`. There are ways (like librarian puppet) of bringing down other modules during your tests, but again, ideally we only want to test this specific class and not any functions that the class depends on.

##### `foo::baz` defined type ([modules/foo/manifests/baz.pp](modules/foo/manifests/baz.pp))
This is defined within the `foo` module so there's not a problem with it being missing, but `baz` references a class from another module. This isn't an ideal thing to do, but I think that sometimes it's necessary!?

Regardless of whether `foo::baz` contains classes from another module, classes from the same module, or no other classes at all, we still don't want to be testing `foo::baz` in the spec for `foo::bar`.

##### `foo::dependency` class
In this case `foo::dependency` is also in the `foo` module, but it's something that needs to be in the catalogue otherwise Puppet will throw an error. `foo::dependency` could also easily be `other::dependency` (again, not ideal, but possible).

## The Solution

See the spec for the `bar` class ([modules/foo/spec/classes/bar_spec.rb](modules/foo/spec/classes/bar_spec.rb)). This has examples of all of the following, but there are two key parts:

##### 1. `let(:pre_condition)`

This is where we mock out the other classes or defined types
- `define foo::baz ($param1, $param2) {}` creates a mock `foo::baz` defined type and overrides the existing one from the module
- `define foo::dependency {}` creates a mock `foo::dependency` class
- `foo::dependency { "need me": }` adds a new "instance" of `foo::dependency` to the catalogue to satisfy the `require` relationship

This is nothing new, there are examples of `let(:pre_condition)` all over the place, I included them here to create a complete example

##### 2. `mock_function()`

The `mock_function()` method is defined within the [spec_helper.rb](modules/foo/spec/spec_helper.rb) file. The rest of the file is pretty much the same as what gets generated when you run `rspec-puppet-init`.

The key part is the `newfunction` call which can be re-written like so

```ruby
Puppet::Parser::Functions.newfunction(name.to_sym, type_hash) do |args|
    mock_func.call(args)
end
```

If it looks familiar, that's because this is how you write custom functions for puppet. The difference is that all the function does is call the `call` method on your `mock_func` object and return the result.

So for example, if the class you're testing calls `my_func('a_string', 3)` and expects to get `'penguin'` in return (it's a weird function I know but just run with it!) then you can mock this by doing:

```ruby
my_func = mock_function('my_func', nil)

before(:each) {
  my_func.stubs(:call).with(['a_string', 3]).returns('penguin')
}
```

Note that all mock functions take one parameter, which is an array of values, like an array of args funnily enough!

By passing `nil` as the second parameter to `mock_function`, the puppet function `my_func` will be created as a return value method (`:type => :rvalue`) by default

If you want to mock a function that doesn't return a value, do this:

```ruby
non_return = mock_function('non_return', {:type => :statement, :default_value => nil})
```

- `:type => :statement` is required otherwise puppet will complain that `'non_return' must be the value of a statement`
- `:default_value => nil` means that `mock_func` has at least one stub method to respond to `call()`, what it returns doesn't matter

[bar_spec.rb](modules/foo/spec/classes/bar_spec.rb) has some other examples for default values and other stuffs

## Mocking Hiera

`hiera` is just another function so mock it like so:

```ruby
hiera = mock_function('hiera', nil)
before(:each) {
  hiera.stubs(:call).raises(Puppet::ParseError.new('Key not found'))
  hiera.stubs(:call).with(['my-key']).returns('badger')
}
```

The `before(:each)` bit isn't necessary but it shows how to raise an error if the key isn't present. Note that the error message isn't exactly the same as the one that the real `hiera` would thrown!

## Testing Custom Functions

The spec for `does_something` [modules/foo/spec/functions/does_something_spec.rb](modules/foo/spec/functions/does_something_spec.rb) has a few examples of getting hold of return values, mocking internal function calls, and mocking `lookupvar()` for getting facts

## Setup

To get this running for another module:
- add `puppetlabs_spec_helper` to your Gemfile (or gem install)
- run `rspec-puppet-init` in the module root as you would normally
- replace the `spec_helper.rb` file with the one from `foo`
- replace the module's `Rakefile` file with the one from `foo`
- copy the `Rakefile` from the root of this project if you want to use it

I think that's it!? [puppetlabs_spec_helper](http://rubygems.org/gems/puppetlabs_spec_helper) provides a few things:
- one if its dependencies is `mocha` which provides the `stubs().with().returns()` stuff
- it has some nice inbuilt `rake` tasks like `help`, `spec_prep`, `spec_clean`, etc which I'll probably make more use of as my tests become more complex
- provides a `scope` object that you can hook into for testing functions (example coming soon)

## Proof

Almost forgot, you can run this if you want, just clone the repo, `cd` into the `foo` directory, and run `rake rspec` (or just `rake` as `rspec` is the default task). If you play around with it and manage to break it let me know, this is all new so I haven't had a chance to properly test it against loads of scenarios or the rspec-puppet matchers (the `should` things, whatever they're called).

**Edit:** I did say to run `rake spec` above, but really you should run `rake rspec`. The `spec` task is provided by `puppetlabs_spec_helper/rake_tasks` along with a couple of others, by default it cleans up your fixtures dir, which can be useful (and you can use the `spec_prep` and `spec_clean` yourself if you want), but it also deletes your site.pp file which breaks these tests!

## Testing All Modules

I've also put a Rakefile in what would be the root of the puppet directory (i.e. it's at the same level as the modules directory). You can run the tests for all modules by running `rake rspec` from the project's root directory (again `rspec` is the default task, so just running `rake` will work too). You can run all the specs for a specific module by running `rake rspec:[module]` e.g. `rake rspec:foo`. Running `rake help` (comes from `puppetlabs_spec_helper`) will show the full list of module tasks.

**Caveat 1:** Running `rake rspec` is like `cd`ing into each module directory and running `rake rspec`, except that it isn't, so there might be some weird things to look out for!?

**Caveat 2:** If you run `rake rspec` and the task for one of the modules fails, no subsequent tasks in the list will run. Ideally the tasks for all the modules should run even if one (or all) of them fail. If someone could just fix it, that would be great :)

## The End

You can use this same setup to mock classes, defined types, and functions within specs for classes, defined types or functions

I'm new to rspec and rspec-puppet and still relatively new to ruby so there are probably nicer/better ways to do some of this stuff but it works for me so far.

Comments, questions and constructive criticism are all welcome!
