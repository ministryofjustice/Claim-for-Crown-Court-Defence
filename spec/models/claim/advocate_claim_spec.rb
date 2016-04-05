#
# == Schema Information
#
# Table name: claims
#
#  id                       :integer          not null, primary key
#  additional_information   :text
#  apply_vat                :boolean
#  state                    :string
#  last_submitted_at        :datetime
#  case_number              :string
#  advocate_category        :string
#  first_day_of_trial       :date
#  estimated_trial_length   :integer          default(0)
#  actual_trial_length      :integer          default(0)
#  fees_total               :decimal(, )      default(0.0)
#  expenses_total           :decimal(, )      default(0.0)
#  total                    :decimal(, )      default(0.0)
#  external_user_id         :integer
#  court_id                 :integer
#  offence_id               :integer
#  created_at               :datetime
#  updated_at               :datetime
#  valid_until              :datetime
#  cms_number               :string
#  authorised_at            :datetime
#  creator_id               :integer
#  evidence_notes           :text
#  evidence_checklist_ids   :string
#  trial_concluded_at       :date
#  trial_fixed_notice_at    :date
#  trial_fixed_at           :date
#  trial_cracked_at         :date
#  trial_cracked_at_third   :string
#  source                   :string
#  vat_amount               :decimal(, )      default(0.0)
#  uuid                     :uuid
#  case_type_id             :integer
#  form_id                  :string
#  original_submission_date :datetime
#  retrial_started_at       :date
#  retrial_estimated_length :integer          default(0)
#  retrial_actual_length    :integer          default(0)
#  retrial_concluded_at     :date
#  type                     :string
#  disbursements_total      :decimal(, )      default(0.0)
#  case_concluded_at        :date
#

require 'rails_helper'
require 'custom_matchers'

