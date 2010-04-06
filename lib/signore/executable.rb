# encoding: UTF-8

module Signore class Executable

  def initialize args
    opts = Trollop.options args do
      opt :database, 'Location of the signature database', :type => String
    end
    Trollop.die 'usage: signore prego|pronto [label, …]' unless ['prego', 'pronto'].include? args.first
    Signore.load_db opts[:database]
  end

end end
