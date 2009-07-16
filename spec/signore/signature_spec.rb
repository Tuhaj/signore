inside_connection do
module Signore describe Signature do

  it 'should return a proper random signature based on the provided labels' do
    Signore.db.transaction do
      lambda { Signature.find_random_by_labels([]) }.should_not raise_error
      lambda { Signature.find_random_by_labels(['foo']) }.should_not raise_error
      Signature.find_random_by_labels(['programming']).text.should == '// sometimes I believe compiler ignores all my comments'
      Signature.find_random_by_labels(['programming', 'tech']).text.should == '// sometimes I believe compiler ignores all my comments'
      srand 1981
      Signature.find_random_by_labels(['tech']).text.should == '// sometimes I believe compiler ignores all my comments'
      srand 1979
      Signature.find_random_by_labels(['tech']).text.force_encoding('UTF-8').should == 'Bruce Schneier knows Alice and Bob’s shared secret.'
      srand
      raise Sequel::Rollback
    end
  end

  it 'should properly display signatures with (and without) author/source' do
    Signature[1].display.should == '// sometimes I believe compiler ignores all my comments'
    Signature[2].display.should == 'stay-at-home executives vs. wallstreet dads [kodz]'
    Signature[3].display.should == 'You do have to be mad to work here, but it doesn’t help. [Gary Barnes, asr]'
    Signature[4].display.should == 'Bruce Schneier knows Alice and Bob’s shared secret. [Bruce Schneier Facts]'
  end

end end
end