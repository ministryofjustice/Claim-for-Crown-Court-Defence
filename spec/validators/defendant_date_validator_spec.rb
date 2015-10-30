require 'rails_helper'
require File.dirname(__FILE__) + '/date_validation_helpers'

describe DefendantValidator do

  include RspecDateValidationHelpers

  let(:defendant)           { FactoryGirl.build :defendant, claim: FactoryGirl.build(:claim, force_validation: true) }

  context 'date of birth' do
    it { should_error_if_not_present(defendant, :date_of_birth, 'blank') }
    it { should_error_if_before_specified_date(defendant, :date_of_birth, 120.years.ago, 'check') }
    it { should_error_if_after_specified_date(defendant, :date_of_birth, 10.years.ago, 'check') }
  end

end
