# frozen_string_literal: true

require_relative 'shared_examples_for_journey_queryable'

RSpec.describe Stats::ManagementInformation::DailyReportQuery do
  it_behaves_like 'a claim journeys query' do
    let(:instance) { described_class.new }
  end

  describe '.call' do
    subject(:response) { described_class.call }

    it {
      create(:advocate_final_claim, :submitted)
      expect(response).to be_a(Array)
    }

    it {
      create(:advocate_final_claim, :submitted)
      expect(response).to all(be_a(Hash))
    }

    it {
      create(:advocate_final_claim, :submitted)
      keys = response.flat_map(&:keys)
      expect(keys).to all(be_a(Symbol))
    }

    context 'with no scope' do
      subject(:response) { described_class.call }

      it 'returns active claims only' do
        create(:advocate_final_claim, :authorised).soft_delete
        create(:litigator_final_claim, :submitted)
        deleted_ats = response.pluck(:deleted_at)

        expect(deleted_ats).to all(be_nil)
      end

      it 'returns non-draft claims only' do
        create(:advocate_final_claim, :draft)
        create(:litigator_final_claim, :submitted)
        states = response.pluck(:state)

        expect(states).to match_array(%w[submitted])
      end

      it 'returns all claim types' do
        create(:advocate_final_claim, :submitted)
        create(:litigator_final_claim, :submitted)
        types = response.pluck(:type)

        expect(types).to match_array(%w[Claim::AdvocateClaim Claim::LitigatorClaim])
      end
    end

    context 'with invalid scheme scope' do
      subject(:call) { described_class.call(scheme:) }

      let(:scheme) { :foobar }

      it { expect { call }.to raise_error ArgumentError, 'scheme must be "agfs" or "lgfs"' }
    end

    context 'with AGFS scheme scope' do
      subject(:response) { described_class.call(scheme:) }

      let(:scheme) { :agfs }

      it 'returns AGFS claims only' do
        create(:advocate_final_claim, :submitted)
        create(:litigator_final_claim, :submitted)
        types = response.pluck(:type)

        expect(types).to match_array(%w[Claim::AdvocateClaim])
      end
    end

    context 'with LGFS claim scope' do
      subject(:response) { described_class.call(scheme:) }

      let(:scheme) { :lgfs }

      it 'returns LGFS claims only' do
        create(:advocate_final_claim, :submitted)
        create(:litigator_final_claim, :submitted)
        types = response.pluck(:type)

        expect(types).to match_array(%w[Claim::LitigatorClaim])
      end
    end

    describe ':scheme' do
      subject { response.pluck(:scheme) }

      context 'with AGFS claim' do
        before { create(:advocate_final_claim, :submitted) }

        it { is_expected.to match_array(%w[AGFS]) }
      end

      context 'with LGFS claim' do
        before { create(:litigator_final_claim, :submitted) }

        it { is_expected.to match_array(%w[LGFS]) }
      end
    end

    describe ':organisation' do
      subject { response.pluck(:organisation) }

      let!(:claim) { create(:advocate_final_claim, :submitted) }

      it { is_expected.to contain_exactly(claim.provider.name) }
    end

    describe ':case_type_name' do
      subject { response.pluck(:case_type_name) }

      context 'with a claim without a case type' do
        before { create(:litigator_transfer_claim, :submitted) }

        it { is_expected.to contain_exactly(nil) }
      end

      context 'with a claim with a case type' do
        before { create(:advocate_final_claim, :submitted, case_type: build(:case_type, :cracked_trial)) }

        it 'returns case_type#name' do
          is_expected.to contain_exactly('Cracked Trial')
        end
      end

      context 'with a claim with a case stage' do
        before { create(:advocate_hardship_claim, :submitted, case_stage: build(:case_stage, :agfs_pre_ptph)) }

        it 'returns case_type#name belonging to case_stage' do
          is_expected.to contain_exactly('Discontinuance')
        end
      end
    end

    describe ':bill_type' do
      subject { response.pluck(:bill_type) }

      context 'with advocate final claim' do
        before { create(:advocate_final_claim, :submitted) }

        it { is_expected.to contain_exactly('AGFS Final') }
      end

      context 'with advocate supplementary claim' do
        before { create(:advocate_supplementary_claim, :submitted) }

        it { is_expected.to contain_exactly('AGFS Supplementary') }
      end

      context 'with litigator final claim' do
        before { create(:litigator_final_claim, :submitted) }

        it { is_expected.to contain_exactly('LGFS Final') }
      end

      context 'with litigator transfer claim' do
        before { create(:litigator_transfer_claim, :submitted) }

        it { is_expected.to contain_exactly('LGFS Transfer') }
      end
    end

    describe ':claim_total' do
      subject { response.pluck(:claim_total) }

      before do
        create(:litigator_final_claim, :submitted).tap do |c|
          c.update!(total: 9999.98555)
        end
      end

      it { is_expected.to all(be_a(BigDecimal)) }

      it 'rounds to 4 decimal places' do
        is_expected.to contain_exactly('9999.9856'.to_d)
      end
    end

    describe ':last_submitted_at' do
      subject(:last_submitted_ats) { response.pluck(:last_submitted_at) }

      context 'when outside of british summer time' do
        let(:timestamp) { DateTime.parse('2021-03-27 23:59:59') }

        before do
          create(:litigator_final_claim, :submitted).tap do |claim|
            claim.update!(last_submitted_at: timestamp)
          end
        end

        it 'retrieves correct date for Europe/London timezone' do
          expect(last_submitted_ats.first.to_date).to eql(Date.parse('2021-03-27'))
        end
      end

      context 'when inside british summer time' do
        let(:timestamp) { DateTime.parse('2021-03-29 23:59:59') }

        before do
          create(:litigator_final_claim, :submitted).tap do |claim|
            claim.update!(last_submitted_at: timestamp)
          end
        end

        it 'retrieves correct date for Europe/London timezone' do
          expect(last_submitted_ats.first.to_date).to eql(Date.parse('2021-03-30'))
        end
      end
    end

    describe ':originally_submitted_at' do
      subject(:originally_submitted_ats) { response.pluck(:originally_submitted_at) }

      context 'when outside of british summer time' do
        let(:timestamp) { DateTime.parse('2021-03-27 23:59:59') }

        before do
          create(:litigator_final_claim, :submitted).tap do |claim|
            claim.update!(original_submission_date: timestamp)
          end
        end

        it 'retrieves correct date for Europe/London timezone' do
          expect(originally_submitted_ats.first.to_date).to eql(Date.parse('2021-03-27'))
        end
      end

      context 'when inside british summer time' do
        let(:timestamp) { DateTime.parse('2021-03-29 23:59:59') }

        before do
          create(:litigator_final_claim, :submitted).tap do |claim|
            claim.update!(original_submission_date: timestamp)
          end
        end

        it 'retrieves correct date for Europe/London timezone' do
          expect(originally_submitted_ats.first.to_date).to eql(Date.parse('2021-03-30'))
        end
      end
    end

    describe ':completed_at' do
      subject(:completed_ats) { response.pluck(:completed_at) }

      let(:authorised_at) { 1.week.ago.beginning_of_day + 10.hours + 30.minutes }
      let(:redetermine_at) { 1.week.ago.beginning_of_day + 10.hours + 45.minutes }
      let(:refused_at) { 1.week.ago.beginning_of_day + 11.hours + 15.minutes }
      let(:claim) { create(:advocate_final_claim, :authorised) }

      context 'with a completed journey' do
        before do
          pending 'Bug with timezones in BST' # TODO: reinstate this line when entering BST
          travel_to(authorised_at) { claim }

          travel_to(redetermine_at) do
            claim.redetermine!
            claim.allocate!
          end

          travel_to(refused_at) { claim.refuse! }
        end

        it 'returns the created_at timestamp for the claim transition to the completed state' do
          expect(completed_ats).to eql([authorised_at, refused_at])
        end
      end

      context 'with an uncompleted journey' do
        before do
          pending 'Bug with timezones in BST' # TODO: reinstate this line when entering BST
          travel_to(authorised_at) { claim }

          travel_to(redetermine_at) do
            claim.redetermine!
            claim.allocate!
          end
        end

        it 'returns nil for timestamp of claim transition to a completed state' do
          expect(completed_ats).to eql([authorised_at, nil])
        end
      end

      # This non-deterministic test only tests BST when we are in BST
      # and UTC/GMT when we are outside of BST.
      # It will break only break during BST if the SQL query is not
      # using correct time zone - `at time zone 'Europe/London' - as the
      # app is using.
      #
      # Need to find a way to consistently stub a BST time within the last
      # 6 months - because transitions ove 6 months old are excluded anyway.
      # Note, we cannot stub postgres `current_date`.
      #
      context 'when handling timezones' do
        before do
          pending 'Bug with timezones in BST' # TODO: comment out this line when entering GMT
          create(:advocate_final_claim, :authorised)
        end

        it 'returns date in same time zone as current time zone for rails' do
          expect(completed_ats.first.utc).to be_within(5.seconds).of(Time.current.utc)
        end
      end
    end

    describe ':main_defendant' do
      subject { response.pluck(:main_defendant) }

      before do
        create(:advocate_final_claim, :allocated, create_defendant_and_rep_order: false).tap do |claim|
          create(:defendant, claim:, first_name: 'Jammy', last_name: 'Dodger')

          travel_to(2.seconds.ago) do
            create(:defendant, claim:, first_name: 'Main', last_name: 'Defendant')
          end

          claim.deallocate!
          claim.allocate!

          claim.tap do |c|
            assign_fees_and_expenses_for(c)
            c.authorise_part!
          end

          claim.redetermine!
          claim.allocate!
          claim.refuse!
        end
      end

      it 'returns the defendant that was created first for each journey' do
        is_expected.to contain_exactly('Main Defendant', 'Main Defendant')
      end
    end

    describe ':maat_reference' do
      subject { response.pluck(:maat_reference) }

      context 'with multiple defendants with rep orders with different representation_order_dates' do
        before do
          create(:advocate_final_claim, :allocated, create_defendant_and_rep_order: false).tap do |claim|
            create(:defendant, claim:, first_name: 'Main', last_name: 'Defendant').tap do |defendant|
              defendant.representation_orders = create_list(:representation_order,
                                                            1,
                                                            defendant:,
                                                            representation_order_date: 30.days.ago,
                                                            maat_reference: '4444441')
            end
            create(:defendant, claim:, first_name: 'Jammy', last_name: 'Dodger').tap do |defendant|
              defendant.representation_orders = create_list(:representation_order,
                                                            1,
                                                            defendant:,
                                                            representation_order_date: 31.days.ago,
                                                            maat_reference: '4444440')
            end
          end
        end

        it 'returns maat_reference of rep order with earliest representation_order_date' do
          is_expected.to contain_exactly('4444440')
        end
      end

      context 'with multiple defendants with rep orders with the same representation_order_date' do
        before do
          create(:advocate_final_claim, :allocated, create_defendant_and_rep_order: false).tap do |claim|
            create(:defendant, claim:, first_name: 'Main', last_name: 'Defendant').tap do |defendant|
              defendant.representation_orders = create_list(:representation_order,
                                                            1,
                                                            defendant:,
                                                            representation_order_date: 31.days.ago,
                                                            maat_reference: '4444440')
            end
            create(:defendant, claim:, first_name: 'Jammy', last_name: 'Dodger').tap do |defendant|
              defendant.representation_orders = create_list(:representation_order,
                                                            1,
                                                            defendant:,
                                                            representation_order_date: 31.days.ago,
                                                            maat_reference: '4444441')
            end
          end
        end

        it 'returns maat_reference of first created rep order' do
          is_expected.to contain_exactly('4444440')
        end
      end
    end

    describe ':rep_order_issued_date' do
      subject { response.pluck(:rep_order_issued_date) }

      before do
        create(:advocate_final_claim, :allocated, create_defendant_and_rep_order: false).tap do |claim|
          create(:defendant, claim:, first_name: 'Main', last_name: 'Defendant').tap do |defendant|
            defendant.representation_orders = [create(:representation_order,
                                                      defendant:,
                                                      representation_order_date: 30.days.ago),
                                               create(:representation_order,
                                                      defendant:,
                                                      representation_order_date: 29.days.ago)]
          end
          create(:defendant, claim:, first_name: 'Jammy', last_name: 'Dodger').tap do |defendant|
            defendant.representation_orders = [create(:representation_order,
                                                      defendant:,
                                                      representation_order_date: 31.days.ago),
                                               create(:representation_order,
                                                      defendant:,
                                                      representation_order_date: 29.days.ago)]
          end
        end
      end

      it { is_expected.to contain_exactly(31.days.ago.strftime('%F')) }
    end

    # authors full name for the "previous decision" that was redetermined or nil if previous decision was not redetermined
    describe ':af1_lf1_processed_by' do
      subject { response.pluck(:af1_lf1_processed_by) }

      let(:first) { create(:case_worker, user: create(:user, first_name: 'Case', last_name: 'Worker-one')) }
      let(:second) { create(:case_worker, user: create(:user, first_name: 'Case', last_name: 'Worker-two')) }
      let(:third) { create(:case_worker, user: create(:user, first_name: 'Case', last_name: 'Worker-three')) }

      before do
        create(:advocate_final_claim, :allocated).tap do |claim|
          claim.tap do |c|
            assign_fees_and_expenses_for(c)
            c.authorise_part!({ author_id: first.user.id })
          end

          claim.redetermine!
          claim.allocate!
          claim.refuse!({ author_id: second.user.id })
          claim.redetermine!
          claim.allocate!
          claim.refuse!({ author_id: third.user.id })
          claim.redetermine!
          claim.allocate!
        end
      end

      it {
        is_expected.to eql([nil, 'Case Worker-one', 'Case Worker-two', 'Case Worker-three'])
      }
    end

    describe ':misc_fees' do
      subject { response.pluck(:misc_fees) }

      before do
        create(:advocate_final_claim, :allocated).tap do |claim|
          claim.fees.clear
          claim.fees << create(:misc_fee, :miaph_fee, claim:)
          claim.fees << create(:misc_fee, :miahu_fee, claim:)
        end
      end

      it do
        is_expected.to contain_exactly(
          'Abuse of process hearings (half day) Abuse of process hearings (half day uplift)'
        )
      end
    end

    describe ':journey' do
      subject(:response) { described_class.call }

      let(:journey_tos) { response.pluck(:journey).map { |el| el.pluck(:to) } }

      it 'excludes state transitions to draft' do
        create(:advocate_final_claim, :allocated)
        expect(journey_tos).to contain_exactly(%w[submitted allocated])
      end

      it 'excludes state transitions to archived_pending_delete' do
        create(:litigator_final_claim, :archived_pending_delete)
        expect(journey_tos).to contain_exactly(%w[submitted allocated authorised])
      end

      it 'excludes state transitions to archived_pending_review' do
        create(:litigator_hardship_claim, :archived_pending_review)
        expect(journey_tos).to contain_exactly(%w[submitted allocated authorised])
      end

      # rubocop:disable RSpec/ExampleLength
      it 'excludes deallocations and deallocated allocations' do
        create(:advocate_final_claim, :allocated).tap do |claim|
          claim.deallocate!
          claim.allocate!
          claim.deallocate!
        end

        expect(journey_tos).to eq([%w[submitted]])
      end

      it 'excludes deallocations and all but last allocation' do
        create(:advocate_final_claim, :allocated).tap do |claim|
          claim.deallocate!
          claim.allocate!
          claim.deallocate!
          claim.allocate!
        end

        expect(journey_tos).to eq([%w[submitted allocated]])
      end
      # rubocop:enable RSpec/ExampleLength

      context 'when applying 6 month rule' do
        let(:claim) { create(:litigator_final_claim, :submitted) }

        # NOTE: The six month exclusion was only applied to handle failing reports and/or
        # keep the spreadsheet small for filtering purposes. It could be removed
        # if these problems are no longer issues.

        # IMPORTANT: query uses postgres `current_date` which cannot be stubbed so do not use freeze_time
        # as it will not be reflected by the query.

        it 'includes all transitions under 6 months old' do
          travel_to(6.months.ago.beginning_of_day + 1.second) { claim }
          claim.allocate!
          expect(journey_tos).to contain_exactly(%w[submitted allocated])
        end

        it 'includes state transitions exactly 6 months old' do
          travel_to(6.months.ago.beginning_of_day) { claim }
          claim.allocate!
          expect(journey_tos).to contain_exactly(%w[submitted allocated])
        end

        it 'excludes state transitions over 6 months old' do
          travel_to(6.months.ago.beginning_of_day - 1.second) { claim }
          claim.allocate!
          expect(journey_tos).to contain_exactly(%w[allocated])
        end
      end

      # rubocop:disable RSpec/ExampleLength
      context 'with a redetermination' do
        it 'slices transitions into "completed" chunks' do
          create(:advocate_final_claim, :allocated).tap do |claim|
            claim.tap do |c|
              assign_fees_and_expenses_for(c)
              c.authorise_part!
            end

            claim.redetermine!
            claim.allocate!
            claim.refuse!
          end

          expect(journey_tos).to eq([%w[submitted allocated part_authorised], %w[redetermination allocated refused]])
        end

        it 'slices transitions into "completed" chunks plus remainder' do
          create(:advocate_final_claim, :allocated).tap do |claim|
            claim.tap do |c|
              assign_fees_and_expenses_for(c)
              c.authorise_part!
            end

            claim.redetermine!
            claim.allocate!
            claim.refuse!
            claim.redetermine!
            claim.allocate!
          end

          expect(journey_tos).to eq([%w[submitted allocated part_authorised],
                                     %w[redetermination allocated refused],
                                     %w[redetermination allocated]])
        end

        it 'excludes deallocations and deallocated allocations per slice' do
          create(:advocate_final_claim, :allocated).tap do |claim|
            claim.deallocate!
            claim.allocate!
            claim.deallocate!
            claim.allocate!

            claim.tap do |c|
              assign_fees_and_expenses_for(c)
              c.authorise_part!
            end

            claim.redetermine!
            claim.allocate!
            claim.deallocate!
            claim.allocate!
            claim.refuse!
          end

          expect(journey_tos).to eq([%w[submitted allocated part_authorised], %w[redetermination allocated refused]])
        end
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end
end
