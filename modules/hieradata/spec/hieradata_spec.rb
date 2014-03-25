require 'spec_helper'

describe 'YAML hieradata' do

  validator = HieraData::YamlValidator.new('spec/fixtures/hieradata')
  validator.load_data :ignore_empty

  it 'passwords should be strings' do
    validator.validate(/-password/, [:prod]) { |v|
      expect(v).to be_a String
    }
  end

end
