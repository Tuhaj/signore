require 'yaml/store'
require_relative 'sig_finder'
require_relative 'tags'

module Signore class Database
  def initialize path, sig_finder: SigFinder
    @sig_finder = sig_finder
    @store      = YAML::Store.new path
  end

  def << sig
    store.transaction do
      store['signatures'] ||= []
      store['signatures'] << sig
    end
    sig
  end

  def find tags: Tags.new
    sigs = store.transaction(true) { store['signatures'] }
    sig_finder.find sigs, tags: tags
  end

  attr_reader :sig_finder, :store
  private     :sig_finder, :store
end end
