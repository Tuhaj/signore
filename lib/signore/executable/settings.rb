require 'optparse'

module Signore class Executable; class Settings
  attr_reader :db_path

  def initialize args
    extract_options_from args
    @args = args
  end

  def action
    args.first
  end

  def forbidden_tags
    args[1..-1].select { |tag| tag.start_with? '~' }.map { |tag| tag[1..-1] }
  end

  def required_tags
    args[1..-1].reject { |tag| tag.start_with? '~' }
  end

  attr_reader :args
  private     :args

  private

  def db_dir
    ENV.fetch('XDG_DATA_HOME') { File.expand_path '~/.local/share' }
  end

  def extract_options_from args
    @db_path = "#{db_dir}/signore/signatures.yml"
    OptionParser.new do |opts|
      opts.on '-d', '--database PATH', 'Database location' do |path|
        @db_path = path
      end
    end.parse! args
  end
end end end
