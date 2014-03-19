require 'spec_helper'

describe 'foo::bar' do

  let(:pre_condition) { [
      'define foo::baz ($param1, $param2) {}',
      'define foo::dependency {}',
      'foo::dependency { "need me": }'
  ] }

  # Creates a function for puppet to find, and returns an object for attaching mock calls.
  # Note the let!() not let()
  let!(:does_something) { MockFunction.new('does_something') { |f|
      # The function will return 'I can do the thing' for any arguments passed in.
      f.stubs(:call).returns('I can do the thing')
      # The function will return 'blah blah' when 'blah' is passed in
      f.stubs(:call).with(['blah']).returns('blah blah')
    }
  }

  before(:each) do
    # We can mock hiera the same way we mock any other function
    MockFunction.new('hiera') { |f|
      # Sets up some mock data in hiera
      f.stubs(:call).with(['key']).returns('value')
    }
  end

  it do
    # For this specific test the function will return 'diff diff' when 'blah' is passed in
    does_something.stubs(:call).with(['blah']).returns('diff diff')
    should contain_foo__baz('bazzy bazzy baz baz')
  end

end
