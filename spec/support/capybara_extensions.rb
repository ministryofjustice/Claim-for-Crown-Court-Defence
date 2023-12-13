# frozen_string_literal: true

require_relative 'capybara_extensions/govuk_component_cccd/matchers'

module CapybaraExtensions
  def self.extension_methods
    (CapybaraExtensions::GovukComponentCccd::Matchers.instance_methods - Object.instance_methods).uniq
  end
end

module Capybara
  module DSL
    CapybaraExtensions.extension_methods.each do |method|
      define_method method do |*args, &block|
        page.send method, *args, &block
      end
    end
  end

  class Session
    CapybaraExtensions.extension_methods.each do |method|
      define_method method do |*args, **kwargs, &block|
        current_scope.send method, *args, **kwargs, &block
      end
    end
  end

  Node::Base.include CapybaraExtensions::GovukComponentCccd::Matchers
  Node::Simple.include CapybaraExtensions::GovukComponentCccd::Matchers
end