RSpec.describe Claim::AdvocateClaim, type: :model do
  include DatabaseHousekeeping

  it { should belong_to(:external_user) }
  it { should belong_to(:creator).class_name('ExternalUser').with_foreign_key('creator_id') }
  it { should delegate_method(:provider_id).to(:creator) }

  it { should belong_to(:court) }
  it { should belong_to(:offence) }
  it { should have_many(:fees) }
  it { should have_many(:fee_types) }
  it { should have_many(:expenses) }
  it { should have_many(:defendants) }
  it { should have_many(:documents) }
  it { should have_many(:messages) }
  it { should have_many(:case_worker_claims) }
  it { should have_many(:case_workers) }
  it { should have_many(:claim_state_transitions) }

  describe 'validates external user and creator with same provider' do
    let(:provider) { create(:provider) }
    let(:other_provider) { create(:provider) }
    let(:external_user) { create(:external_user, provider: provider) }
    let(:same_provider_external_user) { create(:external_user, provider: provider) }
    let(:other_provider_external_user) { create(:external_user, provider: other_provider) }

    it 'should raise error message if no external user is specified' do
      subject.external_user_id = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:external_user]).to eq( ['blank_advocate'] )
    end

    it 'should be valid with the same external_user_id and creator_id' do
      subject.external_user_id = external_user.id
      subject.creator_id = external_user.id
      subject.save
      expect(subject.reload.errors.messages[:external_user]).to be_nil
    end

    it 'should be valid with different external_user_id and creator_id but same provider' do
      subject.external_user_id = external_user.id
      subject.creator_id = same_provider_external_user.id
      subject.save
      expect(subject.reload.errors.messages[:external_user]).to be_nil
    end

    it 'should not be valid when the external_user and creator are with the same provider' do
      subject.external_user_id = external_user.id
      subject.creator_id = other_provider_external_user.id
      subject.save
      expect(subject.reload.errors.messages[:external_user]).to eq(['Creator and advocate must belong to the same provider'])
    end
  end

  describe 'validate external user is advocate role' do
    let(:claim)   { build :unpersisted_claim }

    it 'validates external user with advocate role' do
      expect(claim.external_user.is?(:advocate)).to be true
      expect(claim).to be_valid
    end

    it 'rejects external user without advocate role' do
      claim.external_user = build :external_user, :litigator, provider: claim.creator.provider
      expect(claim).not_to be_valid
      expect(claim.errors[:external_user]).to include('must have advocate role')
    end
  end

  describe '#eligible_case_types' do
    it 'should return all agfs top level case types and non lgfs only and none that are children' do
      claim = build :unpersisted_claim
      ct_top_level_both = create :case_type, name: "Top Level Case Type for both"
      ct_top_level_agfs = create :case_type, roles: %w{ agfs }, name: "Top Level Case type for AGFS"
      ct_top_level_lgfs = create :case_type, roles: %w{ lgfs }, name: "Top Level Case type for LGFS"
      ct_child_both = create :child_case_type, roles: %w{ agfs lgfs }, name: "Child of Top level for both both", parent: ct_top_level_both
      ct_child_agfs = create :child_case_type, roles: %w{ agfs }, name: "Child of Top level for both AGFS only", parent: ct_top_level_both

      expect(claim.eligible_case_types.map(&:id).sort).to eq( [ct_top_level_both.id, ct_top_level_agfs.id].sort )
    end
  end

  context 'eligible misc and fixed fee types' do
    before(:all) do
      @bft1 = create :basic_fee_type
      @bft2 = create :basic_fee_type, :lgfs
      @mft1 = create :misc_fee_type
      @mft2 = create :misc_fee_type, :lgfs
      @fft1 = create :fixed_fee_type
      @fft2 = create :fixed_fee_type, :lgfs
      @claim = build :unpersisted_claim
    end

    after(:all) do
      clean_database
    end

    describe '#eligible_basic_fee_types' do
      it 'returns only basic fee types for AGFS' do
        expect(@claim.eligible_basic_fee_types).to eq([@bft1])
      end
    end

    describe '#eligible_misc_fee_types' do
      it 'returns only misc fee types for AGFS' do
        expect(@claim.eligible_misc_fee_types).to eq([@mft1])
      end
    end

    describe '#eligible_fixed_fee_types' do
      it 'returns only fixed fee types for AGFS' do
        expect(@claim.eligible_fixed_fee_types).to eq([@fft1])
      end
    end
  end

  context 'State Machine meta states magic methods' do
    let(:claim)       { FactoryGirl.build :claim }
    let(:all_states)  { [  'allocated', 'archived_pending_delete',
                           'draft', 'authorised', 'part_authorised', 'refused', 'rejected', 'submitted' ] }

    context 'external_user_dashboard_draft?' do
      before(:each)     { allow(claim).to receive(:state).and_return('draft') }

      it 'should respond true in draft' do
        allow(claim).to receive(:state).and_return('draft')
        expect(claim.external_user_dashboard_draft?).to be true
      end

      it 'should respond false to anything else' do
        (all_states - ['draft']).each do |state|
          allow(claim).to receive(:state).and_return(state)
          expect(claim.external_user_dashboard_draft?).to be false
        end
      end
    end

    context 'external_user_dashboard_rejected?' do
      before(:each)     { allow(claim).to receive(:state).and_return('rejected') }
      it 'should respond true' do
        allow(claim).to receive(:state).and_return('rejected')
        expect(claim.external_user_dashboard_rejected?).to be true
      end

      it 'should respond false to anything else' do
        (all_states - ['rejected']).each do |state|
          allow(claim).to receive(:state).and_return(state)
          expect(claim.external_user_dashboard_rejected?).to be false
        end
      end
    end

    context 'external_user_dashboard_submitted?' do
      it 'should respond true' do
        [ 'allocated', 'submitted' ].each do |claim_state|
          allow(claim).to receive(:state).and_return(claim_state)
          expect(claim.external_user_dashboard_submitted?).to be true
        end
      end

      it 'should respond false to anything else' do
        (all_states - [ 'allocated', 'submitted' ]).each do |claim_state|
          allow(claim).to receive(:state).and_return(claim_state)
          expect(claim.external_user_dashboard_submitted?).to be false
        end
      end
    end

    context 'external_user_dashboard_part_authorised' do
      it 'should respond true' do
        [ 'part_authorised' ].each do |state|
          allow(claim).to receive(:state).and_return(state)
          expect(claim.external_user_dashboard_part_authorised?).to be true
        end
      end

      it 'should respond false to anything else' do
        (all_states - [ 'part_authorised' ]).each do |claim_state|
          allow(claim).to receive(:state).and_return(claim_state)
          expect(claim.external_user_dashboard_part_authorised?).to be false
        end
      end
    end

    context 'external_user_dashboard_completed_states' do
      it 'should respond true' do
        [ 'refused', 'authorised' ].each do |state|
          allow(claim).to receive(:state).and_return(state)
          expect(claim.external_user_dashboard_completed?).to be true
        end
      end

      it 'should respond false to anything else' do
        (all_states - [ 'refused', 'authorised' ]).each do |claim_state|
          allow(claim).to receive(:state).and_return(claim_state)
          expect(claim.external_user_dashboard_completed?).to be false
        end
      end
    end

    context 'unrecognised state' do
      it 'should raise NoMethodError' do
        expect {
          claim.other_unknown_state?
        }.to raise_error NoMethodError, /undefined method `other_unknown_state\?'/
      end
    end
  end

  it { should accept_nested_attributes_for(:basic_fees) }
  it { should accept_nested_attributes_for(:fixed_fees) }
  it { should accept_nested_attributes_for(:misc_fees) }
  it { should accept_nested_attributes_for(:expenses) }
  it { should accept_nested_attributes_for(:defendants) }

  subject { create(:claim) }

  describe '.earliest_representation_order' do
    let(:claim)         { FactoryGirl.build :unpersisted_claim }
    let(:early_date)    { 2.years.ago.to_date }

    before(:each) do
      # add a second defendant
      claim.defendants << FactoryGirl.create(:defendant, claim: claim)

      # add a second rep order to the first defendant
      claim.defendants.first.representation_orders << FactoryGirl.create(:representation_order, representation_order_date: early_date)
    end

    it 'should pick the earliest reporder' do
      # given a claim with two defendants and three rep orders
      expect(claim.defendants).to have_exactly(2).items
      expect(claim.representation_orders).to have_exactly(3).items

      # when I get the earliest rep order
      rep_order = claim.earliest_representation_order

      # it should have a date of
      expect(rep_order.representation_order_date).to eq early_date
    end
  end

  describe '.is_allocated_to_case_worker' do
    let(:case_worker_1)        { FactoryGirl.create :case_worker }
    let(:case_worker_2)        { FactoryGirl.create :case_worker }

    it 'should return true if allocated to the specified case_worker' do
      subject.case_workers << case_worker_1
      subject.case_workers << case_worker_2
      expect(subject.is_allocated_to_case_worker?(case_worker_1)).to be true
    end

    it 'should return false if not allocated to the specified case_worker' do
      subject.case_workers << case_worker_1
      expect(subject.is_allocated_to_case_worker?(case_worker_2)).to be false
    end
  end

  describe '.update_model_and_transition_state' do
    it 'should update the model then transition state to prevent state transition validation errors' do
      # given
      claim = FactoryGirl.create :allocated_claim
      claim.assessment = Assessment.new(claim: claim)
      claim_params = {
        "state_for_form"=>"part_authorised",
        "assessment_attributes" => {
          "id" => claim.assessment.id,
          "fees" => "66.22",
          "expenses" => "22.33"
        },
        "additional_information"=>""}

      # when
      claim.update_model_and_transition_state(claim_params)
      #then
      expect(claim.reload.state).to eq 'part_authorised'
    end

    it 'should not transition when "state_for_form" is the same as the claim\'s state' do
      claim = FactoryGirl.create :authorised_claim
      claim.assessment = Assessment.new(claim: claim)
      claim_params = {
        "state_for_form"=>"authorised",
        'assessment_attributes' => {
          "id" => claim.assessment.id,
          "fees"=>"88.55",
          'expenses' => '0.00'
        },
        "additional_information"=>""}
      claim.update_model_and_transition_state(claim_params)
      expect(claim.reload.state).to eq('authorised')
    end

    it 'should not transition when "state_for_form" is blank' do
      claim = FactoryGirl.create :authorised_claim
      claim.assessment = Assessment.new(claim: claim)
      claim_params = {
        "state_for_form"=>"",
        'assessment_attributes' => {
          "id" => claim.assessment.id,
          "fees"=>"44.55",
          'expenses' => '44.00'
        },
        "additional_information"=>""}
      claim.update_model_and_transition_state(claim_params)
      expect(claim.reload.state).to eq('authorised')
    end
  end

  context 'basic fees' do
    before(:each) do
      @bft1 = FactoryGirl.create :basic_fee_type,  description: 'ZZZZ', id: 1
      @mft1 = FactoryGirl.create :misc_fee_type,   description: 'CCCC', id: 2
      @fft1 = FactoryGirl.create :fixed_fee_type,  description: 'DDDD', id: 3
      @bft2 = FactoryGirl.create :basic_fee_type,  description: 'AAAA', id: 4
      @mft2 = FactoryGirl.create :misc_fee_type,   description: 'EEEE', id: 5
      @bft3 = FactoryGirl.create :basic_fee_type,  description: 'BBBB', id: 6
    end

    describe '.instantiate_basic_fees (after_initialize callback)' do
      it 'should create an unpersisted basic fee record for every basic fee type, in fee_type_id order' do
        claim = FactoryGirl.build :claim
        expect(claim.basic_fees.size).to eq 3
        claim.basic_fees.each { |fee| expect(fee).to be_blank }
        expect(claim.basic_fees.map(&:fee_type_id).sort).to eq( [1, 4, 6])
      end

      it 'should create a persisted basic fee record for every basic fee type in params plus blank basic fees for those not specified by params' do
        claim = Claim::AdvocateClaim.new(valid_params['claim'])
        claim.save
        claim.reload
        expect(claim.fees.size).to eq 3
        expect(claim.basic_fees.map(&:fee_type_id).sort).to eq( [1, 4, 6])
        expect(claim.basic_fees.find_by(fee_type_id: 1).amount).to eq 450
        expect(claim.basic_fees.find_by(fee_type_id: 4).amount).to eq 0
        expect(claim.basic_fees.find_by(fee_type_id: 6).amount).to eq 0
      end
    end

    describe '.basic_fees' do
      it 'should return a fee for every basic fee sorted in order of fee type id (i.e. seeded data order)' do
        claim = FactoryGirl.build :claim
        expect(claim.basic_fees.map(&:fee_type_id).sort).to eq( [1, 4, 6])
      end
    end
  end

  describe '.search' do
    let!(:other_claim) { create(:claim) }
    let(:states) { nil }

    it 'finds only claims with states that match dashboard displayable states' do
      sql = Claim::AdvocateClaim.search('%',states,:advocate_name, :defendant_name, :maat_reference, :case_worker_name_or_email).to_sql
      state_in_list_clause = Claims::StateMachine.dashboard_displayable_states.map{ |s| "\'#{s}\'"}.join(', ')
      expect(sql.downcase).to include(' "claims"."state" in (' << state_in_list_clause << ')')
    end

    context 'find by MAAT reference' do

      let(:search_options) { :maat_reference }

      before do
        create :defendant, claim: subject, representation_orders: [ FactoryGirl.create(:representation_order, maat_reference: '111111') ]
        create :defendant, claim: subject, representation_orders: [ FactoryGirl.create(:representation_order, maat_reference: '222222') ]
        create :defendant, claim: other_claim, representation_orders: [ FactoryGirl.create(:representation_order, maat_reference: '333333') ]
        subject.reload
        other_claim.reload
      end

      it 'finds the claim by MAAT reference "111111"' do
        expect(Claim::AdvocateClaim.search('111111', states, search_options)).to eq([subject])
      end

      it 'finds the claim by MAAT reference "222222"' do
        expect(Claim::AdvocateClaim.search('222222', states, search_options)).to eq([subject])
      end

      it 'finds the claim by MAAT reference "333333"' do
        expect(Claim::AdvocateClaim.search('333333', states, search_options)).to eq([other_claim])
      end

      it 'does not find a claim with MAAT reference "444444"' do
        expect(Claim::AdvocateClaim.search('444444', states, search_options)).to be_empty
      end
    end

    context 'find by Defendant name' do

      let!(:current_external_user) { create(:external_user) }
      let!(:other_external_user)   { create(:external_user, provider: current_external_user.provider ) }
      let(:search_options)    { :defendant_name }

      before do
        subject.external_user = current_external_user
        subject.creator = current_external_user
        other_claim.external_user = other_external_user
        other_claim.creator = other_external_user
        subject.save!
        other_claim.save!
        create(:defendant, first_name: 'Joe', last_name: 'Bloggs', claim: subject)
        create(:defendant, first_name: 'Joe', last_name: 'Bloggs', claim: other_claim)
        create(:defendant, first_name: 'Herbie', last_name: 'Hart', claim: other_claim)
        subject.reload
        other_claim.reload
      end

      it 'finds all claims involving specified defendant' do
        expect(Claim::AdvocateClaim.search('Joe Bloggs', states, search_options).count).to eq(2)
      end

      it 'finds claim involving other specified defendant' do
        expect(Claim::AdvocateClaim.search('Hart',states, search_options)).to eq([other_claim])
      end

      it 'does not find claims involving non-existent defendant"' do
        expect(Claim::AdvocateClaim.search('Foo Bar',states, search_options)).to be_empty
      end
    end

    context 'find by Advocate name' do

      let(:search_options) { :advocate_name }

      before do
        subject.external_user = create(:external_user)
        subject.creator = subject.external_user
        other_claim.external_user = create(:external_user)
        other_claim.creator = other_claim.external_user
        subject.external_user.user.first_name = 'John'
        subject.external_user.user.last_name = 'Smith'
        subject.external_user.user.save!

        subject.save!

        other_claim.external_user.user.first_name = 'Bob'
        other_claim.external_user.user.last_name = 'Hoskins'
        other_claim.external_user.user.save!

        other_claim.save!
      end

      it 'finds the claim by advocate name "John Smith"' do
        expect(Claim::AdvocateClaim.search('John Smith', states, search_options)).to eq([subject])
      end

      it 'finds the claim by advocate name "Bob Hoskins"' do
        expect(Claim::AdvocateClaim.search('Bob Hoskins', states, search_options)).to eq([other_claim])
      end

      it 'does not find a claim with advocate name "Foo Bar"' do
        expect(Claim::AdvocateClaim.search('Foo Bar', states, search_options)).to be_empty
      end
    end

    context 'find claims by state' do
      let(:search_options) { :advocate_name }

      before do
        bob_hoskins = create(:user, first_name: 'Bob', last_name: 'Hoskins')
        bob_hoskins.save!
        adv_bob_hoskins = create(:external_user, user: bob_hoskins)
        adv_bob_hoskins.save!
        create_list(:archived_pending_delete_claim,   2,  external_user: adv_bob_hoskins)
        create_list(:authorised_claim,                      2,  external_user: adv_bob_hoskins)
        create(:allocated_claim,                          external_user: adv_bob_hoskins)
      end

      it 'finds only claims of the single state specified' do
        expect(Claim::AdvocateClaim.search('Bob Hoskins',:archived_pending_delete, search_options).count).to eql 2
      end

      it 'finds only claims of the multiple states specified' do
        expect(Claim::AdvocateClaim.search('Bob Hoskins',[:archived_pending_delete, :authorised], search_options).count).to eql 4
      end

      it 'defaults to finding claims of dashboard_displayable_states' do
        expect(Claim::AdvocateClaim.search('Bob Hoskins', nil, search_options).count).to eql 3
      end

    end


    context 'find by advocate and defendant' do

      let!(:current_external_user) { create(:external_user) }
      let!(:other_external_user)   { create(:external_user, provider: current_external_user.provider ) }
      let(:search_options)    { [:advocate_name, :defendant_name] }

      before do

        subject.external_user = current_external_user
        subject.creator = current_external_user
        subject.external_user.user.first_name = 'Fred'
        subject.external_user.user.last_name = 'Bloggs'
        subject.external_user.user.save!
        create(:defendant, first_name: 'Joexx', last_name: 'Bloggs', claim: subject)
        subject.save!

        other_claim.external_user = other_external_user
        other_claim.creator = other_external_user
        other_claim.external_user.user.first_name = 'Johncz'
        other_claim.external_user.user.last_name = 'Hoskins'
        other_claim.external_user.user.save!
        create(:defendant, first_name: 'Fred', last_name: 'Hoskins', claim: other_claim)
        other_claim.save!

      end

      it 'finds claims with either advocate or defendant matching names' do
        expect(Claim::AdvocateClaim.search('Bloggs', states, *search_options)).to eq([subject])
        expect(Claim::AdvocateClaim.search('Hoskins',states, *search_options)).to eq([other_claim])
        expect(Claim::AdvocateClaim.search('Fred',   states, *search_options).count).to eq(2) #advocate and defendant of name
        expect(Claim::AdvocateClaim.search('Johncz',   states, *search_options).count).to eq(1) #advocate only search
        expect(Claim::AdvocateClaim.search('Joexx',  states, *search_options).count).to eq(1) #defendant only search
      end

      it 'does not find claims that do not match the name' do
        expect(Claim::AdvocateClaim.search('Xavierxxxx', states, :advocate_name, :defendant_name).count).to eq(0)
      end

    end

    context 'find by case worker name or email' do
      let!(:case_worker) { create(:case_worker) }
      let!(:other_case_worker) { create(:case_worker) }
      let(:search_options) { :case_worker_name_or_email }

      before do
        subject.case_workers << case_worker
        other_claim.case_workers << other_case_worker
      end

      it 'finds the claim by case_worker name' do
        expect(Claim::AdvocateClaim.search(case_worker.name, states, search_options)).to eq([subject])
      end

      it 'finds the other claim by case worker name' do
        expect(Claim::AdvocateClaim.search(other_case_worker.name, states, search_options)).to eq([other_claim])
      end

      it 'does not find a claim with a non existent case worker' do
        expect(Claim::AdvocateClaim.search('Foo Bar', states, search_options)).to be_empty
      end
    end

    context 'with invalid option' do
      it 'raises error for invalid option' do
        expect{
          Claim::AdvocateClaim.search('foo', states, :case_worker_name_or_email, :foo)
        }.to raise_error(/Invalid search option/)
      end
    end

    context 'with invalid state' do
      it 'raises error for invalid option' do
        expect{
          Claim::AdvocateClaim.search('foo',:rubbish_state, :case_worker_name_or_email)
        }.to raise_error(/Invalid state, rubbish_state, specified/)
      end
    end

  end

  context 'fees total' do
    let(:basic_fee)           { create(:basic_fee_type) }
    let(:fixed_fee)           { create(:fixed_fee_type) }
    let(:misc_fee)            { create(:misc_fee_type)  }

    before do
      subject.fees.destroy_all

      create(:basic_fee, claim_id: subject.id, rate: 4.00)
      create(:basic_fee, claim_id: subject.id, rate: 3.00)
      create(:fixed_fee, claim_id: subject.id, rate: 0.50)
      create(:misc_fee, claim_id: subject.id, rate: 0.50)
      subject.reload
    end

    describe '#calculate_fees_total' do
      it 'calculates the fees total' do
        expect(subject.calculate_fees_total).to eq(8.0)
      end

      it 'calculates fee totals by category too' do
        expect(subject.calculate_fees_total(:basic)).to eq(7.0)
        expect(subject.calculate_fees_total(:misc)).to eq(0.5)
        expect(subject.calculate_fees_total(:fixed)).to eq(0.5)
      end
    end

    describe '#update_fees_total' do
      it 'stores the fees total' do
        expect(subject.fees_total).to eq(8.0)
      end

      it 'updates the fees total' do
        create(:basic_fee, claim_id: subject.id, rate: 2.00)
        subject.reload
        expect(subject.fees_total).to eq(10.0)
      end

      it 'updates total when claim fee destroyed' do
        fee = subject.fees.first
        fee.destroy
        subject.reload
        expect(subject.fees_total).to eq(4.0)
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
    let(:fee_type) { create(:misc_fee_type) }

    before do
      subject.fees.destroy_all
      create(:misc_fee, claim_id: subject.id, rate: 3.00)
      create(:misc_fee, claim_id: subject.id, rate: 2.00)
      create(:misc_fee, claim_id: subject.id, rate: 1.00)

      create(:expense, claim_id: subject.id, rate: 3.5, quantity: 1)
      create(:expense, claim_id: subject.id, rate: 1.0, quantity: 1)
      create(:expense, claim_id: subject.id, rate: 142.0, quantity: 1)
      subject.reload
    end

    describe '#calculate_total' do
      it 'calculates the fees and expenses total' do
        expect(subject.calculate_total).to eq(152.5)
      end
    end

    describe '#update_total' do
      it 'updates the total' do
        create(:expense, claim_id: subject.id, rate: 3.0, quantity: 1)
        create(:misc_fee, claim_id: subject.id, rate: 0.5)
        subject.reload
        expect(subject.total).to eq(156.00)
      end

      it 'updates total when expense/fee destroyed' do
        expense = subject.expenses.first
        fee = subject.fees.first
        expense.destroy
        fee.destroy
        subject.reload
        expect(subject.total).to eq(146.00)
      end
    end
  end

  describe '#editable?' do
    let(:draft) { create(:claim) }
    let(:submitted) { create(:submitted_claim) }
    let(:allocated) { create(:allocated_claim) }

    it 'should be editable when draft' do
      expect(draft.editable?).to eq(true)
    end

    it 'should not be editable when submitted' do
      expect(submitted.editable?).to eq(false)
    end

    it 'should not be editable when allocated' do
      expect(allocated.editable?).to eq(false)
    end
  end

  describe '#archivable?' do
    let(:claim) { create(:claim) }

    it 'should not be archivable from states: allocated, archived_pending_delete, awaiting_written_reasons, draft, redetermination' do
      %w( allocated awaiting_written_reasons draft redetermination ).each do |state|
        allow(claim).to receive(:state).and_return(state)
        expect(claim.archivable?).to eq(false)
      end
    end

    it 'should be archivable from states: refused, rejected, part authorised, authorised' do
      %w( refused rejected part_authorised authorised ).each do |state|
        allow(claim).to receive(:state).and_return(state)
        expect(claim.archivable?).to eq(true)
      end
    end
  end

  describe '#validation_required?' do

    let(:claim) { FactoryGirl.create(:claim, source: 'web') }

    context 'should return false for' do
      it 'draft claims submited by web app' do
        expect(claim.validation_required?).to eq false
      end

      it 'draft claims submitted by json importer' do
        claim.source = 'json_import'
        expect(claim.validation_required?).to eq false
      end

      it 'archived_pending_delete claims' do
        claim = create(:archived_pending_delete_claim)
        expect(claim.validation_required?).to eq false
      end
    end

    context 'should return true for' do
      it 'draft claims submitted by the API' do
        claim.source = 'api'
        expect(claim.validation_required?).to eq true
      end

      it 'claims in any state other than draft or archived_pending_delete' do
        states = Claim::AdvocateClaim.state_machine.states.map(&:name)
        states = states.map { |s| if not [:draft, :archived_pending_delete].include?(s) then s; end; }.compact
        states.each do | state |
          claim.state = state
          expect(claim.validation_required?).to eq true
        end
      end
    end

  end

  describe '#transition_state' do
    it 'should call authorise! if authorised' do
      expect(subject).to receive(:authorise!)
      subject.transition_state('authorised')
    end
    it 'should call authorise_part! if part_authorised' do
      expect(subject).to receive(:authorise_part!)
      subject.transition_state('part_authorised')
    end
    it 'should call reject! if rejected' do
      expect(subject).to receive(:reject!)
      subject.transition_state('rejected')
    end
    it 'should call refuse! if refused' do
      expect(subject).to receive(:refuse!)
      subject.transition_state('refused')
    end
    it 'should call redetermine! if redetermination' do
      expect(subject).to receive(:redetermine!)
      subject.transition_state('redetermination')
    end
    it 'should raise an exception if anything else' do
      expect{
        subject.transition_state('allocated')
      }.to raise_error ArgumentError, 'Only the following state transitions are allowed from form input: allocated to authorised, part_authorised, rejected or refused, part_authorised or refused to redetermination'
    end
  end


  describe 'allocate claim when assigning to case worker' do
    subject { create(:submitted_claim) }
    let(:case_worker) { create(:case_worker) }

    it 'moves to "allocated" state when assigned to case worker' do
      subject.case_workers << case_worker
      expect(subject.reload).to be_allocated
    end
  end

  describe 'moves to "submitted" state when case worker removed' do
    subject { create(:submitted_claim) }
    let(:case_worker) { create(:case_worker) }
    let(:other_case_worker) { create(:case_worker) }

    before do
      case_worker.claims << subject
      other_case_worker.claims << subject
      subject.reload
    end

    it 'should be "allocated"' do
      expect(subject).to be_allocated
    end

    context 'when case worker unassigned and other case workers remain' do
      it 'should be "allocated"' do
        case_worker.claims.destroy(subject)
        expect(subject.reload).to be_allocated
      end
    end

    context 'when all case workers unassigned' do
      it 'should be "submitted"' do
        case_worker.claims.destroy(subject)
        other_case_worker.claims.destroy(subject)
        expect(subject.reload).to be_submitted
      end
    end
  end

  describe '#has_authorised_state?' do
    let(:claim) { create(:draft_claim) }

    def expect_has_authorised_state_to_be(bool)
     expect(claim.has_authorised_state?).to eql(bool)
    end

    it 'should return false for draft, submitted, allocated, and rejected claims' do
     expect_has_authorised_state_to_be false
     claim.submit
     expect_has_authorised_state_to_be false
     claim.allocate
     expect_has_authorised_state_to_be false
     claim.reject
     expect_has_authorised_state_to_be false
    end

    it 'should return true for part_authorised, authorised claims' do
     claim.submit
     claim.allocate
     claim.assessment.update(fees: 30.01, expenses: 70.00)
     claim.authorise_part
     expect_has_authorised_state_to_be true
     claim.authorise
     expect_has_authorised_state_to_be true
    end
  end

  describe 'Case type scopes' do
    before(:all) do
      @case_types = load("#{Rails.root}/db/seeds/case_types.rb")
      @trials = create_list(:submitted_claim, 2, case_type: CaseType.by_type('Trial'))
      @retrials = create_list(:submitted_claim, 2, case_type: CaseType.by_type('Retrial'))
      @cracked_trials = create_list(:submitted_claim, 2, case_type: CaseType.by_type('Cracked Trial'))
      @cracked_retrials = create_list(:submitted_claim, 2, case_type: CaseType.by_type('Cracked before retrial'))
      @guilty_pleas = create_list(:submitted_claim, 2, case_type: CaseType.by_type('Guilty plea'))
      @discontinuances = create_list(:submitted_claim, 2, case_type: CaseType.by_type('Discontinuance'))
    end

    after(:all) do
      clean_database
    end

    describe '.trial' do
      it 'returns trials and retrials' do
        expect(Claim::AdvocateClaim.trial).to match_array(@trials + @retrials)
      end
    end

    describe '.cracked' do
      it 'returns cracked trials and retrials' do
        expect(Claim::AdvocateClaim.cracked).to match_array(@cracked_trials + @cracked_retrials)
      end
    end

    describe '.guilty_plea' do
      it 'returns guilty pleas and discontinuances' do
        expect(Claim::AdvocateClaim.guilty_plea).to match_array(@guilty_pleas + @discontinuances)
      end
    end
  end

  describe '#fixed_fees' do
    let(:ct_fixed_1)          { FactoryGirl.create :case_type, :fixed_fee }
    let(:ct_fixed_2)          { FactoryGirl.create :case_type, :fixed_fee }
    let(:ct_basic_1)          { FactoryGirl.create :case_type }
    let(:ct_basic_2)          { FactoryGirl.create :case_type }

    it 'should only return claims with fixed fee case types' do
      claim_1 = FactoryGirl.create :claim, case_type_id: ct_fixed_1.id
      claim_2 = FactoryGirl.create :claim, case_type_id: ct_fixed_2.id
      claim_3 = FactoryGirl.create :claim, case_type_id: ct_basic_1.id
      claim_4 = FactoryGirl.create :claim, case_type_id: ct_basic_2.id
      expect(Claim::AdvocateClaim.fixed_fee.count).to eq 2
      expect(Claim::AdvocateClaim.fixed_fee).to include claim_1
      expect(Claim::AdvocateClaim.fixed_fee).to include claim_2
    end
  end


  describe '.total_greater_than_or_equal_to' do
    let(:not_greater_than_400) do
      claims = []

      [100, 200, 399, 2].each do |value|
        claims << create(:submitted_claim, total: value)
      end

      claims
    end

    let(:greater_than_400) do
      claims = []

      [400, 10_000, 566, 1_000].each do |value|
        claim = create(:draft_claim)
        claim.fees << create(:misc_fee, rate: value, claim: claim)
        claims << claim
      end

      claims
    end

    it 'only returns claims with total value greater than the specified value' do
      expect(Claim::AdvocateClaim.total_greater_than_or_equal_to(400)).to match_array(greater_than_400)
    end
  end

  describe '.destroy_all_invalid_fee_types' do

    let(:claim_with_all_fee_types) do
      claim = FactoryGirl.create :draft_claim
      FactoryGirl.create(:basic_fee, :with_date_attended, claim: claim, rate: 9.99)
      FactoryGirl.create(:fixed_fee, :with_date_attended, claim: claim, rate: 9.99)
      claim.misc_fees.first.update(rate: 9.99)
      # FactoryGirl.create(:misc_fee, claim: claim, rate: 9.99)
      claim
    end

    it 'destroys fixed fees for non fixed case types' do
      claim_with_all_fee_types.save
      expect(claim_with_all_fee_types.basic_fees.map(&:amount).sum.to_f).to eql 9.99
      expect(claim_with_all_fee_types.fixed_fees.size).to eql 0
      expect(claim_with_all_fee_types.misc_fees.size).to eql 1
    end

    it 'clears basic fees and but does NOT destroy miscellaneous fees for Fixed Fee case types' do
      claim_with_all_fee_types.case_type = FactoryGirl.create :case_type, :fixed_fee
      claim_with_all_fee_types.save

      expect(claim_with_all_fee_types.basic_fees.size).to eql 1
      expect(claim_with_all_fee_types.basic_fees.map(&:amount).sum.to_f).to eql 0.0
      expect(claim_with_all_fee_types.fixed_fees.size).to eql 1
      expect(claim_with_all_fee_types.misc_fees.size).to eql 1
    end

    it 'destroys basic fee child relations explicitly (dates attended)' do
      expect(claim_with_all_fee_types.basic_fees.first.dates_attended.size).to eql 1
      claim_with_all_fee_types.case_type = FactoryGirl.create :case_type, :fixed_fee
      claim_with_all_fee_types.save
      expect(claim_with_all_fee_types.basic_fees.first.dates_attended.size).to eql 0
    end

  end

  describe 'sets the source field before saving a claim' do
    let(:claim)       { FactoryGirl.build :claim }

    it 'sets the source to web by default if unset' do
      expect(claim.save).to eq(true)
      expect(claim.source).to eq('web')
    end

    it 'does not change the source if set' do
      claim.source = 'api'
      expect(claim.save).to eq(true)
      expect(claim.source).to eq('api')
    end

  end

  describe 'provider type dependant methods' do
    let(:claim) { FactoryGirl.build :unpersisted_claim }

    describe 'for a chamber provider' do
      before :each do
        allow(claim.provider).to receive(:provider_type).and_return('chamber')
      end

      context '#vat_registered?' do
        it 'returns the value from the external user' do
          expect(claim.external_user).to receive(:vat_registered?)
          claim.vat_registered?
        end
      end

      context '#supplier_number' do
        it 'returns the value from the external user' do
          expect(claim.external_user).to receive(:supplier_number)
          claim.supplier_number
        end
      end
    end

    describe 'for a firm provider' do
      before :each do
        allow(claim.provider).to receive(:provider_type).and_return('firm')
      end

      context '#vat_registered?' do
        it 'returns the value from the provider' do
          expect(claim.provider).to receive(:vat_registered?)
          claim.vat_registered?
        end
      end

      context '#supplier_number' do
        it 'returns the value from the provider' do
          expect(claim.provider).to receive(:supplier_number)
          claim.supplier_number
        end
      end
    end

    describe 'for an unknown provider' do
      before :each do
        allow(claim.provider).to receive(:provider_type).and_return('zzzz')
      end

      context '#vat_registered?' do
        it 'raises an exception' do
          expect { claim.vat_registered? }.to raise_error
        end
      end

      context '#supplier_number' do
        it 'raises an exception' do
          expect { claim.supplier_number }.to raise_error
        end
      end
    end
  end

  describe 'calculate_vat' do

    it 'should calaculate vat on submission if vat is applied' do
      allow(VatRate).to receive(:vat_amount).and_return(10)
      claim = FactoryGirl.build :unpersisted_claim, total: 100
      claim.submit!
      expect(claim.vat_amount).to eq 20
    end

    it 'should zeroise the vat amount if vat is not applied' do
      claim = FactoryGirl.build :unpersisted_claim, fees_total: 1500.22, expenses_total: 500.00, vat_amount: 20, total: 100
      claim.external_user.vat_registered = false
      claim.submit!
      expect(claim.vat_amount).to eq 0.0
    end

  end

  describe '#opened_for_redetermination?' do
    let(:claim) { create(:claim) }

    before do
      claim.submit!
      claim.allocate!
      claim.refuse!
    end

    context 'when transitioned to redetermination' do
      before do
        claim.redetermine!
      end

      it 'should be in an redetermination state' do
        expect(claim).to be_redetermination
      end

      it 'should be open for redetermination' do
        expect(claim.opened_for_redetermination?).to eq(true)
      end
    end

    context 'when transitioned to redetermination and then allocated/deallocated/allocated' do
      before do
        claim.redetermine!
        claim.allocate!
        claim.deallocate!
        claim.allocate!
      end

      it 'should be open for redetermination' do
        expect(claim.opened_for_redetermination?).to be_truthy
      end
    end

    context 'when transitioned to redetermination and then refuse' do
      before do
        claim.redetermine!
        claim.allocate!
        claim.refuse!
      end

      it 'should be close for redetermination' do
        expect(claim.opened_for_redetermination?).to be_falsey
      end
    end

    describe 'submission_date' do
      it 'should set the submission date to the date it was set to state redetermination' do
        new_time = 36.hours.from_now
        Timecop.freeze new_time do
          claim.redetermine!
        end
        expect(claim.last_submitted_at).to be_within_seconds_of(new_time, 1)
      end
    end

    context 'when transitioned to allocated' do
      before do
        claim.redetermine!
        claim.allocate!
      end

      it 'should be in an allocated state' do
        expect(claim).to be_allocated
      end

      it 'should have been opened for redetermination before being allocated' do
        expect(claim.opened_for_redetermination?).to eq(true)
      end
    end
  end

  describe 'comma formatted inputs' do
    [:fees_total, :expenses_total, :total, :vat_amount].each do |attribute|
      it "converts input for #{attribute} by stripping commas out" do
        claim = build(:claim)
        claim.send("#{attribute}=", '12,321,111')
        expect(claim.send(attribute)).to eq(12321111)
      end
    end
  end

  describe '#written_reasons_outstanding?' do
    let(:claim) { create(:claim) }

    before do
      claim.submit!
      claim.allocate!
      claim.refuse!
    end

    context 'when transitioned to allocated' do
      before do
        claim.await_written_reasons!
        claim.allocate!
      end

      it 'should be in an allocated state' do
        expect(claim).to be_allocated
      end

      it 'should have written_reasons_outstanding before being allocated' do
        expect(claim.written_reasons_outstanding?).to eq(true)
      end
    end

    context 'when transitioned to awaiting_written_reasons and then allocated/deallocated/allocated' do
      before do
        claim.await_written_reasons!
        claim.allocate!
        claim.deallocate!
        claim.allocate!
      end

      it 'should be true' do
        expect(claim.written_reasons_outstanding?).to be_truthy
      end
    end

    context 'when transitioned to awaiting_written_reasons and then refuse' do
      before do
        claim.await_written_reasons!
        claim.allocate!
        claim.refuse!
      end

      it 'should not have written_reasons_outstanding' do
        expect(claim.written_reasons_outstanding?).to be_falsey
      end
    end
  end

  describe '#requested_redetermination?' do

    context 'allocated state from redetermination' do

      before(:each) do
        @claim = FactoryGirl.create :redetermination_claim
        @claim.allocate!
      end

      context 'no previous redetermination' do

        it 'should be true' do
          expect(@claim.redeterminations).to be_empty
          expect(@claim.requested_redetermination?).to be true
        end
      end

      context 'previous redetermination record created before state was changed to redetermination' do
        it 'should be true' do
          Timecop.freeze(Time.now - 2.hours) do
            @claim.redeterminations << Redetermination.new(fees: 12.12, expenses: 35.55)
            Timecop.freeze(Time.now ) do
              @claim.authorise_part!
              @claim.redetermine!
              @claim.allocate!
            end
            expect(@claim.requested_redetermination?).to be true
          end
        end
      end


      context 'latest redetermination created after transition to redetermination' do
        it 'should be false' do
          Timecop.freeze(Time.now + 10.minutes) do
            @claim.redeterminations << Redetermination.new(fees: 12.12, expenses: 35.55)
          end
          expect(@claim.requested_redetermination?).to be false
        end
      end

    end

    context 'allocated state where the previous state was not redetermination' do
      it 'should be false' do
        claim = FactoryGirl.create :allocated_claim
        expect(claim.requested_redetermination?).to be false
      end
    end

    context 'not allocated state' do
      it 'should be false' do
        claim = FactoryGirl.create :redetermination_claim
        expect(claim.requested_redetermination?).to be false
      end
    end

  end

  describe '#amount_assessed' do
    let!(:claim)  { create(:claim, state: 'draft') }

    context 'when VAT applied' do
      # VAT rate 17.5%

      before do
        claim.external_user.vat_registered = true
        claim.submit!
        claim.allocate!
        claim.assessment.update(fees: 1.55, expenses: 4.21)
        claim.authorise!
      end

      it 'should return the amount assessed from the last determination' do
        expect(claim.amount_assessed).to eq(6.77)
      end
    end

    context 'when VAT not applied' do

      before do
        claim.external_user.vat_registered = false
        claim.submit!
        claim.allocate!
        claim.assessment.update(fees: 1.55, expenses: 4.21)
        claim.authorise!
      end

      it 'should return the amount assessed from the last determination' do
        expect(claim.amount_assessed).to eq(5.76)
      end
    end
  end

  describe 'not saving the expenses model' do
    it 'should save the expenses model' do
      external_user = FactoryGirl.create :external_user
      expense_type = FactoryGirl.create :expense_type
      fee_type = FactoryGirl.create :basic_fee_type
      case_type = FactoryGirl.create :case_type
      court = FactoryGirl.create :court
      offence = FactoryGirl.create :offence

      params = {"claim"=>
        {"case_type_id"=>case_type.id,
         "trial_fixed_notice_at_dd"=>"",
         "trial_fixed_notice_at_mm"=>"",
         "trial_fixed_notice_at_yyyy"=>"",
         "trial_fixed_at_dd"=>"",
         "trial_fixed_at_mm"=>"",
         "trial_fixed_at_yyyy"=>"",
         "trial_cracked_at_dd"=>"",
         "trial_cracked_at_mm"=>"",
         "trial_cracked_at_yyyy"=>"",
         "trial_cracked_at_third"=>"",
         "court_id"=>court.id,
         "case_number"=>"A12345678",
         "advocate_category"=>"QC",
         "external_user_id" => external_user.id,
         "offence_id"=>offence.id,
         "first_day_of_trial_dd"=>"8",
         "first_day_of_trial_mm"=>"9",
         "first_day_of_trial_yyyy"=>"2015",
         "estimated_trial_length"=>"0",
         "actual_trial_length"=>"0",
         "trial_concluded_at_dd"=>"11",
         "trial_concluded_at_mm"=>"9",
         "trial_concluded_at_yyyy"=>"2015",
         "defendants_attributes"=>
          {"0"=>
            {"first_name"=>"Foo",
             "last_name"=>"Bar",
             "date_of_birth_dd"=>"04",
             "date_of_birth_mm"=>"10",
             "date_of_birth_yyyy"=>"1980",
             "order_for_judicial_apportionment"=>"0",
             "representation_orders_attributes"=>
              {"0"=>
                {"representation_order_date_dd"=>"30",
                 "representation_order_date_mm"=>"08",
                 "representation_order_date_yyyy"=>"2015",
                 "maat_reference"=>"1234567890",
                 "_destroy"=>"false"}},
             "_destroy"=>"false"}},
         "additional_information"=>"",
         "basic_fees_attributes"=>
          {"0"=>{"quantity"=>"1", "rate"=>"150", "fee_type_id"=>fee_type.id}},
         "misc_fees_attributes"=>{"0"=>{"fee_type_id"=> "", "quantity"=>"", "rate"=>"", "_destroy"=>"false"}},
         "fixed_fees_attributes"=>{"0"=>{"fee_type_id"=>"", "quantity"=>"", "rate"=>"", "_destroy"=>"false"}},
         "expenses_attributes"=>{"0"=>{"expense_type_id"=>expense_type.id, "location"=>"London", "quantity"=>"1", "rate"=>"40", "_destroy"=>"false"}},
         "apply_vat"=>"0",
         "document_ids"=>[""],
         "evidence_checklist_ids"=>["1", ""]},
       "offence_category"=>{"description"=>""},
       "offence_class"=>{"description"=>"64"},
       "commit_submit_claim"=>"Submit to LAA"}
      claim = Claim::AdvocateClaim.new(params['claim'])
      claim.creator = external_user
      expect(claim.save).to be true
      claim.force_validation = true
      result = claim.valid?
      ap claim.errors if result == false
      expect(claim.expenses).to have(1).member
      expect(claim.expenses_total).to eq 40.0
    end
  end


# local helpers
# ---------------------
  def valid_params
    external_user = FactoryGirl.create :external_user
    {"claim"=>
        {"external_user_id" => external_user.id,
        "creator_id" => external_user.id,
        "case_type_id"=>"1",
        "trial_fixed_notice_at_dd"=>"",
        "trial_fixed_notice_at_mm"=>"",
        "trial_fixed_notice_at_yyyy"=>"",
        "trial_fixed_at_dd"=>"",
        "trial_fixed_at_mm"=>"",
        "trial_fixed_at_yyyy"=>"",
        "trial_cracked_at_dd"=>"",
        "trial_cracked_at_mm"=>"",
        "trial_cracked_at_yyyy"=>"",
        "trial_cracked_at_third"=>"",
        "court_id"=>"1",
        "case_number"=>"A12345678",
        "advocate_category"=>"QC",
        "offence_id"=>"1",
        "first_day_of_trial_dd"=>"8",
        "first_day_of_trial_mm"=>"9",
        "first_day_of_trial_yyyy"=>"2015",
        "estimated_trial_length"=>"0",
        "actual_trial_length"=>"0",
        "trial_concluded_at_dd"=>"11",
        "trial_concluded_at_mm"=>"9",
        "trial_concluded_at_yyyy"=>"2015",
        "defendants_attributes"=>
          {"0"=>
            {"first_name"=>"Foo",
            "last_name"=>"Bar",
            "date_of_birth_dd"=>"04",
            "date_of_birth_mm"=>"10",
            "date_of_birth_yyyy"=>"1980",
            "order_for_judicial_apportionment"=>"0",
            "representation_orders_attributes"=>
              {"0"=>
                {"representation_order_date_dd"=>"30",
                "representation_order_date_mm"=>"08",
                "representation_order_date_yyyy"=>"2015",
                "maat_reference"=>"aaa1111",
                "_destroy"=>"false"}},
            "_destroy"=>"false"}},
        "additional_information"=>"",
        "basic_fees_attributes"=>
          {"0"=>{"quantity"=>"1", "rate"=>"450", "fee_type_id"=>@bft1.id}},
        "apply_vat"=>"0",
        "document_ids"=>[""],
        "evidence_checklist_ids"=>["1", ""]},
      "offence_category"=>{"description"=>""},
      "offence_class"=>{"description"=>"64"}
    }

  end

end
