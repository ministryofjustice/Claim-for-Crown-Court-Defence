# frozen_string_literal: true

RSpec.describe Stats::ManagementInformation::DailyReportQuery do
  describe '.call' do
    subject(:response) { described_class.call }

    let(:scheme_class) { Stats::ManagementInformation::Scheme }

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
      subject(:call) { described_class.call({ scheme: scheme }) }

      let(:scheme) { :foobar }

      it { expect { call }.to raise_error ArgumentError, 'scheme must be "agfs" or "lgfs"' }
    end

    context 'with AGFS scheme scope' do
      subject(:response) { described_class.call({ scheme: scheme }) }

      let(:scheme) { :agfs }

      it 'returns AGFS claims only' do
        create(:advocate_final_claim, :submitted)
        create(:litigator_final_claim, :submitted)
        types = response.pluck(:type)

        expect(types).to match_array(%w[Claim::AdvocateClaim])
      end
    end

    context 'with LGFS claim scope' do
      subject(:response) { described_class.call({ scheme: scheme }) }

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

      it { is_expected.to match_array([claim.provider.name]) }
    end

    describe ':case_type_name' do
      subject { response.pluck(:case_type_name) }

      context 'with a claim without a case type' do
        before { create(:litigator_transfer_claim, :submitted) }

        it { is_expected.to all(be_nil) }
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

        it { is_expected.to match_array(['AGFS Final']) }
      end

      context 'with advocate supplementary claim' do
        before { create(:advocate_supplementary_claim, :submitted) }

        it { is_expected.to match_array(['AGFS Supplementary']) }
      end

      context 'with litigator final claim' do
        before { create(:litigator_final_claim, :submitted) }

        it { is_expected.to match_array(['LGFS Final']) }
      end

      context 'with litigator transfer claim' do
        before { create(:litigator_transfer_claim, :submitted) }

        it { is_expected.to match_array(['LGFS Transfer']) }
      end
    end

    describe ':claim_total' do
      subject { response.pluck(:claim_total) }

      let!(:claim) { create(:litigator_final_claim, :submitted) }

      it { is_expected.to match_array([format('%.2f', claim.total_including_vat)]) }
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

    describe ':main_defendant' do
      subject { response.pluck(:main_defendant) }

      before do
        create(:advocate_final_claim, :allocated, create_defendant_and_rep_order: false).tap do |claim|
          create(:defendant, claim: claim, first_name: 'Main', last_name: 'Defendant')
          create(:defendant, claim: claim, first_name: 'Jammy', last_name: 'Dodger')
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

      it { is_expected.to match_array(['Main Defendant', 'Main Defendant']) }
    end

    describe ':maat_reference' do
      subject { response.pluck(:maat_reference) }

      before do
        create(:advocate_final_claim, :allocated, create_defendant_and_rep_order: false).tap do |claim|
          create(:defendant, claim: claim, first_name: 'Main', last_name: 'Defendant').tap do |defendant|
            defendant.representation_orders = [create(:representation_order,
                                                      defendant: defendant,
                                                      representation_order_date: 30.days.ago,
                                                      maat_reference: '4444442'),
                                               create(:representation_order,
                                                      defendant: defendant,
                                                      representation_order_date: 29.days.ago,
                                                      maat_reference: '4444444')]
          end
          create(:defendant, claim: claim, first_name: 'Jammy', last_name: 'Dodger').tap do |defendant|
            defendant.representation_orders = [create(:representation_order,
                                                      defendant: defendant,
                                                      representation_order_date: 31.days.ago,
                                                      maat_reference: '4444441'),
                                               create(:representation_order,
                                                      defendant: defendant,
                                                      representation_order_date: 29.days.ago,
                                                      maat_reference: '4444443')]
          end
        end
      end

      it { is_expected.to match_array(['4444441']) }
    end

    describe ':rep_order_issued_date' do
      subject { response.pluck(:rep_order_issued_date) }

      before do
        create(:advocate_final_claim, :allocated, create_defendant_and_rep_order: false).tap do |claim|
          create(:defendant, claim: claim, first_name: 'Main', last_name: 'Defendant').tap do |defendant|
            defendant.representation_orders = [create(:representation_order,
                                                      defendant: defendant,
                                                      representation_order_date: 30.days.ago),
                                               create(:representation_order,
                                                      defendant: defendant,
                                                      representation_order_date: 29.days.ago)]
          end
          create(:defendant, claim: claim, first_name: 'Jammy', last_name: 'Dodger').tap do |defendant|
            defendant.representation_orders = [create(:representation_order,
                                                      defendant: defendant,
                                                      representation_order_date: 31.days.ago),
                                               create(:representation_order,
                                                      defendant: defendant,
                                                      representation_order_date: 29.days.ago)]
          end
        end
      end

      it { is_expected.to match_array([31.days.ago.strftime('%F')]) }
    end

    # authors full name for the "previous decision" that was redetermined or nil if previous decision was not redetermined
    describe ':af1_lf1_processed_by' do
      subject { response.pluck(:af1_lf1_processed_by) }

      let(:case_worker1) { create(:case_worker, user: create(:user, first_name: 'Case', last_name: 'Worker-one')) }
      let(:case_worker2) { create(:case_worker, user: create(:user, first_name: 'Case', last_name: 'Worker-two')) }
      let(:case_worker3) { create(:case_worker, user: create(:user, first_name: 'Case', last_name: 'Worker-three')) }

      before do
        create(:advocate_final_claim, :allocated).tap do |claim|
          claim.tap do |c|
            assign_fees_and_expenses_for(c)
            c.authorise_part!({ author_id: case_worker1.user.id })
          end

          claim.redetermine!
          claim.allocate!
          claim.refuse!({ author_id: case_worker2.user.id })
          claim.redetermine!
          claim.allocate!
          claim.refuse!({ author_id: case_worker3.user.id })
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
          claim.fees << create(:misc_fee, :miaph_fee, claim: claim)
          claim.fees << create(:misc_fee, :miahu_fee, claim: claim)
        end
      end

      it {
        is_expected.to match_array(['Abuse of process hearings (half day) Abuse of process hearings (half day uplift)'])
      }
    end

    context 'with claim state transitions' do
      subject(:response) { described_class.call }

      let(:transition_tos) { response.pluck(:journey).map { |el| el.pluck(:to) } }

      it 'excludes state transitions to draft' do
        create(:advocate_final_claim, :allocated)
        expect(transition_tos).to match_array([%w[submitted allocated]])
      end

      it 'excludes state transitions to archived_pending_delete' do
        create(:litigator_final_claim, :archived_pending_delete)
        expect(transition_tos).to match_array([%w[submitted allocated authorised]])
      end

      it 'excludes state transitions to archived_pending_review' do
        create(:litigator_hardship_claim, :archived_pending_review)
        expect(transition_tos).to match_array([%w[submitted allocated authorised]])
      end

      # TODO: remove debug helper
      # let(:time_info) do
      #   { ruby_current_datetime: DateTime.current.iso8601,
      #     ruby_now_datetime: DateTime.now.iso8601,
      #     postgres_now: ActiveRecord::Base.connection.execute('select now()').to_a,
      #     postgres_now_6_months_ago: ActiveRecord::Base.connection.execute("select (now() - '6 months'::interval)").to_a,
      #     postgres_now_6_months_ago_cast: ActiveRecord::Base.connection.execute("select (now() - '6 months'::interval) at time zone 'utc' at time zone 'Europe/London'").to_a,
      #     postgres_now_6_months_ago_trunc_cast: ActiveRecord::Base.connection.execute("select DATE_TRUNC('day', (now() - '6 months'::interval) at time zone 'utc' at time zone 'Europe/London')").to_a }
      # end

      context 'when applying 6 month rule' do
        let(:claim) { create(:litigator_final_claim, :submitted) }

        # NOTE: The six month exclusion was only applied to handle failing reports and/or
        # keep the spreadsheet small for filtering purposes. It could be removed
        # if these problems are no longer issues.

        # TODO: handle boundaries for BST and GMT/UTC
        #
        # 1. We want this to fail if 6.months.ago.beginning_of_day falls INSIDE BST
        # (end of march to end of october rougly) and the query is not using
        # 'Europe/London' timezone "casting".
        #
        # 2. We want this to fail if 6.months.ago.beginning_of_day falls OUTSIDE BST
        # (beginning november to end of march roughly) and the query is not using
        # 'Europe/London' timezone "casting".
        #
        # IMPORTANT: query uses postgres `now()` which cannot be stubbed
        #

        # TODO: this emulates MI version 1 current behaviour, however:

        # 1. the 6 month rule should probably include transitions that are exactly 6 months old.
        # 2. it is time sensitive (and performance sensitive) as there is no way to stub postgres
        #    db now() method. It may be flaky therefore.
        # 3. to improve this, and the report logic generally, we should truncate the date comparisons on
        # old and new MI reports to nearest date (i.e. not datetime). This will provide clear behaviour
        # as well as be more testable.

        it 'includes all transitions under 6 months old' do
          travel_to(6.months.ago + 1.second) { claim }
          claim.allocate!
          expect(transition_tos).to match_array([%w[submitted allocated]])
        end

        it 'excludes state transitions exactly 6 months old' do
          travel_to(6.months.ago) { claim }
          claim.allocate!
          expect(transition_tos).to match_array([%w[allocated]])
        end

        it 'excludes state transitions over 6 months old' do
          travel_to(6.months.ago - 1.second) { claim }
          claim.allocate!
          expect(transition_tos).to match_array([%w[allocated]])
        end
      end

      # rubocop:disable RSpec/ExampleLength
      it 'excludes deallocations and deallocated allocations' do
        create(:advocate_final_claim, :allocated).tap do |claim|
          claim.deallocate!
          claim.allocate!
          claim.deallocate!
        end

        expect(transition_tos).to eq([%w[submitted]])
      end

      it 'excludes deallocations and all but last allocation' do
        create(:advocate_final_claim, :allocated).tap do |claim|
          claim.deallocate!
          claim.allocate!
          claim.deallocate!
          claim.allocate!
        end

        expect(transition_tos).to eq([%w[submitted allocated]])
      end

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

          expect(transition_tos).to eq([%w[submitted allocated part_authorised], %w[redetermination allocated refused]])
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

          expect(transition_tos).to eq([%w[submitted allocated part_authorised],
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

          expect(transition_tos).to eq([%w[submitted allocated part_authorised], %w[redetermination allocated refused]])
        end
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end
end
