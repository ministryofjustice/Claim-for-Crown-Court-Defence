# Migrating to using govuk formbuilder

This guide covers back end validation and error message translation changes required for attributes that are using a govuk-formbuilder form and field helper. It does not include the changes required in the views.


- [migrate basic attributes](#migrate-a-direct-attribute-of-an-object)
- [migrate associated object](#migrate-an-association-on-an-object)

## Migrate a direct attribute of an object

Examples for `claim.case_number` attribute

1. find all instance s of the validation method

    ```ruby
    def validate_case_number
    end
    ```

2. change error string to a symbol

    ```ruby
    def validate_case_number
      validate_presence(:case_number, 'blank')
    end
    # becomes
    def validate_case_number
      validate_presence(:case_number, :blank)
    end
    ```

3. add activerecord error translation in standard location

    ```yml
    # config/locales/en/models/claim.yml
    ---
    en:
      activerecord:
        errors:
          models:
            claim/base_claim:
              attributes:
                case_number:
                  blank: Enter a case number
    ```

4. rename custom error translation key

    ```yml
    # config/locales/en/error_messages/claim.yml
    case_number:
      _seq: 50
      blank:
        long: Enter a case number
        short: Enter a case number
        api: Enter a case number
     # becomes
    case_number:
      _seq: 50
      enter_a_case_number:
        long: Enter a case number
        short: _
        api: Enter a case number
    ```

5. Identify specs that cover this error and change to expect the actual english error message.

    Ideally do this before steps 1..4 to use TDD

    For example:
    ```ruby
    # /spec/validators/claim/base_claim_validator_spec.rb
    RSpec.describe Claim::BaseClaimValidator, type: :validator do
      ...
      context 'case_number' do
        it 'errors if not present' do
          claim.case_number = nil
          should_error_with(claim, :case_number, 'blank')
        end
        # becomes
        it 'errors if not present' do
          claim.case_number = nil
          should_error_with(claim, :case_number, 'Enter a case number')
        end
        ...
      end
     end
    ```
    Please add a spec in the validator if one does not exist.


## Migrate an association on an object

Examples for `claim.case_type` association

Typically this would be a `belongs_to` relation . In such instances we should validate the
presence of the object itself, `claim.case_type`, but all errors on the object must be added to the foreign key attribute, `claim.case_type_id`.

1. rename all instances of the validation method to use the foreign key attribute name

    ```ruby
    def validate_case_type
    end
    # becomes
    def validate_case_type_id
    end
    ```

2. change calling key in all claim validators

  ```ruby
  class Claim::AdvocateHardshipClaimValidator < Claim::BaseClaimValidator
    ...
    def self.fields_for_steps
      {
        case_details: %i[
          case_type
        # becomes
        case_details: %i[
          case_type_id
      }
  ```

3. change any method presence checks to use helper

    ```ruby
    def validate_case_type_id
      validate_presence(:case_type, 'blank')
    end
    # becomes
    def validate_case_type_id
      validate_belongs_to_object_presence(:case_type, :blank)
    end
    ```

4. change any validation checks, other than presence, to ensure they add errors to the foreign key attribute only, not the object. In addition change the message string to a symbol.

    ```ruby
    def validate_case_type_id
      ...
      validate_inclusion(:case_type, @record.eligible_case_types, 'inclusion')
    end
    # becomes
    def validate_case_type_id
      validate_inclusion(:case_type_id, @record.eligible_case_types.pluck(:id), :inclusion)
    end
    ```

5. add activerecord error translations in standard location for the foreign key

    ```yml
    # config/locales/en/models/claim.yml
    ---
    en:
      activerecord:
        errors:
          models:
            claim/base_claim:
              attributes:
                case_type_id:
                  blank: Choose a case type
                  inclusion: Choose an eligible case type
    ```

6. rename custom error translation keys

    ```yml
    # config/locales/en/error_messages/claim.yml
    case_type:
      _seq: 30
      blank:
        long: Choose a case type
        short: Choose a case type
        api: Choose a case type
      inclusion:
        long: Choose an eligible case type
        short: Choose an eligible case type
        api: Choose an eligible case type
    # becomes
    case_type_id:
      _seq: 30
      choose_a_case_type:
        long: Choose a case type
        short: _
        api: Choose a case type
      choose_an_eligible_case_type:
        long: Choose an eligible case type
        short: _
        api: Choose an eligible case type
    ```

7. Identify specs that cover this error and change to expect the actual english error message on the foreign key attribute

    Ideally do this before steps 1..4 to use TDD

    For example:
    ```ruby
    # /spec/validators/claim/base_claim_validator_spec.rb
    RSpec.describe Claim::BaseClaimValidator, type: :validator do
      ...
      context 'when validating case_type' do
        it 'errors if not present' do
          claim.case_type = nil
          should_error_with(claim, :case_type, 'blank')
        end
       # becomes
        it 'errors if not present' do
          claim.case_type = nil
          should_error_with(claim, :case_type_id, 'Choose a case type')
        end
       ....
     end
    ```
    Please add a spec in the validator if one does not exist.
