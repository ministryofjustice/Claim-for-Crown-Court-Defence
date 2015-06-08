# == Schema Information
#
# Table name: claims
#
#  id                     :integer          not null, primary key
#  additional_information :text
#  apply_vat              :boolean
#  state                  :string(255)
#  case_type              :string(255)
#  submitted_at           :datetime
#  case_number            :string(255)
#  advocate_category      :string(255)
#  prosecuting_authority  :string(255)
#  indictment_number      :string(255)
#  first_day_of_trial     :date
#  estimated_trial_length :integer          default(0)
#  actual_trial_length    :integer          default(0)
#  fees_total             :decimal(, )      default(0.0)
#  expenses_total         :decimal(, )      default(0.0)
#  total                  :decimal(, )      default(0.0)
#  advocate_id            :integer
#  court_id               :integer
#  offence_id             :integer
#  scheme_id              :integer
#  created_at             :datetime
#  updated_at             :datetime
#  valid_until            :datetime
#  cms_number             :string(255)
#  paid_at                :datetime
#  creator_id             :integer
#  amount_assessed        :decimal(, )
#

require 'rails_helper'

RSpec.describe Claim, type: :model do
  it { should belong_to(:advocate) }
  it { should belong_to(:creator).class_name('Advocate').with_foreign_key('creator_id') }
  it { should delegate_method(:chamber_id).to(:advocate) }

  it { should belong_to(:court) }
  it { should belong_to(:offence) }
  it { should belong_to(:scheme) }
  it { should have_many(:fees) }
  it { should have_many(:fee_types) }
  it { should have_many(:expenses) }
  it { should have_many(:defendants) }
  it { should have_many(:documents) }
  it { should have_many(:messages) }

  it { should have_many(:case_worker_claims) }
  it { should have_many(:case_workers) }

  it { should validate_presence_of(:advocate) }
  it { should validate_presence_of(:creator) }
  it { should validate_presence_of(:court) }
  it { should validate_presence_of(:offence) }
  it { should validate_presence_of(:case_number) }
  it { should validate_presence_of(:prosecuting_authority) }
  it { should validate_inclusion_of(:prosecuting_authority).in_array(%w( cps )) }

  it { should validate_presence_of(:case_type) }
  it { should validate_inclusion_of(:case_type).in_array(%w(
                                                            appeal_against_conviction
                                                            appeal_against_sentence
                                                            breach_of_crown_court_order
                                                            commital_for_sentence
                                                            contempt
                                                            cracked_trial
                                                            cracked_before_retrial
                                                            discontinuance
                                                            elected_cases_not_proceeded
                                                            guilty_plea
                                                            retrial
                                                            trial
                                                            ))
      }

  it { should validate_presence_of(:advocate_category) }
  it { should validate_inclusion_of(:advocate_category).in_array(['QC', 'Led Junior', 'Leading junior', 'Junior alone']) }

  it { should validate_numericality_of(:estimated_trial_length).is_greater_than_or_equal_to(0) }
  it { should validate_numericality_of(:actual_trial_length).is_greater_than_or_equal_to(0) }
  it { should validate_numericality_of(:amount_assessed).is_greater_than_or_equal_to(0) }

  it { should accept_nested_attributes_for(:basic_fees) }
  it { should accept_nested_attributes_for(:non_basic_fees) }
  it { should accept_nested_attributes_for(:expenses) }
  it { should accept_nested_attributes_for(:defendants) }
  it { should accept_nested_attributes_for(:documents) }


  subject { create(:claim) }

  describe '#update_model_and_transition_state' do
    it 'should update the model then transition state to prevent state transition validation errors' do
      # given
      claim = FactoryGirl.create :allocated_claim
      claim_params = {"state_for_form"=>"part_paid", "amount_assessed"=>"88.55", "additional_information"=>""}
      # when
      claim.update_model_and_transition_state(claim_params)
      #then
      expect(claim.reload.state).to eq 'part_paid'
    end
  end

  context 'amount_assessed validation' do
    context 'paid and part paid' do
      it 'should be invalid if amount assessed = 0 for state paid' do
        claim = FactoryGirl.create :paid_claim
        claim.amount_assessed = 0
        expect(claim).not_to be_valid
        expect(claim.errors[:amount_assessed]).to eq( ['cannot be zero for claims in state paid'] )
      end

      it 'should be invalid if amount assessed = 0 for state part_paid' do
        claim = FactoryGirl.create :part_paid_claim
        claim.amount_assessed = 0
        expect(claim).not_to be_valid
        expect(claim.errors[:amount_assessed]).to eq( ['cannot be zero for claims in state part_paid'] )
      end

      it 'should be valid if amount assesssed > 0 and state paid' do
        claim = FactoryGirl.create  :paid_claim
        expect(claim).to be_valid
      end

      it 'should be valid if amount_assessed > 0 and state part_paid' do
        claim = FactoryGirl.create  :part_paid_claim
        expect(claim).to be_valid
      end
    end

    context 'states demanding zero value for amount assessed' do
      it 'should be valid if amount assessed is zero' do
        %w{ draft allocated awaiting_info_from_court refused rejected submitted }.each do |state|
          factory_name = "#{state}_claim".to_sym
          claim = FactoryGirl.create factory_name, amount_assessed: 0
          expect(claim).to be_valid
        end
      end

      it 'should be invalid if amount assessed is not zero' do
        %w{ draft allocated awaiting_info_from_court refused rejected submitted }.each do |state|
          factory_name = "#{state}_claim".to_sym
          expect {
            claim = FactoryGirl.create factory_name, amount_assessed: 356.31
          }.to raise_error ActiveRecord::RecordInvalid
        end
      end
    end
  end

  context 'basic fees' do
    before(:each) do
      @bft1 = FactoryGirl.create :fee_type, :basic,  description: 'ZZZZ'
      @mft1 = FactoryGirl.create :fee_type, :misc,   description: 'CCCC'
      @fft1 = FactoryGirl.create :fee_type, :fixed,  description: 'DDDD'
      @bft2 = FactoryGirl.create :fee_type, :basic,  description: 'AAAA'
      @mft2 = FactoryGirl.create :fee_type, :misc,   description: 'EEEE'
      @bft3 = FactoryGirl.create :fee_type, :basic,  description: 'BBBB'
    end

    describe '#instantiate_basic_fees' do
      it 'should create a fee record for every basic fee type' do
        # Given three basic fee types and some other non-basic fee types
        # when I instantiate a new claim
        claim = FactoryGirl.build :claim
        claim.instantiate_basic_fees

        # it should also instantiate an emtpy fee for every basic fee type and not for the  other fee types
        expect(claim.fees.size).to eq 3
        claim.fees.each do |fee|
          expect(fee.fee_type.fee_category.abbreviation).to eq 'BASIC'
        end

        # and all fees should be blank
        claim.fees.each { |fee| expect(fee).to be_blank }
      end
    end

    describe '#basic_fees' do
      it 'should return a fee for every basic fee sorted alphabetically in order of fee type description' do
        # Given three basic fee types and some other non-basic fee types and a claim
        claim = FactoryGirl.build :claim
        claim.instantiate_basic_fees

        # when I call basic_fees
        fees = claim.basic_fees

        # it should return the three basic fees sorted in order of fee type description
        expect(fees.map(&:description)).to eq( ['AAAA', 'BBBB', 'ZZZZ'])
      end
    end
  end

  describe '.find_by_maat_reference' do
    let!(:other_claim) { create(:claim) }

    before do
      create(:defendant, maat_reference: '111111', claim_id: subject.id)
      create(:defendant, maat_reference: '222222', claim_id: subject.id)
      create(:defendant, maat_reference: '333333', claim_id: other_claim.id)
      subject.reload
      other_claim.reload
    end

    it 'finds the claim by MAAT reference "111111"' do
      expect(Claim.find_by_maat_reference('111111')).to eq([subject])
    end

    it 'finds the claim by MAAT reference "222222"' do
      expect(Claim.find_by_maat_reference('222222')).to eq([subject])
    end

    it 'finds the claim by MAAT reference "333333"' do
      expect(Claim.find_by_maat_reference('333333')).to eq([other_claim])
    end

    it 'does not find a claim with MAAT reference "444444"' do
      expect(Claim.find_by_maat_reference('444444')).to be_empty
    end
  end

  describe '.find_by_defendant_name' do
    let!(:other_claim) { create(:claim) }
    let!(:current_advocate) { create(:advocate) }
    let!(:other_advocate) { create(:advocate, chamber: current_advocate.chamber ) }

    before do
      subject.advocate = current_advocate
      other_claim.advocate = other_advocate
      subject.save!
      other_claim.save!
      create(:defendant, first_name: 'Joe', middle_name: 'Herbie', last_name: 'Bloggs', claim: subject)
      create(:defendant, first_name: 'Joe', middle_name: 'Herbie', last_name: 'Bloggs', claim: other_claim)
      create(:defendant, first_name: 'Herbie', last_name: 'Hart', claim: other_claim)
      subject.reload
      other_claim.reload
    end

    it 'finds all claims involving specified defendant' do
      expect(Claim.find_by_defendant_name('Joe Bloggs').count).to eq(2)
    end

    it 'finds claim involving other specified defendant' do
      expect(Claim.find_by_defendant_name('Hart')).to eq([other_claim])
    end

    it 'does not find claims involving non-existent defendant"' do
      expect(Claim.find_by_defendant_name('Foo Bar')).to be_empty
    end

  end

  describe '.find_by_advocate_name' do
    let!(:other_claim) { create(:claim) }

    before do
      subject.advocate = create(:advocate)
      other_claim.advocate = create(:advocate)
      subject.advocate.user.first_name = 'John'
      subject.advocate.user.last_name = 'Smith'
      subject.advocate.user.save!

      subject.save!

      other_claim.advocate.user.first_name = 'Bob'
      other_claim.advocate.user.last_name = 'Hoskins'
      other_claim.advocate.user.save!

      other_claim.save!
    end

    it 'finds the claim by advocate name "John Smith"' do
      expect(Claim.find_by_advocate_name('John Smith')).to eq([subject])
    end

    it 'finds the claim by advocate name "Bob Hoskins"' do
      expect(Claim.find_by_advocate_name('Bob Hoskins')).to eq([other_claim])
    end

    it 'does not find a claim with advocate name "Foo Bar"' do
      expect(Claim.find_by_advocate_name('Foo Bar')).to be_empty
    end
  end

  context 'fees total' do
    let(:fee_type) { create(:fee_type) }

    before do
      create(:fee, fee_type: fee_type, claim_id: subject.id, rate: 5.0, quantity: 1)
      create(:fee, fee_type: fee_type, claim_id: subject.id, rate: 2.0, quantity: 1)
      create(:fee, fee_type: fee_type, claim_id: subject.id, rate: 1.0, quantity: 1)
      subject.reload
    end

    describe '#calculate_fees_total' do
      it 'calculates the fees total' do
        expect(subject.calculate_fees_total).to eq(8.0)
      end
    end

    describe '#update_fees_total' do
      it 'stores the fees total' do
        expect(subject.fees_total).to eq(8.0)
      end

      it 'updates the fees total' do
        create(:fee, fee_type: fee_type, claim_id: subject.id, rate: 2.0, quantity: 1)
        subject.reload
        expect(subject.fees_total).to eq(10.0)
      end

      it 'updates total when claim fee destroyed' do
        fee = subject.fees.first
        fee.destroy
        subject.reload
        expect(subject.fees_total).to eq(3.0)
      end
    end
  end

  context 'expenses total' do
    before do
      create(:expense, claim_id: subject.id, rate: 3.5, quantity: 1)
      create(:expense, claim_id: subject.id, rate: 1.0, quantity: 1)
      create(:expense, claim_id: subject.id, rate: 142.0, quantity: 1)
      subject.reload
    end

    describe '#calculate_expenses_total' do
      it 'calculates expenses total' do
        expect(subject.calculate_expenses_total).to eq(146.5)
      end
    end

    describe '#update_expenses_total' do
      it 'stores the expenses total' do
        expect(subject.expenses_total).to eq(146.5)
      end

      it 'updates the expenses total' do
        create(:expense, claim_id: subject.id, rate: 3.0, quantity: 1)
        subject.reload
        expect(subject.expenses_total).to eq(149.5)
      end

      it 'updates expenses total when expense destroyed' do
        expense = subject.expenses.first
        expense.destroy
        subject.reload
        expect(subject.expenses_total).to eq(143.0)
      end
    end
  end

  context 'total' do
    let(:fee_type) { create(:fee_type) }

    before do
      create(:fee, fee_type: fee_type, claim_id: subject.id, rate: 5.0, quantity: 1)
      create(:fee, fee_type: fee_type, claim_id: subject.id, rate: 2.0, quantity: 1)
      create(:fee, fee_type: fee_type, claim_id: subject.id, rate: 1.0, quantity: 1)

      create(:expense, claim_id: subject.id, rate: 3.5, quantity: 1)
      create(:expense, claim_id: subject.id, rate: 1.0, quantity: 1)
      create(:expense, claim_id: subject.id, rate: 142.0, quantity: 1)
      subject.reload
    end

    describe '#calculate_total' do
      it 'calculates the fees and expenses total' do
        expect(subject.calculate_total).to eq(154.5)
      end
    end

    describe '#update_total' do
      it 'updates the total' do
        create(:expense, claim_id: subject.id, rate: 3.0, quantity: 1)
        create(:fee, fee_type: fee_type, claim_id: subject.id, rate: 1.0, quantity: 1)
        subject.reload
        expect(subject.total).to eq(158.5)
      end

      it 'updates total when expense/fee destroyed' do
        expense = subject.expenses.first
        fee = subject.fees.first
        expense.destroy
        fee.destroy
        subject.reload
        expect(subject.total).to eq(146.0)
      end
    end
  end

  describe '#description' do
    let(:expected_output) do
      "#{subject.court.code}-#{subject.case_number} #{subject.advocate.name} (#{subject.advocate.chamber.name})"
    end

    it 'returns a formatted description string containing claim information' do
      expect(subject.description).to eq(expected_output)
    end
  end

  describe '#editable?' do
    let(:draft) { create(:claim) }
    let(:submitted) { create(:submitted_claim) }
    let(:allocated) { create(:allocated_claim) }

    it 'should be editable when draft' do
      expect(draft.editable?).to eq(true)
    end

    it 'should be editable when submitted' do
      expect(submitted.editable?).to eq(true)
    end

    it 'should not be editable when allocated' do
      expect(allocated.editable?).to eq(false)
    end
  end

  describe '#state_for_form' do
    it 'should return the state' do
      expect(subject).to receive(:state)
      subject.state_for_form
    end
  end

  describe '#state_for_form=' do
    it 'should call pay! if paid' do
      expect(subject).to receive(:pay!)
      subject.state_for_form = 'paid'
    end
    it 'should call pay_part! if part_paid' do
      expect(subject).to receive(:pay_part!)
      subject.state_for_form = 'part_paid'
    end
    it 'should call reject! if rejected' do
      expect(subject).to receive(:reject!)
      subject.state_for_form = 'rejected'
    end
    it 'should call refuse! if refused' do
      expect(subject).to receive(:refuse!)
      subject.state_for_form = 'refused'
    end
    it 'should call await_info_from_court! if awaiting_info_from_court' do
      expect(subject).to receive(:await_info_from_court!)
      subject.state_for_form = 'awaiting_info_from_court'
    end
    it 'should raise an exception if anything else' do
      expect{
        subject.state_for_form = 'allocated'
      }.to raise_error ArgumentError, 'Only the following state transitions are allowed from form input: allocated to paid, part_paid, rejected or refused'
    end
  end

  describe 'STATES_FOR_FORM' do
    it "should have constant values" do
    expect(Claim::STATES_FOR_FORM).to eql({part_paid: "Part paid",
                                          paid: "Paid in full",
                                          rejected: "Rejected",
                                          refused: "Refused",
                                          awaiting_info_from_court: "Awaiting info from court"
                                         })
  end

  end

end
