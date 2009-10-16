module Signore describe Wrapper do

  it 'should wrap signatures properly' do
    samples = YAML.load_file 'spec/fixtures/wrapping.yaml'
    samples.each do |sample|
      Wrapper.new(sample[:text], sample[:meta]).display.should == sample[:wrapped]
    end
  end

end end
