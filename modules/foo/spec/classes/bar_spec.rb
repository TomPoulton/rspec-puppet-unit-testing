require 'spec_helper'

describe 'foo::bar' do

  let(:pre_condition) { [
      'define foo::baz ($param1, $param2) {}',
      'define foo::dependency {}',
      'foo::dependency { "need me": }'
  ] }

  # Creates a function for puppet to find, and returns an object for attaching mock calls.
  # by default, the function will return 'I can do teh thing' for any arguments passed in.
  does_something = mock_function('does_something', {:default_value => 'I can do teh thing'})

  # We can mock hiera the same way we mock any other function
  hiera = mock_function('hiera', nil)

  before(:each) {
    # For all tests the function will return 'blah blah' when 'blah' is passed in
    does_something.stubs(:call).with(['blah']).returns('blah blah')

    # Sets up some mock data in hiera
    hiera.stubs(:call).with(['key']).returns('value')
  }

  it {
    # For this specific test the function will return 'diff diff' when 'blah' is passed in
    does_something.stubs(:call).with(['blah']).returns('diff diff')
    should contain_foo__baz('bazzy bazzy baz baz')
  }
end
