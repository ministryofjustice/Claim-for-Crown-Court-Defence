# NOTE: This is a MAJOR shoehorn patch to get around the convoluted way the validations in this application work.
# Its main intent is to solve the problem of having validations for a claim per step/stage and because of the fact
# that Rails autosaves and validates associations that have been defined as with 'accept_nested_attributes_for'.
# What that causes is that for a given step/stage that does not require a given association to be validated, as long as
# the association itself exists, Rails will automatically save and validate it which is not the expected behaviour here.
#
# The initial approach was to define the association with the option validate: Proc.new { |claim| claim.condition_to_validate? }
# Unfortunately, the association definition support Procs or lambdas but does not evaluate them, just checks if the value is not false.
#
# The next approach was to define the association with the option validate: false and have an explicity validation for the association
# conditional to the step/stage it belongs:
#
# validates_associated :association_name, if: Proc.new { |claim| claim.condition_to_validate? }
#
# This approach works as intended with a caveat: the errors produced are not attached to the parent object anymore (as they were with the
# default autosave/validaton set in the association definition)
#
# So, that gets us here, patching the autosave association to check if the validate option is a proc, and if so evaluated it to determine
# if the associated records needs to be validated or not.
#
# WARNING: This patch will likely cause any further Rails updates/upgrades to break, so do keep that in mind!!!
#
# This should probably be re-thinked going forward, so a cleaner/less disruptive solution is choosen instead.
# This is not a recommended approach to take!!!, but rather a last resort approach to get around a very unsual behaviour (saving invalid records into the database).

module ActiveRecord
  module AutosaveAssociation
    private
      alias old_association_valid? association_valid?

      def association_valid?(reflection, record, index=nil)
        if reflection.options[:validate].is_a?(Proc)
          return true unless reflection.options[:validate].call(self)
        end
        old_association_valid?(reflection, record, index)
      end
  end
end
