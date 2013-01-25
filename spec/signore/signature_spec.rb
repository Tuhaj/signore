# encoding: UTF-8

require_relative '../spec_helper'

module Signore describe Signature do
  before do
    @confusion, @mad, @compiler, @bruce, @dads, @starwars = YAML.load_file('spec/fixtures/signatures.yml')['signatures']
  end

  describe '#tagged_with?' do
    it 'says whether a tagged signature is tagged with a given tag' do
      refute @compiler.tagged_with? 'fnord'
      assert @compiler.tagged_with? 'programming'
      assert @compiler.tagged_with? 'tech'
    end

    it 'says that an untagged signature is not tagged with any tag' do
      refute @dads.tagged_with? 'fnord'
    end
  end

  describe '#to_s' do
    it 'returns a signature formatted with meta information (if available)' do
      @compiler.to_s.must_equal <<-end.dedent.strip
        // sometimes I believe compiler ignores all my comments
      end

      @dads.to_s.must_equal <<-end.dedent.strip
        stay-at-home executives vs. wallstreet dads
                                             [kodz]
      end

      @mad.to_s.must_equal <<-end.dedent.strip
        You do have to be mad to work here, but it doesn’t help.
                                              [Gary Barnes, asr]
      end

      @bruce.to_s.must_equal <<-end.dedent.strip
        Bruce Schneier knows Alice and Bob’s shared secret.
                                     [Bruce Schneier Facts]
      end

      @confusion.to_s.must_equal <<-end.dedent.strip
        She was good at playing abstract confusion in
        the same way a midget is good at being short.
                      [Clive James on Marilyn Monroe]
      end

      @starwars.to_s.must_equal <<-end.dedent.strip
        Amateur fighter pilot ignores orders, listens to
        the voices in his head and slaughters thousands.
                            [Star Wars ending explained]
      end
    end

    it 'handles edge cases properly' do
      class SignatureWithMeta < Signature
        attr_accessor :meta
      end

      YAML.load_file('spec/fixtures/wrapper.yml').each do |sample|
        sig = SignatureWithMeta.new sample[:text]
        sig.meta = sample[:meta]
        sig.to_s.must_equal sample[:wrapped]
      end
    end
  end
end end
