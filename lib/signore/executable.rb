# encoding: UTF-8

module Signore class Executable
  def initialize args = ARGV, opts = {}
    options   = options_from args
    @db       = opts.fetch(:db_factory) { Database }.new options.db_path
    @action   = options.action
    @must_tag = options.must_tag
    @wont_tag = options.wont_tag
  end

  def run input = $stdin
    case action
    when 'prego'
      sig = db.find tags: must_tag, no_tags: wont_tag
    when 'pronto'
      params = params_from input
      sig = Signature.new params.text, params.author, params.source, params.subject, must_tag
      db << sig
    end

    puts sig.to_s
  end

  attr_reader :action, :db, :must_tag, :wont_tag
  private     :action, :db, :must_tag, :wont_tag

  private

  def get_param param, input
    puts "#{param}?"
    value = ''
    value << input.gets until value.lines.to_a.last == "\n"
    value.strip
  end

  def params_from input
    OpenStruct.new Hash[[:text, :author, :subject, :source].map do |param|
      [param, get_param(param, input)]
    end].reject { |_, value| value.empty? }
  end

  def options_from args
    OpenStruct.new.tap do |options|
      db_dir = ENV.fetch('XDG_DATA_HOME') { File.expand_path '~/.local/share' }
      options.db_path = "#{db_dir}/signore/signatures.yml"
      OptionParser.new do |opts|
        opts.on '-d', '--database PATH', "Location of the signature database (default: #{options.db_path})" do |path|
          options.db_path = path
        end
      end.parse! args
      options.action = args.shift
      options.wont_tag, options.must_tag = args.partition { |tag| tag.start_with? '~' }
      options.wont_tag.map! { |tag| tag[1..-1] }
      abort 'usage: signore prego|pronto [label, …]' unless ['prego', 'pronto'].include? options.action
    end
  end
end end
