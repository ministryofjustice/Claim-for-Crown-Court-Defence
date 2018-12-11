# If you use amoeba (https://github.com/amoeba-rb/amoeba) for cloning your
# ActiveRecord objects this concern should be useful, it allows you properly inherit
# associations if you use (Single Table) Inheritance.
#
# Just do something like:
#
# class SomeTable < ActiveRecord::Base
#   has_many :somethings
#
#   duplicate_this do
#     include_association :somethings
#   end
# end
#
# TODO: this may no longer be needed at all but provides
# a wrapper for calling the amoeba block

module Duplicable
  extend ActiveSupport::Concern

  included do
    class_attribute :amoeba_blocks
  end

  module ClassMethods
    def inherited(subclass)
      super
      subclass.duplicate_this
    end

    def duplicate_this(&block)
      self.amoeba_blocks ||= begin
        blocks = [proc { enable }]
        blocks << block if block_given?
        blocks
      end

      blocks = self.amoeba_blocks

      amoeba do |config|
        blocks.each { |blk| config.instance_eval(&blk) }
      end
    end
  end

  def duplicate
    blocks = self.class.amoeba_blocks || []

    self.class.amoeba do |config|
      blocks.each { |blk| config.instance_eval(&blk) }
    end

    amoeba_dup
  end
end
