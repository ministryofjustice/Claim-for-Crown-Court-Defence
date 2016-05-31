Dir[File.join(Rails.root, 'lib', 'extensions', '*.rb')].each { |file| require file }

class Array
  include ArrayExtension
end

class String
  include StringExtension
end

class ActiveRecord::Base
  include NestedAttributesExtension
end

class ActionController::Parameters
  include ParametersExtension
end

module Devise::Models::Lockable
  include DeviseExtension
end
