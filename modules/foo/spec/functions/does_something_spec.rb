require 'spec_helper'

describe 'does_something' do

  # Hook up the scope object so we can reference it later
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  things = []

  # Functions that does_something calls internally can be mocked the same way
  get_hostname = mock_function('get_hostname', nil)
  before(:each) {
    things = ['penguin', 'badger', 'spaniel']

    # Mock lookupvar normally as it's a function of the scope object
    scope.stubs(:lookupvar).with('fqdn').returns('host.foo.com')
    get_hostname.stubs(:call).with(['host.foo.com']).returns('host')
  }

  it 'should helpfully return whatever gets passed in' do
    result = scope.function_does_something [things]
    result.should be_a_kind_of Array
    result.size.should eq things.size
    result[0].should eq things[0]
  end

end
