RSpec.shared_examples 'a base claim' do
  context '.belongs_to' do
    it { is_expected.to belong_to(:external_user) }
    it { is_expected.to belong_to(:creator).class_name('ExternalUser').with_foreign_key('creator_id') }

    it { is_expected.to belong_to(:court) }
    it { is_expected.to belong_to(:transfer_court).class_name('Court').with_foreign_key('transfer_court_id') }
    it { is_expected.to belong_to(:offence) }
  end

  context '.has_many' do
    it { is_expected.to have_many(:fees).class_name('Fee::BaseFee').with_foreign_key(:claim_id) }
    it { is_expected.to have_many(:fee_types).class_name('Fee::BaseFeeType') }
    it { is_expected.to have_many(:expenses) } # with/without_vat spec?
    it { is_expected.to have_many(:disbursements) } # with/without_vat spec?
    it { is_expected.to have_many(:defendants) }
    it { is_expected.to have_many(:documents) }
    it { is_expected.to have_many(:messages) }
    it { is_expected.to have_many(:case_worker_claims).with_foreign_key(:claim_id) }
    it { is_expected.to have_many(:case_workers) }
    it { is_expected.to have_many(:claim_state_transitions) }
    it { is_expected.to have_many(:misc_fees) }
    it { is_expected.to have_many(:determinations) }
    it { is_expected.to have_many(:redeterminations) }
    it { is_expected.to have_many(:injection_attempts) }
  end

  context '.has_one' do
    it { is_expected.to have_one(:assessment) }
    it { is_expected.to have_one(:certification) }
  end

  context 'delegates' do
    it { is_expected.to delegate_method(:provider_id).to(:creator) }
    it { is_expected.to delegate_method(:requires_trial_dates?).to(:case_type) }
    it { is_expected.to delegate_method(:requires_retrial_dates?).to(:case_type) }
  end

  context 'accepts nested attributes for' do
    it { is_expected.to accept_nested_attributes_for(:misc_fees) }
    it { is_expected.to accept_nested_attributes_for(:expenses) }
    it { is_expected.to accept_nested_attributes_for(:defendants) }
    it { is_expected.to accept_nested_attributes_for(:disbursements) }
    it { is_expected.to accept_nested_attributes_for(:assessment) }
    it { is_expected.to accept_nested_attributes_for(:redeterminations) }
  end
end