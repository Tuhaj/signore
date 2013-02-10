# encoding: UTF-8

require_relative '../spec_helper'

module Signore describe Executable do
  describe '#initialize' do
    it 'prints usage if no command is given' do
      stderr = capture_io { -> { Executable.new [] }.must_raise SystemExit }.last
      stderr.must_include 'usage: signore prego|pronto [label, …]'
    end

    it 'prints usage if a bogus command is given' do
      stderr = capture_io { -> { Executable.new ['bogus'] }.must_raise SystemExit }.last
      stderr.must_include 'usage: signore prego|pronto [label, …]'
    end

    it 'loads the signature database from the specified location' do
      db_factory = MiniTest::Mock.new.expect :new, nil, ['signatures.yml']
      Executable.new ['-d', 'signatures.yml', 'prego'], db_factory: db_factory
      db_factory.verify
    end

    it 'loads the signature database from ~/.local/share/signore/signatures.yml if no location specified' do
      pending if ENV['XDG_DATA_HOME']
      db_factory = MiniTest::Mock.new
      db_factory.expect :new, nil, [File.expand_path('~/.local/share/signore/signatures.yml')]
      Executable.new ['prego'], db_factory: db_factory
      db_factory.verify
    end

    it 'loads the signature database from $XDG_DATA_HOME/signore/signatures.yml if $XDG_DATA_HOME is set' do
      begin
        orig_data_home = ENV.delete 'XDG_DATA_HOME'
        ENV['XDG_DATA_HOME'] = Dir.tmpdir
        db_factory = MiniTest::Mock.new
        db_factory.expect :new, nil, ["#{ENV['XDG_DATA_HOME']}/signore/signatures.yml"]
        Executable.new ['prego'], db_factory: db_factory
        db_factory.verify
      ensure
        orig_data_home ? ENV['XDG_DATA_HOME'] = orig_data_home : ENV.delete('XDG_DATA_HOME')
      end
    end
  end

  describe '#run' do
    describe 'prego' do
      it 'prints a signature tagged with the provided tags' do
        capture_io do
          Executable.new(['-d', 'spec/fixtures/signatures.yml', 'prego', 'tech', 'programming']).run
        end.first.must_equal <<-end.dedent
          // sometimes I believe compiler ignores all my comments
        end
      end

      it 'prints a signature based on allowed and forbidden tags' do
        capture_io do
          Executable.new(['-d', 'spec/fixtures/signatures.yml', 'prego', '~programming', 'tech', '~security']).run
        end.first.must_equal <<-end.dedent
          You do have to be mad to work here, but it doesn’t help.
                                                [Gary Barnes, asr]
        end
      end
    end

    describe 'pronto' do
      before do
        @file = Tempfile.new ''
      end

      it 'asks about signature parts and saves given signature with provided labels' do
        input = StringIO.new <<-end.dedent
          The Wikipedia page on ADHD is like 20 pages long. That’s just cruel.\n
          Mark Pilgrim\n\n\n
        end

        capture_io do
          Executable.new(['-d', @file.path, 'pronto', 'Wikipedia', 'ADHD']).run input
        end.first.must_equal <<-end.dedent
          text?
          author?
          subject?
          source?
          The Wikipedia page on ADHD is like 20 pages long. That’s just cruel.
                                                                [Mark Pilgrim]
        end

        capture_io do
          Executable.new(['-d', @file.path, 'prego', 'Wikipedia', 'ADHD']).run
        end.first.must_equal <<-end.dedent
          The Wikipedia page on ADHD is like 20 pages long. That’s just cruel.
                                                                [Mark Pilgrim]
        end
      end

      it 'handles multi-line signatures' do
        input = StringIO.new <<-end.dedent
          ‘I’ve gone through over-stressed to physical exhaustion – what’s next?’
          ‘Tuesday.’\n
          Simon Burr, Kyle Hearn\n\n\n
        end

        capture_io do
          Executable.new(['-d', @file.path, 'pronto']).run input
        end.first.must_equal <<-end.dedent
          text?
          author?
          subject?
          source?
          ‘I’ve gone through over-stressed to physical exhaustion – what’s next?’
          ‘Tuesday.’
                                                         [Simon Burr, Kyle Hearn]
        end
      end
    end
  end
end end
