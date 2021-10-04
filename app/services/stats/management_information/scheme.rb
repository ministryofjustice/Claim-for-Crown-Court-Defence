# frozen_string_literal: true

module Stats
  module ManagementInformation
    class Scheme
      def initialize(name)
        @name = name.to_s.downcase
      end

      attr_accessor :name
      delegate :nil?, :present?, :blank?, :to_s, to: :name

      def ==(other)
        to_s == other.to_s.downcase
      end
      alias eql? ==

      def valid?
        %w[agfs lgfs].include?(name)
      end
    end
  end
end
