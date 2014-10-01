require 'fileutils'
require 'pathname'
require 'tempfile'
require 'tmpdir'
require_relative '../spec_helper'
require_relative '../../lib/signore/database'
require_relative '../../lib/signore/signature'
require_relative '../../lib/signore/tags'

module Signore
  describe Database do
    describe '#<<' do
      let(:path) { Pathname.new(Tempfile.new('').path)                     }
      let(:sig)  { Signature.new(text)                                     }
      let(:text) { 'Normaliser Unix c’est comme pasteuriser le camembert.' }

      it 'saves the provided signature to disk' do
        Database.new(path: path) << sig
        path.read.must_include text
      end

      it 'returns the saved signature' do
        Database.new(path: path).<<(sig).must_equal sig
      end
    end

    describe '#find' do
      let(:database)   { Database.new(path: path, sig_finder: sig_finder) }
      let(:path)       { Pathname.new('spec/fixtures/signatures.yml')     }
      let(:sig_finder) { fake(:sig_finder, as: :class)                    }
      let(:sigs)       { store.transaction(true) { store['signatures'] }  }
      let(:store)      { YAML::Store.new(path)                            }

      it 'returns a random signature by default' do
        stub(sig_finder).find(sigs, tags: Tags.new) { sigs.last }
        database.find.must_equal sigs.last
      end

      it 'returns a random signature based on required and forbidden tags' do
        tags = Tags.new(forbidden: %w(tech), required: %w(programming security))
        stub(sig_finder).find(sigs, tags: tags) { sigs.last }
        database.find(tags: tags).must_equal sigs.last
      end

      it 'doesn’t blow up if the path is missing' do
        begin
          tempdir = Dir.mktmpdir
          path = Pathname.new("#{tempdir}/some_intermediate_dir/sigs.yml")
          Database.new(path: path).find(tags: Tags.new).must_equal Signature.new
        ensure
          FileUtils.rmtree tempdir
        end
      end
    end
  end
end
