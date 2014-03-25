require 'spec_helper'

describe 'tempy.erb' do

  let(:template) { TemplateHarness.new('spec/fixtures/modules/foo/templates/tempy.erb') }

  it 'should create credentials when supplied' do
    template.set '@class_var', 'booooooo'
    result = template.run
    expect(result).to match /This came from the class: bo/
  end

end
