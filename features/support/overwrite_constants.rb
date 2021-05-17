# frozen_string_literal: true

# Idea from
# https://makandracards.com/makandra/6125-how-to-overwrite-and-reset-constants-within-cucumber-features
#
module ConstantsHelper
  def saved_constants
    @saved_constants ||= {}
  end

  def undefined_constants
    @undefined_constants ||= {}
  end

  def overwrite_constant(constant, value, object = Object)
    constant = constant.to_sym
    if object.const_defined?(constant)
      saved_constants[object] ||= {}
      saved_constants[object][constant] = object.const_get(constant) unless saved_constants[object].has_key?(constant)
    else
      undefined_constants[object] ||= []
      undefined_constants[object] << constant
    end

    silence_warnings { object.const_set(constant, value) }
  end

  def overwrite_constants(constants = {}, object = Object)
    constants.each do |constant, value|
      overwrite_constant constant, value, object
    end
  end

  def reset_constant(constant, object = Object)
    silence_warnings do
      if undefined_constants[object] && undefined_constants[object].include?(constant)
        object.instance_eval { remove_const(constant) }
        undefined_constants[object].delete(constant)
      else
        object.const_set(constant, saved_constants[object].delete(constant))
      end
    end
  end

  def reset_constants(constants = nil, object = Object)
    constants ||= (saved_constants[object].keys | undefined_constants.fetch(object, []))
    constants.each do |constant|
      reset_constant(constant, object)
    end
  end

  def reset_all_constants
    (saved_constants.keys | undefined_constants.keys).each do |object|
      reset_constants(nil, object)
    end
  end
end

World(ConstantsHelper)

After do
  reset_all_constants
end
