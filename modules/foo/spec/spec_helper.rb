require 'rspec-puppet'
require 'puppetlabs_spec_helper/module_spec_helper'

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))

RSpec.configure do |c|
  c.config = '/doesnotexist'
  c.module_path = File.join(fixture_path, 'modules')
  c.manifest_dir = File.join(fixture_path, 'manifests')
  c.color = true
end

def mock_function(name, options = {})

  type_hash = !options.nil? && options.has_key?(:type) ? {:type => options[:type]} : {:type => :rvalue}

  mock_func = {}
  mock_func[:default_value] = options[:default_value] if !options.nil? && options.has_key?(:default_value)
  before(:each) {
    Puppet::Parser::Functions.newfunction(name.to_sym, type_hash) { |args| mock_func.call(args) }
    mock_func.stubs(:call).returns(mock_func[:default_value]) if mock_func.has_key?(:default_value)
  }
  return mock_func
end