Dir[File.join(Rails.root, 'lib', 'extensions', '*.rb')].each { |file| require file }

class Array
  include ArrayExtension
  include RemoteExtension
end

class String
  include StringExtension
end

class ActiveRecord::Base
  include NestedAttributesExtension
  include RemoteExtension
end

class ActiveRecord::Relation
  include RemoteExtension
end

class ActionController::Parameters
  include ParametersExtension
end

module Devise::Models::Lockable
  include DeviseExtension
end

module Rails
  extend RailsModuleExtension
end

module ActiveSupport::XmlMini
  extend XmlMiniExtension
end
