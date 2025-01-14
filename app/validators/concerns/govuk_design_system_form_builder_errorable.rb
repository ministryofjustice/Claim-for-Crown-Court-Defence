# frozen_string_literal: true

# Include this module for validators on models that
# are using the govuk_design_system_formbuilder
# for their front-end forms.
#
# It ensures the errors are named following the convention
# it uses and thereby enables functional links between
# govuk_error_summary and govuk_ "field" errors.
#
# NOTE: Once all models are using this module then the method(s)
# can be promoted to the superclass and this module removed
#
module GovukDesignSystemFormBuilderErrorable
  extend ActiveSupport::Concern

  included do
    def associated_error_attribute(association_name, record_num, error)
      "#{association_name}_attributes_#{record_num}_#{error.attribute}"
    end
  end
end
