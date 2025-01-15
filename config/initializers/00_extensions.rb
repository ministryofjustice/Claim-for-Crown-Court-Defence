Dir[File.join(Rails.root, 'lib', 'extensions', '*.rb')].each { |file| require file }

class Array
  include Extensions::ArrayExtension
  include Extensions::RemoteExtension
end

class Hash
  include Extensions::HashExtension
end

class String
  include Extensions::StringExtension
end

class ActiveRecord::Base
  include Extensions::NestedAttributesExtension
  include Extensions::RemoteExtension
end

class ActiveRecord::Relation
  include Extensions::RemoteExtension
end

module Devise::Models::Lockable
  include Extensions::DeviseExtension
end

module Rails
  extend Extensions::RailsModuleExtension
end

module ActiveSupport::XmlMini
  extend Extensions::XMLMiniExtension
end

class TrueClass
  include Extensions::BooleanExtension::True
end

class FalseClass
  include Extensions::BooleanExtension::False
end

module ActionView
  module Helpers
    class FormBuilder
      include Extensions::FormBuilderExtension
    end
  end
end
