require 'forwardable'
require_relative 'repo'
require_relative 'settings'
require_relative 'sig_from_stream'

module Signore
  class CLI
    extend Forwardable

    delegate %i(action tags) => :settings

    def initialize(args = ARGV, repo: Repo.new)
      @settings = Settings.new(args)
      @repo     = repo
    end

    def run(input: $stdin)
      case action
      when 'prego'  then puts retrieve_sig
      when 'pronto' then puts create_sig_from(input)
      else abort 'usage: signore prego|pronto [tag, …]'
      end
    end

    attr_reader :repo, :settings
    private     :repo, :settings

    private

    def create_sig_from(input)
      SigFromStream.sig_from(input, tags: tags).tap { |sig| repo << sig }
    end

    def retrieve_sig
      repo.find(tags: tags)
    end
  end
end
