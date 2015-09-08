require 'rails_helper'
require File.dirname(__FILE__) + '/date_validation_helpers'

describe DefendantDateValidator do

  include RspecDateValidationHelpers

  let(:defendant)           { FactoryGirl.build :defendant, claim: FactoryGirl.build(:claim, force_validation: true) }

  context 'date of birth' do
    it { should_error_if_not_present(defendant, :date_of_birth, 'Please enter valid date of birth') }
    it { should_error_if_before_specified_date(defendant, :date_of_birth, 120.years.ago, 'Date of birth must not be more than 120 years ago') }
    it { should_error_if_after_specified_date(defendant, :date_of_birth, 10.years.ago, 'Date of birth must be at least 10 years ago') }
  end

end
