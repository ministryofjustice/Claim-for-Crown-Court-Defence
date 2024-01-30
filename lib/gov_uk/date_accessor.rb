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
      base.include InstanceMethods
      base.extend ClassMethods
    end

    module InstanceMethods
      private

      def date_from_parts(field)
        instance_variable_set(:"@#{field}", parse_date_from_parts(field))
      rescue ArgumentError
        instance_variable_set(:"@#{field}", nil)
      end

      def parse_date_from_parts(field)
        yyyy = instance_variable_get(:"@#{field}_yyyy").to_i
        raise ArgumentError unless valid_year?(yyyy)
        mm = instance_variable_get(:"@#{field}_mm").to_i
        dd = instance_variable_get(:"@#{field}_dd").to_i
        Date.new(yyyy, mm, dd)
      end

      def valid_year?(year)
        current_year = Date.current.year
        range = Range.new(current_year - 50, current_year + 50)
        range.include?(year)
      end
    end

    module ClassMethods
      def gov_uk_date_accessor(*date_fields)
        # rubocop:disable Metrics/BlockLength
        date_fields.each do |field|
          define_method(field) do
            instance_variable_get(:"@#{field}")
          end

          define_method(:"#{field}_dd") do
            instance_variable_get(:"@#{field}")&.strftime('%d')
          end

          define_method(:"#{field}_mm") do
            instance_variable_get(:"@#{field}")&.strftime('%m')
          end

          define_method(:"#{field}_yyyy") do
            instance_variable_get(:"@#{field}")&.strftime('%Y')
          end

          define_method(:"#{field}=") do |date|
            instance_variable_set(:"@#{field}", date)
          end

          define_method(:"#{field}_dd=") do |day|
            instance_variable_set(:"@#{field}_dd", day)
            date_from_parts(field)
          end

          define_method(:"#{field}_mm=") do |month|
            instance_variable_set(:"@#{field}_mm", month)
            date_from_parts(field)
          end

          define_method(:"#{field}_yyyy=") do |year|
            instance_variable_set(:"@#{field}_yyyy", year)
            date_from_parts(field)
          end
        end
        # rubocop:enable Metrics/BlockLength
      end
    end
  end
end
