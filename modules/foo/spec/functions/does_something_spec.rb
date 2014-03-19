require 'spec_helper'

describe 'does_something' do

  # Hook up the scope object so we can reference it later
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  let(:things) { ['penguin', 'badger', 'spaniel'] }

  before(:each) do
    # Functions that does_something calls internally can be mocked the same way
    MockFunction.new('get_hostname') { |f| f.stubs(:call).with(['host.foo.com']).returns('host') }

    # Mock lookupvar normally as it's a function of the scope object
    scope.stubs(:lookupvar).with('fqdn').returns('host.foo.com')
  end

  it 'should helpfully return whatever gets passed in' do
    result = scope.function_does_something [things]
    expect(result).to be_an Array
    expect(result.size).to eq things.size
    expect(result[0]).to eq things[0]
  end

end
