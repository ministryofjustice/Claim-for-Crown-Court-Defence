RSpec.shared_examples 'a base claim' do
  describe '.belongs_to' do
    it { is_expected.to belong_to(:external_user) }
    it { is_expected.to belong_to(:creator).class_name('ExternalUser') }

    it { is_expected.to belong_to(:court) }
    it { is_expected.to belong_to(:transfer_court).class_name('Court') }
    it { is_expected.to belong_to(:offence) }
  end

  describe '.has_many' do
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

  describe '.has_one' do
    it { is_expected.to have_one(:assessment) }
    it { is_expected.to have_one(:certification) }
  end

  describe 'delegates' do
    it { is_expected.to delegate_method(:provider_id).to(:creator) }
  end

  describe 'accepts nested attributes for' do
    it { is_expected.to accept_nested_attributes_for(:misc_fees) }
    it { is_expected.to accept_nested_attributes_for(:expenses) }
    it { is_expected.to accept_nested_attributes_for(:defendants) }
    it { is_expected.to accept_nested_attributes_for(:disbursements) }
    it { is_expected.to accept_nested_attributes_for(:assessment) }
    it { is_expected.to accept_nested_attributes_for(:redeterminations) }
  end
end

RSpec.shared_examples 'a claim with an AGFS fee scheme factory' do |fee_scheme_factory|
  describe '#fee_scheme' do
    subject(:fee_scheme) { claim.fee_scheme }

    let(:main_hearing_date) { Date.parse('20 April 2023') }
    let(:representation_order_date) { Date.parse('17 April 2023') }

    before do
      claim.main_hearing_date = main_hearing_date
      claim.defendants = [
        create(:defendant, representation_orders: [create(:representation_order, representation_order_date:)])
      ]
      allow(fee_scheme_factory).to receive(:call).and_call_original
    end

    it do
      fee_scheme
      expect(fee_scheme_factory).to have_received(:call).with(
        main_hearing_date:,
        representation_order_date:
      )
    end

    it { is_expected.to eq(FeeScheme.find_by(name: 'AGFS', version: 15)) }

    context 'when a fee scheme 13 representation order date is added' do
      subject do
        claim.fee_scheme
        claim.defendants << create(
          :defendant,
          representation_orders: [
            create(:representation_order, representation_order_date: Date.parse('5 January 2023'))
          ]
        )
        claim.fee_scheme
      end

      it { is_expected.to eq(FeeScheme.find_by(name: 'AGFS', version: 13)) }
    end
  end
end

RSpec.shared_examples 'a claim with an LGFS fee scheme factory' do |fee_scheme_factory|
  describe '#fee_scheme' do
    subject(:fee_scheme) { claim.fee_scheme }

    let(:main_hearing_date) { Date.parse('31 January 2023') }
    let(:representation_order_date) { Date.parse('1 January 2023') }

    before do
      claim.main_hearing_date = main_hearing_date
      claim.defendants = [
        create(:defendant, representation_orders: [create(:representation_order, representation_order_date:)])
      ]
      allow(fee_scheme_factory).to receive(:call).and_call_original
    end

    it do
      fee_scheme
      expect(fee_scheme_factory).to have_received(:call).with(
        main_hearing_date:,
        representation_order_date:
      )
    end

    it { is_expected.to eq(FeeScheme.find_by(name: 'LGFS', version: 10)) }

    context 'when a fee scheme 9 representation order date is added' do
      subject do
        claim.fee_scheme
        claim.defendants << create(
          :defendant,
          representation_orders: [
            create(:representation_order, representation_order_date: Date.parse('5 January 2019'))
          ]
        )
        claim.fee_scheme
      end

      it { is_expected.to eq(FeeScheme.find_by(name: 'LGFS', version: 9)) }
    end
  end
end

RSpec.shared_examples 'a claim delegating to case type' do
  it { is_expected.to delegate_method(:requires_trial_dates?).to(:case_type) }
  it { is_expected.to delegate_method(:requires_retrial_dates?).to(:case_type) }
end

RSpec.shared_examples 'uses claim cleaner' do |cleaner_class|
  describe '#cleaner' do
    let(:cleaner) { instance_double(cleaner_class) }

    before do
      allow(cleaner_class).to receive(:new).with(subject).and_return(cleaner)
      allow(cleaner).to receive(:call)
      subject.save
    end

    it { expect(cleaner).to have_received(:call) }
  end
end
