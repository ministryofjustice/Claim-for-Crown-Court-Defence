require 'rails_helper'

RSpec.describe Claim::AdvocateClaim do
  subject(:claim) { create(:advocate_claim) }

  it_behaves_like 'a base claim'
  it_behaves_like 'a claim with an AGFS fee scheme factory', FeeSchemeFactory::AGFS
  it_behaves_like 'a claim delegating to case type'
  it_behaves_like 'uses claim cleaner', Cleaners::AdvocateClaimCleaner

  it { is_expected.to delegate_method(:requires_cracked_dates?).to(:case_type) }

  it { is_expected.to accept_nested_attributes_for(:basic_fees) }
  it { is_expected.to accept_nested_attributes_for(:fixed_fees) }

  specify { expect(claim.external_user_type).to eq(:advocate) }
  specify { expect(claim.requires_case_type?).to be_truthy }
  specify { expect(claim.agfs?).to be_truthy }
  specify { expect(claim.final?).to be_truthy }
  specify { expect(claim.interim?).to be_falsey }
  specify { expect(claim.supplementary?).to be_falsey }

  describe 'validates external user and creator with same provider' do
    subject(:claim) { described_class.create(external_user:, creator:) }

    let(:provider) { create(:provider) }
    let(:external_user) { create(:external_user, provider:) }
    let(:creator) { external_user }

    context 'with no external user' do
      let(:external_user) { nil }

      it { is_expected.not_to be_valid }
      it { expect(claim.errors[:external_user_id]).to eq(['Choose an advocate']) }
    end

    context 'when the external_user_id and creator_id are the same' do
      it { is_expected.to be_valid }
      it { expect(claim.reload.errors.messages[:external_user_id]).not_to be_present }
    end

    context 'when the external_user_id and creator_id are different but of the same provider' do
      let(:creator) { create(:external_user, provider:) }

      it { is_expected.to be_valid }
      it { expect(claim.reload.errors.messages[:external_user_id]).not_to be_present }
    end

    context 'when the external_user and creator are with different providers' do
      let(:creator) { create(:external_user, provider: create(:provider)) }

      it { is_expected.not_to be_valid }
      it { expect(claim.errors.messages[:external_user_id]).to eq(['Creator and advocate must belong to the same provider']) }
    end
  end

  describe 'validate external user is advocate role' do
    let(:claim) { build(:unpersisted_claim, :with_fixed_fee_case) }

    it 'validates external user with advocate role' do
      expect(claim.external_user.is?(:advocate)).to be_truthy
      expect(claim).to be_valid
    end

    it 'rejects external user without advocate role' do
      claim.external_user = build :external_user, :litigator, provider: claim.creator.provider
      expect(claim).not_to be_valid
      expect(claim.errors[:external_user_id]).to include('must have advocate role')
    end
  end

  describe '#eligible_case_types' do
    subject(:claim) { described_class.new }

    let!(:agfs_case_types) do
      [
        create(:case_type, name: 'AGFS and LGFS case type', roles: %w[agfs lgfs]),
        create(:case_type, name: 'AGFS case type', roles: %w[agfs])
      ]
    end

    before { create(:case_type, name: 'LGFS case type', roles: %w[lgfs]) }

    it 'returns only AGFS case types' do
      expect(claim.eligible_case_types).to match_array(agfs_case_types)
    end
  end

  context 'eligible fee types' do
    subject(:claim) { build(:unpersisted_claim) }

    before(:all) do
      @bft1 = create(:basic_fee_type, roles: %w[agfs agfs_scheme_9 agfs_scheme_10], description: 'bft1')
      @bft2 = create(:basic_fee_type, :lgfs, description: 'bft2')
      @bft3 = create(:basic_fee_type, description: 'bft3')
      @bft4 = create(:basic_fee_type, roles: %w[agfs agfs_scheme_9], description: 'bft4')
      @bft5 = create(:basic_fee_type, roles: %w[agfs agfs_scheme_10], description: 'bft5')
      @mft1 = create(:misc_fee_type, :agfs_scheme_9)
      @mft2 = create(:misc_fee_type, :lgfs)
      @mft3 = create(:misc_fee_type, :agfs_scheme_10)
      @fft1 = create(:fixed_fee_type)
      @fft2 = create(:fixed_fee_type, :lgfs)
    end

    after(:all) do
      clean_database
    end

    describe '#eligible_basic_fee_types' do
      it 'returns only basic fee types for AGFS' do
        expect(claim.eligible_basic_fee_types).to contain_exactly(@bft1, @bft3, @bft4)
      end

      context 'when claim has fee reform scheme' do
        let(:claim) { create(:claim, :agfs_scheme_10) }

        it 'returns only basic fee types for AGFS excluding the ones that are not part of the fee reform' do
          expect(claim.eligible_basic_fee_types).to contain_exactly(@bft1, @bft5)
        end
      end

      context 'when claim has a scheme 10 offence (from API)' do
        let(:offence) { create(:offence, :with_fee_scheme_ten) }
        let(:claim) { create(:claim, create_defendant_and_rep_order: false, source: 'api', offence:) }

        it 'returns only basic fee types for AGFS scheme 10' do
          expect(claim.eligible_basic_fee_types).to contain_exactly(@bft1, @bft5)
        end
      end
    end

    describe '#eligible_misc_fee_types' do
      subject(:call) { claim.eligible_misc_fee_types }

      let(:service) { instance_double(Claims::FetchEligibleMiscFeeTypes) }

      it 'calls eligible misc fee type fetch service' do
        allow(Claims::FetchEligibleMiscFeeTypes).to receive(:new).and_return service
        allow(service).to receive(:call)
        call
        expect(service).to have_received(:call)
      end
    end

    describe '#eligible_fixed_fee_types' do
      subject(:call) { claim.eligible_fixed_fee_types }

      let(:service) { instance_double(Claims::FetchEligibleFixedFeeTypes) }

      it 'calls eligible fixed fee type fetch service' do
        allow(Claims::FetchEligibleFixedFeeTypes).to receive(:new).and_return service
        allow(service).to receive(:call)
        call
        expect(service).to have_received(:call)
      end
    end
  end

  describe '#eligible_advocate_categories' do
    let(:categories) { double(:mocked_categories_result) }
    let(:claim) { build(:advocate_claim) }

    specify do
      allow(Claims::FetchEligibleAdvocateCategories).to receive(:for).with(claim).and_return(categories)
      expect(claim.eligible_advocate_categories).to eq(categories)
    end
  end

  describe 'State Machine meta states magic methods' do
    let(:claim) { build(:claim) }
    let(:all_states) do
      %w[allocated archived_pending_delete draft authorised part_authorised refused rejected submitted]
    end

    describe '#external_user_dashboard_draft?' do
      before { allow(claim).to receive(:state).and_return('draft') }

      it 'responds true in draft' do
        allow(claim).to receive(:state).and_return('draft')
        expect(claim.external_user_dashboard_draft?).to be true
      end

      it 'responds false to anything else' do
        (all_states - ['draft']).each do |state|
          allow(claim).to receive(:state).and_return(state)
          expect(claim.external_user_dashboard_draft?).to be false
        end
      end
    end

    describe '#external_user_dashboard_rejected?' do
      before { allow(claim).to receive(:state).and_return('rejected') }

      it 'responds true' do
        allow(claim).to receive(:state).and_return('rejected')
        expect(claim.external_user_dashboard_rejected?).to be true
      end

      it 'responds false to anything else' do
        (all_states - ['rejected']).each do |state|
          allow(claim).to receive(:state).and_return(state)
          expect(claim.external_user_dashboard_rejected?).to be false
        end
      end
    end

    describe '#external_user_dashboard_submitted?' do
      it 'responds true' do
        %w[allocated submitted].each do |claim_state|
          allow(claim).to receive(:state).and_return(claim_state)
          expect(claim.external_user_dashboard_submitted?).to be true
        end
      end

      it 'responds false to anything else' do
        (all_states - %w[allocated submitted]).each do |claim_state|
          allow(claim).to receive(:state).and_return(claim_state)
          expect(claim.external_user_dashboard_submitted?).to be false
        end
      end
    end

    describe '#external_user_dashboard_part_authorised?' do
      it 'responds true' do
        ['part_authorised'].each do |state|
          allow(claim).to receive(:state).and_return(state)
          expect(claim.external_user_dashboard_part_authorised?).to be true
        end
      end

      it 'responds false to anything else' do
        (all_states - ['part_authorised']).each do |claim_state|
          allow(claim).to receive(:state).and_return(claim_state)
          expect(claim.external_user_dashboard_part_authorised?).to be false
        end
      end
    end

    describe '#external_user_dashboard_completed_states?' do
      it 'responds true' do
        %w[refused authorised].each do |state|
          allow(claim).to receive(:state).and_return(state)
          expect(claim.external_user_dashboard_completed?).to be true
        end
      end

      it 'responds false to anything else' do
        (all_states - %w[refused authorised]).each do |claim_state|
          allow(claim).to receive(:state).and_return(claim_state)
          expect(claim.external_user_dashboard_completed?).to be false
        end
      end
    end

    context 'unrecognised state' do
      it 'raises NoMethodError' do
        expect { claim.other_unknown_state? }.to raise_error NoMethodError, /undefined method `other_unknown_state\?'/
      end
    end
  end

  describe '.earliest_representation_order' do
    subject(:claim) { build(:unpersisted_claim) }

    let(:early_date) { scheme_date_for(nil).to_date - 10.days }

    before do
      # add a second defendant
      claim.defendants << create(:defendant, claim:)

      # add a second rep order to the first defendant
      claim.defendants.first.representation_orders << create(:representation_order, representation_order_date: early_date)
    end

    it 'picks the earliest reporder' do
      # given a claim with two defendants and three rep orders
      expect(claim.defendants).to have_exactly(2).items
      expect(claim.representation_orders).to have_exactly(3).items

      # when I get the earliest rep order
      rep_order = claim.earliest_representation_order

      # it should have a date of
      expect(rep_order.representation_order_date).to eq early_date
    end
  end

  describe '#allocated_to_case_worker?' do
    let(:case_worker_1) { create(:case_worker) }
    let(:case_worker_2) { create(:case_worker) }

    it 'returns true if allocated to the specified case_worker' do
      claim.case_workers << case_worker_1
      claim.case_workers << case_worker_2
      expect(claim.allocated_to_case_worker?(case_worker_1)).to be true
    end

    it 'returns false if not allocated to the specified case_worker' do
      claim.case_workers << case_worker_1
      expect(claim.allocated_to_case_worker?(case_worker_2)).to be false
    end
  end

  context 'basic fees' do
    let!(:basic_fee_types) do
      [
        create(:basic_fee_type, description: 'ZZZZ'),
        create(:basic_fee_type, description: 'AAAA'),
        create(:basic_fee_type, description: 'BBBB')
      ]
    end

    before do
      create(:fixed_fee_type, description: 'DDDD')
      create(:misc_fee_type, description: 'CCCC')
      create(:misc_fee_type, description: 'EEEE')
    end

    context 'when the case type is not yet set' do
      subject(:claim) { described_class.new(case_type: nil) }

      specify { expect(claim.basic_fees).to be_empty }
    end

    context 'when the case type is set and its for fixed fee' do
      subject(:claim) { described_class.new(case_type:) }

      let(:case_type) { create(:case_type, :fixed_fee) }

      specify { expect(claim.basic_fees).to be_empty }
    end

    context 'when the case type is set and its for graduated fee' do
      subject(:claim) { described_class.new(case_type:) }

      let(:case_type) { create(:case_type, :graduated_fee) }

      it 'returns a list of basic fees for each of the eligible basic fee types with all the fees with blank values' do
        expect(claim.basic_fees.length).to eq(3)
        expect(claim.basic_fees.map(&:fee_type)).to match_array(claim.eligible_basic_fee_types)
        expect(claim.basic_fees).to all(be_blank)
      end

      context 'when some basic fees are provided' do
        subject(:claim) { described_class.new(attributes) }

        let(:attributes) do
          {
            'basic_fees_attributes' => {
              '0' => {
                'quantity' => '1',
                'rate' => '450',
                'fee_type_id' => basic_fee_types.first.id
              }
            },
            'case_type_id' => case_type.id
          }
        end

        it 'returns a list of basic fees for each of the eligible basic fee types with the ones provided by the user filled in' do
          expect(claim.basic_fees.length).to eq(3)
          expect(claim.basic_fees.map(&:fee_type_id).sort).to eq(claim.eligible_basic_fee_types.map(&:id).sort)
          expect(claim.basic_fees.map(&:rate)).to contain_exactly(450, nil, nil)
        end
      end
    end
  end

  describe '.search' do
    let!(:other_claim) { create(:advocate_claim) }
    let(:states) { nil }

    it 'finds only claims with states that match dashboard displayable states' do
      sql = described_class.search('%', states, :advocate_name, :defendant_name, :maat_reference, :case_worker_name_or_email).to_sql
      state_in_list_clause = Claims::StateMachine.dashboard_displayable_states.map { |s| "'#{s}'" }.join(', ')
      expect(sql.downcase).to include(' "claims"."state" in (' << state_in_list_clause << ')')
    end

    context 'invalid search options' do
      it 'raises' do
        expect { described_class.search('My search term', [], 'caseworker-name') }
          .to raise_error RuntimeError, 'Invalid search option'
      end
    end

    context 'find by MAAT reference' do
      let(:search_options) { :maat_reference }

      before do
        create(:defendant, claim:, representation_orders: create_list(:representation_order, 1, maat_reference: '111111'))
        create(:defendant, claim:, representation_orders: create_list(:representation_order, 1, maat_reference: '222222'))
        create(
          :defendant,
          claim: other_claim,
          representation_orders: create_list(:representation_order, 1, maat_reference: '333333')
        )
        claim.reload
        other_claim.reload
      end

      it 'finds the claim by MAAT reference "111111"' do
        expect(described_class.search('111111', states, search_options)).to eq([claim])
      end

      it 'finds the claim by MAAT reference "222222"' do
        expect(described_class.search('222222', states, search_options)).to eq([claim])
      end

      it 'finds the claim by MAAT reference "333333"' do
        expect(described_class.search('333333', states, search_options)).to eq([other_claim])
      end

      it 'does not find a claim with MAAT reference "444444"' do
        expect(described_class.search('444444', states, search_options)).to be_empty
      end
    end

    context 'find by Defendant name' do
      let!(:current_external_user) { create(:external_user) }
      let!(:other_external_user)   { create(:external_user, provider: current_external_user.provider) }
      let(:search_options)         { :defendant_name }

      before do
        claim.external_user = current_external_user
        claim.creator = current_external_user
        other_claim.external_user = other_external_user
        other_claim.creator = other_external_user
        claim.save!
        other_claim.save!
        create(:defendant, first_name: 'Joe', last_name: 'Bloggs', claim:)
        create(:defendant, first_name: 'Joe', last_name: 'Bloggs', claim: other_claim)
        create(:defendant, first_name: 'Herbie', last_name: 'Hart', claim: other_claim)
        claim.reload
        other_claim.reload
      end

      it 'finds all claims involving specified defendant' do
        expect(described_class.search('Joe Bloggs', states, search_options).count).to eq(2)
      end

      it 'finds claim involving other specified defendant' do
        expect(described_class.search('Hart', states, search_options)).to eq([other_claim])
      end

      it 'does not find claims involving non-existent defendant"' do
        expect(described_class.search('Foo Bar', states, search_options)).to be_empty
      end
    end

    context 'find by Advocate name' do
      let(:search_options) { :advocate_name }

      before do
        claim.external_user = create(:external_user)
        claim.creator = claim.external_user
        other_claim.external_user = create(:external_user)
        other_claim.creator = other_claim.external_user
        claim.external_user.user.first_name = 'John'
        claim.external_user.user.last_name = 'Smith'
        claim.external_user.user.save!

        claim.save!

        other_claim.external_user.user.first_name = 'Bob'
        other_claim.external_user.user.last_name = 'Hoskins'
        other_claim.external_user.user.save!

        other_claim.save!
      end

      it 'finds the claim by advocate name "John Smith"' do
        expect(described_class.search('John Smith', states, search_options)).to eq([claim])
      end

      it 'finds the claim by advocate name "Bob Hoskins"' do
        expect(described_class.search('Bob Hoskins', states, search_options)).to eq([other_claim])
      end

      it 'does not find a claim with advocate name "Foo Bar"' do
        expect(described_class.search('Foo Bar', states, search_options)).to be_empty
      end
    end

    context 'find claims by state' do
      let(:search_options) { :advocate_name }

      before do
        bob_hoskins = create(:user, first_name: 'Bob', last_name: 'Hoskins')
        bob_hoskins.save!
        adv_bob_hoskins = create(:external_user, user: bob_hoskins)
        adv_bob_hoskins.save!
        create_list(:archived_pending_delete_claim, 2, external_user: adv_bob_hoskins)
        create_list(:authorised_claim, 2, external_user: adv_bob_hoskins)
        create(:allocated_claim, external_user: adv_bob_hoskins)
      end

      it 'finds only claims of the single state specified' do
        expect(described_class.search('Bob Hoskins', :archived_pending_delete, search_options).count).to eq 2
      end

      it 'finds only claims of the multiple states specified' do
        expect(
          described_class.search('Bob Hoskins', %i[archived_pending_delete authorised], search_options).count
        ).to eq 4
      end

      it 'defaults to finding claims of dashboard_displayable_states' do
        expect(described_class.search('Bob Hoskins', nil, search_options).count).to eq 3
      end
    end

    context 'find by advocate and defendant' do
      let!(:current_external_user) { create(:external_user) }
      let!(:other_external_user)   { create(:external_user, provider: current_external_user.provider) }
      let(:search_options)         { %i[advocate_name defendant_name] }

      before do
        claim.external_user = current_external_user
        claim.creator = current_external_user
        claim.external_user.user.first_name = 'Fred'
        claim.external_user.user.last_name = 'Bloggs'
        claim.external_user.user.save!
        create(:defendant, first_name: 'Joexx', last_name: 'Bloggs', claim:)
        claim.save!

        other_claim.external_user = other_external_user
        other_claim.creator = other_external_user
        other_claim.external_user.user.first_name = 'Johncz'
        other_claim.external_user.user.last_name = 'Hoskins'
        other_claim.external_user.user.save!
        create(:defendant, first_name: 'Fred', last_name: 'Hoskins', claim: other_claim)
        other_claim.save!
      end

      it 'finds claims with either advocate or defendant matching names' do
        expect(described_class.search('Bloggs', states, *search_options)).to eq([claim])
        expect(described_class.search('Hoskins', states, *search_options)).to eq([other_claim])
        expect(described_class.search('Fred', states, *search_options).count).to eq(2) # advocate and defendant of name
        expect(described_class.search('Johncz', states, *search_options).count).to eq(1) # advocate only search
        expect(described_class.search('Joexx', states, *search_options).count).to eq(1) # defendant only search
      end

      it 'does not find claims that do not match the name' do
        expect(described_class.search('Xavierxxxx', states, :advocate_name, :defendant_name).count).to eq(0)
      end
    end

    context 'find by case worker name or email' do
      let!(:case_worker) { create(:case_worker) }
      let!(:other_case_worker) { create(:case_worker) }
      let(:search_options) { :case_worker_name_or_email }

      before do
        claim.case_workers << case_worker
        other_claim.case_workers << other_case_worker
      end

      it 'finds the claim by case_worker name' do
        expect(described_class.search(case_worker.name, states, search_options)).to eq([claim])
      end

      it 'finds the other claim by case worker name' do
        expect(described_class.search(other_case_worker.name, states, search_options)).to eq([other_claim])
      end

      it 'does not find a claim with a non existent case worker' do
        expect(described_class.search('Foo Bar', states, search_options)).to be_empty
      end
    end

    context 'with invalid option' do
      it 'raises error for invalid option' do
        expect { described_class.search('foo', states, :case_worker_name_or_email, :foo) }
          .to raise_error(/Invalid search option/)
      end
    end

    context 'with invalid state' do
      it 'raises error for invalid option' do
        expect { described_class.search('foo', :rubbish_state, :case_worker_name_or_email) }
          .to raise_error(/Invalid state, rubbish_state, specified/)
      end
    end
  end

  context 'fees total' do
    before do
      seed_case_types
      seed_fee_types
    end

    let(:misc_fees) { [build(:misc_fee, :miaph_fee, rate: 0.50)] }

    describe '#calculate_fees_total' do
      context 'for a fixed case type' do
        subject(:claim) { create(:advocate_claim, :with_fixed_fee_case, fixed_fees:, misc_fees:) }

        let(:fixed_fees) { [build(:fixed_fee, :fxase_fee, rate: 0.50)] }

        it 'calculates the fees total' do
          expect(claim.calculate_fees_total).to eq(1.0)
        end

        it 'calculates fee totals by category too' do
          expect(claim.calculate_fees_total(:basic_fees)).to eq(0.0)
          expect(claim.calculate_fees_total(:misc_fees)).to eq(0.5)
          expect(claim.calculate_fees_total(:fixed_fees)).to eq(0.5)
        end
      end

      context 'for a graduated case type' do
        subject(:claim) do
          create(:advocate_claim, :with_graduated_fee_case, misc_fees:).tap do |c|
            c.basic_fees = basic_fees
          end
        end

        let(:basic_fees) do
          [
            build(:basic_fee, :baf_fee, rate: 4.00),
            build(:basic_fee, :baf_fee, rate: 3.00)
          ]
        end

        it 'calculates the fees total' do
          expect(claim.calculate_fees_total).to eq(7.5)
        end

        it 'calculates fee totals by category too' do
          expect(claim.calculate_fees_total(:basic_fees)).to eq(7.0)
          expect(claim.calculate_fees_total(:misc_fees)).to eq(0.5)
          expect(claim.calculate_fees_total(:fixed_fees)).to eq(0.0)
        end
      end
    end

    describe '#update_fees_total' do
      context 'for a fixed case type' do
        subject(:claim) { create(:advocate_claim, :with_fixed_fee_case, fixed_fees:, misc_fees:) }

        let(:fixed_fees) { [build(:fixed_fee, :fxase_fee, rate: 0.50)] }

        it 'stores the fees total' do
          expect(claim.fees_total).to eq(1.0)
        end

        it 'updates the fees total' do
          claim.fixed_fees.create attributes_for(:fixed_fee, :fxase_fee, rate: 2.00)
          expect(claim.fees_total).to eq(3.0)
        end

        it 'updates total when claim fee destroyed' do
          expect { claim.fixed_fees.first.destroy }.to change(claim, :fees_total).from(1.0).to(0.5)
        end
      end

      context 'for a graduated case type' do
        subject(:claim) do
          create(:advocate_claim, :with_graduated_fee_case, misc_fees:).tap do |c|
            c.basic_fees = basic_fees
          end
        end

        let(:basic_fees) do
          [
            build(:basic_fee, :baf_fee, rate: 4.00),
            build(:basic_fee, :baf_fee, rate: 3.00)
          ]
        end

        it 'stores the fees total' do
          expect(claim.fees_total).to eq(7.5)
        end

        it 'updates the fees total' do
          expect { claim.basic_fees.create attributes_for(:basic_fee, :baf_fee, rate: 2.00) }
            .to change(claim, :fees_total).from(7.5).to(9.5)
        end

        it 'updates total when claim fee destroyed' do
          expect { claim.basic_fees.where(rate: 3.00).first.destroy }
            .to change(claim, :fees_total).from(7.5).to(4.5)
        end
      end
    end
  end

  context 'expenses total' do
    before do
      create(:expense, claim_id: claim.id, amount: 3.5)
      create(:expense, claim_id: claim.id, amount: 1.0)
      create(:expense, claim_id: claim.id, amount: 142.0)
      claim.reload
    end

    describe '#update_expenses_total' do
      it 'stores the expenses total' do
        expect(claim.expenses_total).to eq(146.5)
      end

      it 'updates the expenses total' do
        create(:expense, claim_id: claim.id, amount: 3.0)
        claim.reload
        expect(claim.expenses_total).to eq(149.5)
      end

      it 'updates expenses total when expense destroyed' do
        expense = claim.expenses.first
        expense.destroy
        claim.reload
        expect(claim.expenses_total).to eq(143.0)
      end
    end
  end

  context 'total' do
    let(:fee_type) { create(:misc_fee_type) }

    before do
      claim.fees.destroy_all
      create(:misc_fee, claim_id: claim.id, rate: 3.00)
      create(:misc_fee, claim_id: claim.id, rate: 2.00)
      create(:misc_fee, claim_id: claim.id, rate: 1.00)

      create(:expense, claim_id: claim.id, amount: 3.5)
      create(:expense, claim_id: claim.id, amount: 1.0)
      create(:expense, claim_id: claim.id, amount: 142.0)
      claim.reload
    end

    describe '#calculate_total' do
      it 'calculates the fees and expenses total' do
        expect(claim.calculate_total).to eq(152.5)
      end
    end

    describe '#update_total' do
      it 'updates the total' do
        create(:expense, claim_id: claim.id, amount: 3.0)
        create(:misc_fee, claim_id: claim.id, rate: 0.5)
        claim.reload
        expect(claim.total).to eq(156.00)
      end

      it 'updates total when expense/fee destroyed' do
        expense = claim.expenses.first
        fee = claim.fees.first
        expense.destroy
        fee.destroy
        claim.reload
        expect(claim.total).to eq(146.00)
      end
    end
  end

  describe '#editable?' do
    let(:draft) { create(:advocate_claim) }
    let(:submitted) { create(:submitted_claim) }
    let(:allocated) { create(:allocated_claim) }

    it 'is editable when draft' do
      expect(draft.editable?).to be(true)
    end

    it 'is not editable when submitted' do
      expect(submitted.editable?).to be(false)
    end

    it 'is not editable when allocated' do
      expect(allocated.editable?).to be(false)
    end
  end

  describe '#archivable?' do
    let(:claim) { create(:advocate_claim) }

    it 'is not archivable from states: allocated, archived_pending_delete, awaiting_written_reasons, draft, redetermination' do
      %w[allocated awaiting_written_reasons draft redetermination].each do |state|
        allow(claim).to receive(:state).and_return(state)
        expect(claim.archivable?).to be(false)
      end
    end

    it 'is archivable from states: refused, rejected, part authorised, authorised' do
      %w[refused rejected part_authorised authorised].each do |state|
        allow(claim).to receive(:state).and_return(state)
        expect(claim.archivable?).to be(true)
      end
    end
  end

  describe '#validation_required?' do
    let(:claim) { create(:claim, source: 'web') }

    context 'should return false for' do
      it 'draft claims submited by web app' do
        expect(claim.validation_required?).to be false
      end

      it 'archived_pending_delete claims' do
        claim = create(:archived_pending_delete_claim)
        expect(claim.validation_required?).to be false
      end
    end

    context 'should return true for' do
      it 'draft claims submitted by the API' do
        claim.source = 'api'
        expect(claim.validation_required?).to be true
      end

      it 'claims in any state other than draft or archived_pending_delete' do
        states = described_class.state_machine.states.map(&:name) - %i[draft archived_pending_delete]
        states.each do |state|
          claim.state = state
          expect(claim.validation_required?).to be true
        end
      end
    end
  end

  describe 'allocate claim when assigning to case worker' do
    subject(:claim) { create(:submitted_claim) }

    let(:case_worker) { create(:case_worker) }

    it 'moves to "allocated" state when assigned to case worker' do
      claim.case_workers << case_worker
      expect(claim.reload).to be_allocated
    end
  end

  describe 'moves to "submitted" state when case worker removed' do
    subject(:claim) { create(:submitted_claim) }

    let(:case_worker) { create(:case_worker) }
    let(:other_case_worker) { create(:case_worker) }

    before do
      case_worker.claims << claim
      other_case_worker.claims << claim
      claim.reload
    end

    it 'is "allocated"' do
      expect(claim).to be_allocated
    end

    context 'when case worker unassigned and other case workers remain' do
      it 'is "allocated"' do
        case_worker.claims.destroy(claim)
        expect(claim.reload).to be_allocated
      end
    end

    context 'when all case workers unassigned' do
      it 'is "submitted"' do
        case_worker.claims.destroy(claim)
        other_case_worker.claims.destroy(claim)
        expect(claim.reload).to be_submitted
      end
    end
  end

  describe '#authorised_state?' do
    let(:claim) { create(:draft_claim) }

    it 'returns false for draft, submitted, allocated, and rejected claims' do
      expect(claim.authorised_state?).to be_falsey
      claim.submit
      expect(claim.authorised_state?).to be_falsey
      claim.allocate
      expect(claim.authorised_state?).to be_falsey
      claim.reject
      expect(claim.authorised_state?).to be_falsey
    end

    it 'returns true for part_authorised, authorised claims' do
      claim.submit
      claim.allocate
      claim.assessment.update(fees: 30.01, expenses: 70.00)
      claim.authorise_part
      expect(claim.authorised_state?).to be_truthy
      claim.authorise
      expect(claim.authorised_state?).to be_truthy
    end
  end

  describe 'Case type scopes' do
    before(:all) do
      load(Rails.root.join('db', 'seeds', 'case_types.rb'))
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
        expect(described_class.trial).to match_array(@trials + @retrials)
      end
    end

    describe '.cracked' do
      it 'returns cracked trials and retrials' do
        expect(described_class.cracked).to match_array(@cracked_trials + @cracked_retrials)
      end
    end

    describe '.guilty_plea' do
      it 'returns guilty pleas and discontinuances' do
        expect(described_class.guilty_plea).to match_array(@guilty_pleas + @discontinuances)
      end
    end
  end

  describe '#fixed_fees' do
    let(:ct_fixed_1)          { create(:case_type, :fixed_fee) }
    let(:ct_fixed_2)          { create(:case_type, :fixed_fee) }
    let(:ct_basic_1)          { create(:case_type) }
    let(:ct_basic_2)          { create(:case_type) }

    it 'only returns claims with fixed fee case types' do
      claim_1 = create(:claim, case_type_id: ct_fixed_1.id)
      claim_2 = create(:claim, case_type_id: ct_fixed_2.id)
      create(:claim, case_type_id: ct_basic_1.id)
      create(:claim, case_type_id: ct_basic_2.id)
      expect(described_class.fixed_fee.count).to eq 2
      expect(described_class.fixed_fee).to include claim_1
      expect(described_class.fixed_fee).to include claim_2
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
        claim.fees << create(:misc_fee, rate: value, claim:)
        claims << claim
      end

      claims
    end

    it 'only returns claims with total value greater than the specified value' do
      expect(described_class.total_greater_than_or_equal_to(400)).to match_array(greater_than_400)
    end
  end

  describe 'sets the source field before saving a claim' do
    let(:claim) { build(:claim) }

    it 'sets the source to web by default if unset' do
      expect(claim.save).to be(true)
      expect(claim.source).to eq('web')
    end

    it 'does not change the source if set' do
      claim.source = 'api'
      expect(claim.save).to be(true)
      expect(claim.source).to eq('api')
    end
  end

  describe 'sets the supplier number before validation' do
    let(:advocate)          { create(:external_user, :advocate) }
    let(:another_advocate)  { create(:external_user, :advocate, provider: advocate.provider) }
    let(:claim)             { build(:advocate_claim, external_user: advocate) }

    it 'does not have a supplier number before creation' do
      expect(claim.supplier_number).to be_nil
    end

    it 'has a supplier number, derived from the external_user, after creation' do
      expect { claim.save! }.to change(claim, :supplier_number).to eql(advocate.supplier_number)
    end

    it 'resets supplier number to match external_user' do
      claim.save!
      claim.external_user = another_advocate
      expect { claim.save! }.to change(claim, :supplier_number).to eql(another_advocate.supplier_number)
    end
  end

  describe 'provider type dependant methods' do
    let(:claim) { build(:unpersisted_claim) }

    describe 'for a chamber provider' do
      before do
        allow(claim.provider).to receive(:provider_type).and_return('chamber')
      end

      context '#vat_registered?' do
        it 'returns the value from the external user' do
          allow(claim.external_user).to receive(:vat_registered?)
          claim.vat_registered?
          expect(claim.external_user).to have_received(:vat_registered?)
        end
      end
    end

    describe 'for a firm provider' do
      before do
        allow(claim.provider).to receive(:provider_type).and_return('firm')
      end

      context '#vat_registered?' do
        it 'returns the value from the provider' do
          allow(claim.provider).to receive(:vat_registered?)
          claim.vat_registered?
          expect(claim.provider).to have_received(:vat_registered?)
        end
      end
    end

    describe 'for an unknown provider' do
      before do
        allow(claim.provider).to receive(:provider_type).and_return('zzzz')
      end

      context '#vat_registered?' do
        it 'raises an exception' do
          expect { claim.vat_registered? }.to raise_error(RuntimeError)
        end
      end
    end
  end

  describe '#calculate_vat' do
    subject { claim.vat_amount }

    context 'when vat is applied' do
      let(:claim) { create(:unpersisted_claim, :with_fixed_fee_case, total: 100) }

      before do
        allow(VatRate).to receive(:vat_amount).and_return(10)
        claim.submit!
      end

      it { is_expected.to eq 10 }
    end

    context 'when vat is not applied' do
      let(:claim) do
        create(
          :unpersisted_claim, :with_fixed_fee_case,
          fees_total: 1500.22,
          expenses_total: 500.00,
          vat_amount: 20,
          total: 100,
          external_user: build(:external_user, vat_registered: false)
        )
      end

      before { claim.submit! }

      it { is_expected.to eq 0.0 }
    end
  end

  describe '#opened_for_redetermination?' do
    let(:claim) { create(:advocate_claim) }

    before do
      claim.submit!
      claim.allocate!
      claim.refuse!
    end

    context 'when transitioned to redetermination' do
      before do
        claim.redetermine!
      end

      it 'is in an redetermination state' do
        expect(claim).to be_redetermination
      end

      it 'is open for redetermination' do
        expect(claim.opened_for_redetermination?).to be(true)
      end
    end

    context 'when transitioned to redetermination and then allocated/deallocated/allocated' do
      before do
        claim.redetermine!
        claim.allocate!
        claim.deallocate!
        claim.allocate!
      end

      it 'is open for redetermination' do
        expect(claim.opened_for_redetermination?).to be_truthy
      end
    end

    context 'when transitioned to redetermination and then refuse' do
      before do
        claim.redetermine!
        claim.allocate!
        claim.refuse!
      end

      it 'is close for redetermination' do
        expect(claim.opened_for_redetermination?).to be_falsey
      end
    end

    describe 'submission_date' do
      it 'sets the submission date to the date it was set to state redetermination' do
        new_time = 36.hours.from_now
        travel_to new_time do
          claim.redetermine!
        end
        expect(claim.last_submitted_at).to be_within(1.second).of(new_time)
      end
    end

    context 'when transitioned to allocated' do
      before do
        claim.redetermine!
        claim.allocate!
      end

      it 'is in an allocated state' do
        expect(claim).to be_allocated
      end

      it 'has been opened for redetermination before being allocated' do
        expect(claim.opened_for_redetermination?).to be(true)
      end
    end
  end

  describe 'comma formatted inputs' do
    %i[fees_total expenses_total total vat_amount].each do |attribute|
      it "converts input for #{attribute} by stripping commas out" do
        claim = build(:claim)
        claim.send("#{attribute}=", '12,321,111')
        expect(claim.send(attribute)).to eq(12_321_111)
      end
    end
  end

  describe '#written_reasons_outstanding?' do
    let(:claim) { create(:advocate_claim) }

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

      it 'is in an allocated state' do
        expect(claim).to be_allocated
      end

      it 'has written_reasons_outstanding before being allocated' do
        expect(claim.written_reasons_outstanding?).to be(true)
      end
    end

    context 'when transitioned to awaiting_written_reasons and then allocated/deallocated/allocated' do
      before do
        claim.await_written_reasons!
        claim.allocate!
        claim.deallocate!
        claim.allocate!
      end

      it 'is true' do
        expect(claim.written_reasons_outstanding?).to be_truthy
      end
    end

    context 'when transitioned to awaiting_written_reasons and then refuse' do
      before do
        claim.await_written_reasons!
        claim.allocate!
        claim.refuse!
      end

      it 'does not have written_reasons_outstanding' do
        expect(claim.written_reasons_outstanding?).to be_falsey
      end
    end
  end

  describe '#amount_assessed' do
    let(:external_user) { build(:external_user, vat_registered: false) }
    let!(:claim) { create(:claim, state: 'draft', external_user:) }

    context 'when VAT applied' do
      # VAT rate 20.0%

      before do
        claim.external_user.vat_registered = true
        claim.submit!
        claim.allocate!
        claim.assessment.update(fees: 1.55, expenses: 4.21)
        claim.authorise!
      end

      it 'returns the amount assessed from the last determination' do
        expect(claim.amount_assessed).to eq(6.91)
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

      it 'returns the amount assessed from the last determination' do
        expect(claim.amount_assessed).to eq(5.76)
      end
    end
  end

  describe 'not saving the expenses model' do
    it 'saves the expenses model' do
      external_user = create(:external_user)
      expense_type = create(:expense_type, :car_travel)
      fee_type = create(:basic_fee_type)
      case_type = create(:case_type)
      court = create(:court)
      offence = create(:offence)

      params = {
        'claim' => {
          'case_type_id' => case_type.id,
          'trial_fixed_notice_at(3i)' => '',
          'trial_fixed_notice_at(2i)' => '',
          'trial_fixed_notice_at(1i)' => '',
          'trial_fixed_at(3i)' => '',
          'trial_fixed_at(2i)' => '',
          'trial_fixed_at(1i)' => '',
          'trial_cracked_at(3i)' => '',
          'trial_cracked_at(2i)' => '',
          'trial_cracked_at(1i)' => '',
          'trial_cracked_at_third' => '',
          'court_id' => court.id,
          'case_number' => 'B20161234',
          'advocate_category' => 'QC',
          'external_user_id' => external_user.id,
          'offence_id' => offence.id,
          'first_day_of_trial(3i)' => '8',
          'first_day_of_trial(2i)' => '9',
          'first_day_of_trial(1i)' => '2015',
          'estimated_trial_length' => '0',
          'actual_trial_length' => '0',
          'trial_concluded_at(3i)' => '11',
          'trial_concluded_at(2i)' => '9',
          'trial_concluded_at(1i)' => '2015',
          'defendants_attributes' => {
            '0' => {
              'first_name' => 'Foo',
              'last_name' => 'Bar',
              'date_of_birth(3i)' => '04',
              'date_of_birth(2i)' => '10',
              'date_of_birth(1i)' => '1980',
              'order_for_judicial_apportionment' => '0',
              'representation_orders_attributes' => {
                '0' => {
                  'representation_order_date(3i)' => '30',
                  'representation_order_date(2i)' => '08',
                  'representation_order_date(1i)' => '2015',
                  'maat_reference' => '1234567890',
                  '_destroy' => 'false'
                }
              },
              '_destroy' => 'false'
            }
          },
          'additional_information' => '',
          'basic_fees_attributes' => {
            '0' => { 'quantity' => '1', 'rate' => '150', 'fee_type_id' => fee_type.id }
          },
          'misc_fees_attributes' => {
            '0' => { 'fee_type_id' => '', 'quantity' => '', 'rate' => '', '_destroy' => 'false' }
          },
          'fixed_fees_attributes' => {
            '0' => { 'fee_type_id' => '', 'quantity' => '', 'rate' => '', '_destroy' => 'false' }
          },
          'expenses_attributes' => {
            '0' => {
              'expense_type_id' => expense_type.id,
              'location' => 'London',
              'mileage_rate_id' => '1',
              '_destroy' => 'false',
              'reason_id' => '3',
              'distance' => '48',
              'amount' => '40.00',
              'date(3i)' => 10.days.ago.day.to_s,
              'date(2i)' => 10.days.ago.month.to_s,
              'date(1i)' => 10.days.ago.year.to_s
            }
          },
          'apply_vat' => '0',
          'document_ids' => [''],
          'evidence_checklist_ids' => ['1', '']
        },
        'offence_category' => { 'description' => '' },
        'offence_class' => { 'description' => '64' },
        'commit_submit_claim' => 'Submit to LAA'
      }
      claim = described_class.new(params['claim'])
      claim.creator = external_user
      expect(claim.save).to be true
      claim.force_validation = true
      claim.valid?
      expect(claim.expenses).to have(1).member
      expect(claim.expenses_total).to eq 40.0
    end

    describe '#discontinuance?' do
      let(:discontinuance) { create(:case_type, :discontinuance) }

      let(:claim_discontinuance_9) do
        create(:advocate_claim, :agfs_scheme_9, case_type: discontinuance, prosecution_evidence: true)
      end
      let(:agfs_scheme_9_claim) { create(:advocate_claim, :agfs_scheme_9) }

      let(:agfs_scheme_10_discontinuance_claim) do
        create(:advocate_claim, :agfs_scheme_10, case_type: discontinuance, prosecution_evidence: true)
      end
      let(:agfs_scheme_10_claim) { create(:advocate_claim, :agfs_scheme_10) }

      context 'when claim is scheme 9' do
        context 'when claim is a discontinuance' do
          it 'returns true' do
            expect(claim_discontinuance_9.discontinuance?).to be true
          end
        end

        context 'when claim is not a discontinuance' do
          it 'returns false' do
            expect(agfs_scheme_9_claim.discontinuance?).to be false
          end
        end
      end

      context 'when claim is scheme 10' do
        context 'when claim is a discontinuance' do
          it 'returns true' do
            expect(agfs_scheme_10_discontinuance_claim.discontinuance?).to be true
          end
        end

        context 'when claim is not a discontinuance' do
          it 'returns true' do
            expect(agfs_scheme_10_claim.discontinuance?).to be false
          end
        end
      end

      context 'when the claim has been saved as draft before the case type is set' do
        let(:claim) { build(:advocate_claim, case_type: nil) }

        it { expect(claim.discontinuance?).to be false }
      end
    end
  end
end
