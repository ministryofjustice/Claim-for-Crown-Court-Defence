# mixin for adding required date accessors
# for using gov_uk_date_field helpers with
# a virtual/unpersisted date attribute.
#
# Example:
# ```
# # model
# class MyModel
#   gov_uk_date_accessor :my_virtual_date_field, my_other_date_field
# end
# ```
#
# ```
# # view
# form_with(model: :my_model) do |f|
#   .form-group
#     = f.gov_uk_date_field(:my_virtual_date_field)
#   .form-group
#     = f.gov_uk_date_field(:my_other_date_field)
# ```
#
module GovUk
  module DateAccessor
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def gov_uk_date_accessor(*date_fields)
        date_fields.each do |field|
          define_method(field) do
            instance_variable_get("@#{field}".to_sym)
          end

          define_method("#{field}_dd") do
            instance_variable_get("@#{field}".to_sym)&.strftime('%d')
          end

          define_method("#{field}_mm") do
            instance_variable_get("@#{field}".to_sym)&.strftime('%mm')
          end

          define_method("#{field}_yyyy") do
            instance_variable_get("@#{field}".to_sym)&.strftime('%yyyy')
          end

          define_method("#{field}=") do |date|
            instance_variable_set("@#{field}".to_sym, date)
          end

          define_method("#{field}_dd=") do |day|
            instance_variable_set("@#{field}_dd".to_sym, day)
          end

          define_method("#{field}_mm=") do |month|
            instance_variable_set("@#{field}_mm".to_sym, month)
          end

          define_method("#{field}_yyyy=") do |year|
            instance_variable_set("@#{field}_yyyy".to_sym, year)
          end
        end
      end
    end
  end
end
