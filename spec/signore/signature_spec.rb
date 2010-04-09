# encoding: UTF-8

module Signore describe Signature do

  before do
    Database.load 'spec/fixtures/signatures.yml'
  end

  context '#display' do

    it 'returns a signature formatted with meta information (if available)' do
      Database.db[2].display.should == '// sometimes I believe compiler ignores all my comments'
      Database.db[4].display.should == "stay-at-home executives vs. wallstreet dads\n                                     [kodz]"
      Database.db[1].display.should == "You do have to be mad to work here, but it doesn’t help.\n                                      [Gary Barnes, asr]"
      Database.db[3].display.should == "Bruce Schneier knows Alice and Bob’s shared secret.\n                             [Bruce Schneier Facts]"
      Database.db[0].display.should == "She was good at playing abstract confusion in\nthe same way a midget is good at being short.\n              [Clive James on Marilyn Monroe]"
    end

  end

  context '#tagged_with?' do

    it 'says whether a tagged signature is tagged with a given tag' do
      Database.db[2].should_not be_tagged_with 'fnord'
      Database.db[2].should     be_tagged_with 'programming'
      Database.db[2].should     be_tagged_with 'tech'
    end

    it 'says that an untagged signature is not tagged with any tag' do
      Database.db[4].should_not be_tagged_with 'fnord'
    end

  end

end end
