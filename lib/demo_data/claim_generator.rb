require 'erb'
require 'yaml'
require_relative 'utility.rb'

require 'pp'

module DemoData

  class ClaimGenerator

    def initialize
      filename = File.dirname(__FILE__) + '/fixtures/claims.yml'
      @claims = YAML.load(ERB.new(File.read(filename)).result)['claims']
      ap @claims
      
    end
  end

end


